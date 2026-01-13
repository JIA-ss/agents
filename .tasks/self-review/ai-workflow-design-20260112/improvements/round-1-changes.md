# Round 1 Improvements

## Issues Addressed

### Issue 1: Workflow commands not executable (MAJOR)
**Status**: FIXED

**Changes**:
- Rewrote Section 5.2 in workflow-design.md
- Separated "Existing Skills" (directly usable) from "Manual Operations"
- Documented that `/specify`, `/plan`, `/tasks` require manual template usage
- Added note about future skill implementation

### Issue 2: Config schema conflict (MAJOR)
**Status**: FIXED

**Changes**:
- Updated workflow-design.md example config to match templates/config.yaml
- Changed `tools.test_command` → `tools.test.command`
- Changed `tdd.test_first_threshold` → `tdd.test_first`
- Added nested structure for tool commands

### Issue 3: Tool-agnostic claim vs TypeScript-specific templates (MAJOR)
**Status**: FIXED

**Changes**:
- Added Section 1.2 "Multi-Stack Support" to workflow-design.md
- Added "Stack-Flexible" principle to core principles
- Documented how to adapt for Python, Go, Rust, Java
- Explained template customization strategy

### Issue 4: Security conflict (MAJOR)
**Status**: FIXED

**Changes**:
- Changed templates/config.yaml `sandbox: "danger-full-access"` → `sandbox: "sandbox"`
- Added comment explaining when to opt into full access

### Issue 5: Phase checkpoint inconsistency (MAJOR)
**Status**: FIXED

**Changes**:
- Changed templates/config.yaml `after_tasks: false` → `after_tasks: true`
- Added comment "(Full Mode: true)" to clarify this is full mode config
- Comment mentions Quick Mode can set all to false

### Issue 6: Test directory inconsistency (MINOR)
**Status**: FIXED

**Changes**:
- Updated templates/constitution.md to use `tests/` directory
- Added note: "测试目录约定为 `tests/`，与源码目录平级"
- Removed `__tests__/` reference

### Issue 7: Missing directory structure template (MINOR)
**Status**: FIXED

**Changes**:
- Created new file: templates/structure.md
- Includes standard structure, stack-specific variations
- Includes quick setup script

## Files Modified

1. workflow-design.md
   - Section 1.1: Added Stack-Flexible principle
   - Section 1.2: New Multi-Stack Support section
   - Section 4.1: Updated config example
   - Section 5.2: Rewrote workflow commands

2. templates/config.yaml
   - Changed sandbox default to "sandbox"
   - Changed after_tasks to true
   - Added clarifying comments

3. templates/constitution.md
   - Updated test directory convention

4. templates/structure.md (NEW)
   - Added directory structure template

## Ready for Round 2 Review

All 7 issues have been addressed.
