---
name: payment-system
description: >
  支付系统专家，负责订单支付、退款、对账和第三方支付渠道集成的完整实现。
  Use when the user asks to "implement payment flow", "debug payment callback",
  "configure payment channel", "fix refund logic", "optimize payment performance",
  mentions "PaymentService", "OrderPayment", "RefundService", "PaymentGateway",
  or needs help with payment processing, transaction management and reconciliation.
  Also responds to "实现支付流程", "调试支付回调", "配置支付渠道", "修复退款逻辑", "对账问题排查".
related-skills: [order-system, notification-system, user-auth]
deprecated: false
superseded-by: ""
---

# Payment System 支付系统指南

## Overview

支付系统专家，精通第三方支付集成、交易状态管理和资金安全。负责订单支付、退款处理、异步回调、对账和支付渠道管理。

**核心能力**：
- **支付集成**：微信支付、支付宝、银行卡等多渠道统一接入
- **交易管理**：订单创建、支付、退款的完整生命周期管理
- **安全保障**：签名验证、幂等性、防重放、资金安全
- **对账系统**：每日自动对账、差异处理、财务报表

**核心职责**：
- 诊断和解决支付回调异常（签名失败、超时、重复通知）
- 实现新支付渠道接入和配置
- 优化支付流程性能（减少支付延迟、提高成功率）
- 处理退款和争议交易

## Core Rules

### 规则 1: 支付回调必须验签且保证幂等性

**所有第三方支付回调必须先验签再处理业务，且同一笔交易的重复回调不可重复扣款/退款：**
```javascript
// !! 错误：不验签直接处理
router.post('/payment/callback', async (req, res) => {
  const { orderId, amount } = req.body;
  await orderService.markPaid(orderId); // 危险：任何人都能伪造请求
  res.send('SUCCESS');
});

// >> 正确：验签 + 幂等性检查
router.post('/payment/callback', async (req, res) => {
  // 1. 验证签名
  if (!paymentGateway.verifySignature(req.body, req.headers)) {
    logger.warn('支付回调签名验证失败', { body: req.body });
    return res.status(403).send('SIGNATURE_INVALID');
  }

  // 2. 幂等性检查
  const { outTradeNo, transactionId } = req.body;
  const existingTx = await Transaction.findOne({ where: { transactionId } });
  if (existingTx) {
    return res.send('SUCCESS'); // 已处理过，直接返回成功
  }

  // 3. 在事务中处理业务
  await sequelize.transaction(async (t) => {
    await Transaction.create({ outTradeNo, transactionId, status: 'paid' }, { transaction: t });
    await Order.update({ status: 'paid' }, { where: { orderNo: outTradeNo }, transaction: t });
  });

  res.send('SUCCESS');
});
```

### 规则 2: 金额计算必须使用整数（分），禁止浮点数

**所有金额存储和计算必须以"分"为单位使用整数，避免浮点精度问题：**
```javascript
// !! 错误：使用浮点数计算金额
const total = 19.9 + 0.1; // 结果可能是 20.000000000000004
const discount = price * 0.85; // 精度丢失

// >> 正确：以分为单位使用整数计算
const totalCents = 1990 + 10; // 2000 分 = 20.00 元
const discountCents = Math.round(priceCents * 85 / 100); // 整数运算

// 仅在展示时转换为元
function centsToYuan(cents) {
  return (cents / 100).toFixed(2);
}
```

### 规则 3: 支付操作必须在数据库事务中执行

**涉及资金变动的操作必须使用数据库事务，保证原子性：**
```javascript
// !! 错误：分步操作，可能出现中间状态
await Order.update({ status: 'paid' }, { where: { id: orderId } });
await Account.decrement('balance', { by: amount, where: { userId } });
// 如果第二步失败，订单已标记为已支付但余额未扣除

// >> 正确：事务保证原子性
await sequelize.transaction(async (t) => {
  await Order.update(
    { status: 'paid', paidAt: new Date() },
    { where: { id: orderId, status: 'pending' }, transaction: t }
  );
  await Account.decrement('balance', {
    by: amount,
    where: { userId },
    transaction: t
  });
  await TransactionLog.create({
    orderId, userId, amount, type: 'payment'
  }, { transaction: t });
});
```

