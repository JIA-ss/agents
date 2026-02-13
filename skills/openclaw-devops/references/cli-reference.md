# OpenClaw CLI Quick Reference

## Table of Contents

- [Gateway Management](#gateway-management)
- [Log Monitoring](#log-monitoring)
- [Model & Provider Management](#model--provider-management)
- [Skill & Plugin Management](#skill--plugin-management)
- [Cron Job Management](#cron-job-management)
- [Configuration](#configuration)
- [Channel Management](#channel-management)
- [Session & Agent Management](#session--agent-management)
- [Browser Management](#browser-management)
- [System & Updates](#system--updates)

---

## Gateway Management

```bash
# Status & health
openclaw gateway status              # Gateway service status + probe
openclaw health                      # Fetch gateway health
openclaw health --json               # Health as JSON
openclaw status                      # Channel health + session info
openclaw status --all                # Full diagnosis
openclaw status --usage              # Include model usage/quota
openclaw status --deep               # Probe all channels

# Service control
openclaw gateway start               # Start gateway service
openclaw gateway stop                # Stop gateway service
openclaw gateway restart             # Restart gateway service
openclaw daemon status               # Daemon install status
openclaw daemon install              # Install as system service
openclaw daemon uninstall            # Remove system service

# Diagnostics
openclaw doctor                      # Health checks + quick fixes
openclaw doctor --repair             # Apply recommended repairs
openclaw doctor --deep               # Scan for extra gateway installs
openclaw security audit              # Security audit
openclaw security audit --fix        # Auto-fix security issues
```

## Log Monitoring

```bash
# Gateway logs
openclaw logs                        # Tail gateway logs
openclaw logs --limit 100            # Last 100 lines
openclaw logs --follow               # Follow (tail -f)
openclaw logs --json                 # JSON log lines

# Channel logs
openclaw channels logs               # Recent channel logs
openclaw channels logs --channel telegram  # Telegram-specific
```

## Model & Provider Management

```bash
# Status
openclaw models status               # Configured model state
openclaw models status --probe       # Live probe auth
openclaw models list                 # List configured models
openclaw models list --all           # Full model catalog

# Configuration
openclaw models set <model-id>       # Set default model
openclaw models set-image <model-id> # Set image model

# Fallbacks
openclaw models fallbacks list       # List fallback chain
openclaw models fallbacks add <id>   # Add fallback model
openclaw models fallbacks remove <id> # Remove fallback

# Auth profiles
openclaw models auth add             # Interactive auth setup
openclaw models auth login --provider <id>  # Provider login flow
openclaw models auth setup-token     # Create/sync API token
openclaw models auth paste-token --provider <id>  # Paste token

# Scanning
openclaw models scan                 # Scan OpenRouter free models
openclaw models scan --min-params 70 # Filter by parameter size

# Aliases
openclaw models aliases list         # List model aliases
openclaw models aliases add <alias> <model>  # Add alias
```

## Skill & Plugin Management

```bash
# Skills
openclaw skills list                 # List all skills
openclaw skills list --eligible      # Show ready-to-use skills
openclaw skills info <name>          # Skill details
openclaw skills check                # Check requirements

# Plugins
openclaw plugins list                # List plugins
openclaw plugins list --enabled      # Only enabled
openclaw plugins info <name>         # Plugin details
openclaw plugins enable <name>       # Enable plugin
openclaw plugins disable <name>      # Disable plugin
openclaw plugins install <spec>      # Install plugin
openclaw plugins doctor              # Report load issues
```

## Cron Job Management

```bash
openclaw cron status                 # Scheduler status
openclaw cron list                   # List jobs
openclaw cron list --all             # Include disabled
openclaw cron runs --id <job-id>     # Run history
openclaw cron run <job-id> --force   # Manual trigger
openclaw cron enable <job-id>        # Enable job
openclaw cron disable <job-id>       # Disable job
openclaw cron add --name <n> --every <interval> --message <msg>  # Add job
openclaw cron rm <job-id>            # Remove job
openclaw cron edit <job-id> --message <msg>  # Edit job
```

## Configuration

```bash
openclaw config get <dot.path>       # Read config value
openclaw config set <dot.path> <val> # Set config value
openclaw config unset <dot.path>     # Remove config value
```

## Channel Management

```bash
openclaw channels list               # List channels + auth
openclaw channels status             # Gateway channel status
openclaw channels status --probe     # Probe credentials
openclaw channels capabilities       # Show provider capabilities
openclaw channels add --channel <type>  # Add channel
openclaw channels remove --channel <type>  # Remove channel
openclaw channels login --channel <alias>  # Link account
openclaw channels logout --channel <alias> # Log out
```

## Session & Agent Management

```bash
openclaw sessions                    # List sessions
openclaw sessions --active           # Active sessions only
openclaw agents list                 # List agents
openclaw agent -m "message"          # Run agent turn
```

## Browser Management

```bash
openclaw browser status              # Browser status
openclaw browser start               # Start browser
openclaw browser stop                # Stop browser
openclaw browser tabs                # List open tabs
```

## System & Updates

```bash
openclaw update status               # Version + update check
openclaw update                      # Update to latest
openclaw update --channel beta       # Switch to beta
openclaw --version                   # Show version
```