### 规则 4: 支付状态流转必须严格遵守状态机

**订单支付状态必须按有向图流转，禁止跳跃状态：**
```
合法状态流转：
  pending --> paid --> refunding --> refunded
  pending --> cancelled
  pending --> expired
  paid --> refunding --> refund_failed --> refunding
```

```javascript
// !! 错误：不检查当前状态直接更新
await Order.update({ status: 'refunded' }, { where: { id: orderId } });

// >> 正确：检查当前状态是否允许流转
const VALID_TRANSITIONS = {
  pending: ['paid', 'cancelled', 'expired'],
  paid: ['refunding'],
  refunding: ['refunded', 'refund_failed'],
  refund_failed: ['refunding'],
};

async function transitionOrderStatus(orderId, newStatus, transaction) {
  const order = await Order.findByPk(orderId, { lock: true, transaction });
  const allowed = VALID_TRANSITIONS[order.status] || [];
  if (!allowed.includes(newStatus)) {
    throw new PaymentError(`非法状态流转: ${order.status} -> ${newStatus}`);
  }
  await order.update({ status: newStatus }, { transaction });
}
```

### 规则 5: 敏感支付配置必须通过环境变量管理

**支付密钥、证书路径等敏感信息禁止硬编码：**
```javascript
// !! 错误：硬编码密钥
const config = {
  appId: 'wx1234567890',
  mchKey: 'abc123secretkey',  // 泄露风险
};

// >> 正确：通过环境变量注入
const config = {
  appId: process.env.WECHAT_APP_ID,
  mchId: process.env.WECHAT_MCH_ID,
  mchKey: process.env.WECHAT_MCH_KEY,
  certPath: process.env.WECHAT_CERT_PATH,
};

// 启动时校验必要配置
const requiredEnvVars = ['WECHAT_APP_ID', 'WECHAT_MCH_ID', 'WECHAT_MCH_KEY'];
for (const envVar of requiredEnvVars) {
  if (!process.env[envVar]) {
    throw new Error(`缺少必要环境变量: ${envVar}`);
  }
}
```

## Reference Files

**核心实现**：
```
src/services/payment/
├── PaymentService.js                # 支付服务主入口
├── RefundService.js                 # 退款服务
├── ReconciliationService.js         # 对账服务
├── gateways/
│   ├── WechatPayGateway.js          # 微信支付渠道
│   ├── AlipayGateway.js             # 支付宝渠道
│   └── BaseGateway.js               # 支付渠道基类
├── models/
│   ├── Transaction.js               # 交易记录模型
│   ├── RefundRecord.js              # 退款记录模型
│   └── ReconciliationLog.js         # 对账日志模型
└── utils/
    ├── signatureHelper.js           # 签名工具
    └── amountHelper.js              # 金额转换工具
```

**配置文件**：
```
config/
├── payment.config.js                # 支付渠道配置（读取环境变量）
└── payment.constants.js             # 支付相关常量（状态枚举等）
```

**测试文件**：
```
tests/payment/
├── PaymentService.test.js           # 支付服务单元测试
├── RefundService.test.js            # 退款服务单元测试
├── signatureHelper.test.js          # 签名验证测试
└── fixtures/
    ├── wechat-callback.json         # 微信回调模拟数据
    └── alipay-callback.json         # 支付宝回调模拟数据
```

## Workflow

### 1. 支付问题诊断流程

**Step 1: 确认问题范围**
```
检查点：
- 是单笔订单还是批量问题
- 影响的支付渠道（微信/支付宝/全部）
- 问题发生的阶段（创建订单/发起支付/回调/退款）
```

**Step 2: 查看交易日志**
```
- 检查 Transaction 表中该订单的记录
- 查看支付网关的请求/响应日志
- 对比第三方平台的交易状态
```

**Step 3: 排查常见原因**
```
- 签名验证失败：检查密钥配置和签名算法
- 超时未回调：检查回调 URL 是否可达、证书是否过期
- 金额不一致：检查金额单位转换（元/分）
- 重复支付：检查幂等性机制是否生效
```

### 2. 新支付渠道接入流程

**申请 --> 开发 --> 联调 --> 上线**

#### 接入检查清单

| 阶段 | 任务 | 状态 |
|------|------|------|
| **准备** | 申请商户号和 API 密钥 | - |
| **准备** | 阅读支付平台 API 文档 | - |
| **开发** | 继承 BaseGateway 实现渠道类 | - |
| **开发** | 实现签名/验签逻辑 | - |
| **开发** | 实现创建订单/查询/退款接口 | - |
| **测试** | 沙箱环境联调 | - |
| **测试** | 编写单元测试和集成测试 | - |
| **上线** | 配置生产环境密钥 | - |
| **上线** | 灰度放量验证 | - |

## Best Practices

### 实践 1: 使用统一的支付网关抽象层

**所有支付渠道继承同一基类，业务层无需感知底层渠道差异：**
```javascript
class BaseGateway {
  async createOrder(orderInfo) { throw new Error('子类必须实现'); }
  async queryOrder(outTradeNo) { throw new Error('子类必须实现'); }
  async refund(refundInfo) { throw new Error('子类必须实现'); }
  verifySignature(payload, headers) { throw new Error('子类必须实现'); }
}

// 工厂模式选择渠道
function getGateway(channel) {
  const gateways = {
    wechat: new WechatPayGateway(),
    alipay: new AlipayGateway(),
  };
  return gateways[channel] || throw new Error(`不支持的支付渠道: ${channel}`);
}
```

### 实践 2: 支付超时自动关单

**创建支付订单后设置超时任务，到期未支付自动关闭：**
```javascript
import { Queue } from 'bullmq';

const paymentQueue = new Queue('payment-timeout');

async function createPaymentOrder(orderData) {
  const order = await Order.create({ ...orderData, status: 'pending' });

  // 30分钟后自动关单
  await paymentQueue.add('close-order', { orderId: order.id }, {
    delay: 30 * 60 * 1000,
    removeOnComplete: true,
  });

  return order;
}
```

### 实践 3: 对账任务每日定时执行

**使用定时任务每天凌晨拉取第三方账单进行对账：**
```javascript
// 每日 2:00 AM 执行对账
cron.schedule('0 2 * * *', async () => {
  const yesterday = dayjs().subtract(1, 'day').format('YYYY-MM-DD');
  await reconciliationService.reconcile(yesterday);
});
```

## Common Issues

### Issue 1: 支付回调签名验证失败

**症状**：第三方支付平台已扣款成功，但系统返回签名验证失败，订单状态未更新。

**诊断步骤**：
```
1. 检查商户密钥是否与平台后台一致
2. 检查签名算法版本（如微信支付 v2/v3 差异）
3. 检查请求 body 解析方式（是否正确获取原始 body）
4. 对比本地计算的签名与回调中的签名
```

**解决方案**：
```javascript
// 确保获取原始 body 而非解析后的 JSON
app.use('/payment/callback', express.raw({ type: 'text/xml' }));

// 使用原始 body 计算签名
router.post('/payment/callback', (req, res) => {
  const rawBody = req.body.toString();
  const isValid = paymentGateway.verifySignature(rawBody);
  // ...
});
```

### Issue 2: 重复支付 / 重复退款

**症状**：同一笔订单出现多次扣款或退款记录。

**可能原因**：
```
1. 回调幂等性未实现 → 添加 transactionId 唯一索引和查重逻辑
2. 前端重复提交 → 添加按钮防重和请求去重中间件
3. 超时重试无去重 → 使用唯一的 outTradeNo 作为幂等键
```

### Issue 3: 对账金额不一致

**症状**：系统交易金额与第三方平台账单金额不匹配。

**排查清单**：
```
1. 检查金额单位是否统一（分 vs 元）
2. 检查是否有未入库的成功回调（回调处理失败）
3. 检查退款是否在对账时正确扣减
4. 检查汇率转换逻辑（跨境支付场景）
```

---

**最后更新**: 2026-02-09
**版本**: 1.0
**维护者**: ecommerce-api 团队
