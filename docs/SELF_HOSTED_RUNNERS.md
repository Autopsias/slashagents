# Self-Hosted macOS Runners Setup Guide

**Version:** 1.0.0 | **Updated:** 2025-12-25

This guide helps you set up and maintain self-hosted macOS runners for the CC_Agents_Commands CI pipeline. Self-hosted runners provide faster execution, cost savings, and greater control over your CI/CD environment.

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Initial Setup](#initial-setup)
- [Runner Configuration](#runner-configuration)
- [Maintenance](#maintenance)
- [Troubleshooting](#troubleshooting)
- [Monitoring](#monitoring)

## Overview

The CC_Agents_Commands project uses self-hosted macOS runners for lightweight documentation validation:
- Markdown linting (markdownlint-cli2)
- Link validation (markdown-link-check)
- Shell script linting (ShellCheck)
- File structure validation
- Content validation

**Runner Requirements:**
- macOS machine (M1/M2 ARM64 or Intel X64)
- GitHub repository admin access
- Stable internet connection

## Prerequisites

### 1. Install Homebrew

If not already installed:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Verify installation:

```bash
brew --version
```

### 2. Install ShellCheck

ShellCheck is required for shell script linting:

```bash
brew install shellcheck
```

Verify installation:

```bash
shellcheck --version
# Should show version 0.9.0 or higher
```

### 3. Install Modern Bash (Optional but Recommended)

macOS ships with bash 3.2, but bash 5+ has better features:

```bash
brew install bash
```

### 4. Verify Node.js Support

The workflow uses `actions/setup-node@v4` which handles Node.js installation automatically. No pre-installation needed, but verify npm is available:

```bash
npm --version
```

If not installed:

```bash
brew install node
```

## Initial Setup

### Step 1: Create Runner Directory

Create a dedicated directory for the GitHub Actions runner:

```bash
mkdir -p ~/actions-runner && cd ~/actions-runner
```

### Step 2: Download Runner Package

1. Navigate to your GitHub repository: `https://github.com/[owner]/CC_Agents_Commands`
2. Go to: **Settings** → **Actions** → **Runners**
3. Click: **New self-hosted runner**
4. Select: **macOS** as the operating system
5. Choose architecture:
   - **ARM64** for M1/M2 Macs
   - **X64** for Intel Macs

6. Copy the download URL and run:

```bash
# Example for ARM64 (check GitHub UI for latest version)
curl -o actions-runner-osx-arm64-2.311.0.tar.gz -L \
  https://github.com/actions/runner/releases/download/v2.311.0/actions-runner-osx-arm64-2.311.0.tar.gz

# Extract
tar xzf ./actions-runner-osx-arm64-*.tar.gz
```

### Step 3: Configure Runner

Configure the runner with your repository:

```bash
./config.sh \
  --url https://github.com/[owner]/CC_Agents_Commands \
  --token [YOUR_REGISTRATION_TOKEN] \
  --labels self-hosted,macOS,ARM64,self-hosted-macos \
  --name macos-runner-1 \
  --work _work
```

**Important Labels:**
- `self-hosted` - Built-in label (automatic)
- `macOS` - Built-in label (automatic)
- `ARM64` or `X64` - Built-in label (automatic)
- `self-hosted-macos` - **Custom label required by workflows**

**Configuration prompts:**
- Runner group: Press Enter (default)
- Runner name: `macos-runner-1` (or your preferred name)
- Work folder: Press Enter (uses `_work` default)
- Run as service: See Step 4

### Step 4: Install as Service (Recommended)

Running as a service ensures the runner starts automatically on boot:

```bash
./svc.sh install
./svc.sh start
```

Verify the service is running:

```bash
./svc.sh status
# Should show "active (running)"
```

To check via launchctl:

```bash
launchctl list | grep actions.runner
# Should show the runner service
```

## Runner Configuration

### Runner Labels Explained

The workflow file uses these labels to select runners:

```yaml
runs-on: [self-hosted, macOS, self-hosted-macos]
```

This means:
- `self-hosted` - Must be a self-hosted runner (not GitHub-hosted)
- `macOS` - Must be running macOS
- `self-hosted-macos` - Custom label for this specific runner pool

### Multiple Runners (Optional)

To add redundancy, configure multiple runners:

```bash
# On second Mac
mkdir -p ~/actions-runner && cd ~/actions-runner
# Repeat download and configuration steps
# Use name: macos-runner-2, macos-runner-3, etc.
```

All runners with the same labels will pick up jobs in a round-robin fashion.

### Runner Isolation

Each runner maintains isolated workspaces in the `_work` directory:

```
~/actions-runner/_work/
├── CC_Agents_Commands/  # Repository checkout
│   └── CC_Agents_Commands/  # Actual code
├── _actions/  # Cached actions
├── _temp/  # Temporary files
└── _tool/  # Tool cache (Node.js versions)
```

The workflow's cleanup steps ensure no state contamination between runs.

## Maintenance

### Daily Maintenance (Automatic)

The workflow includes pre-job and post-job cleanup steps that run automatically:

**Pre-job cleanup:**
- Removes previous workspace files
- Clears temporary directories
- Prepares clean environment

**Post-job cleanup:**
- Removes workspace (even on failure with `if: always()`)
- Clears temp files
- Removes npm cache artifacts

No manual intervention required for daily maintenance.

### Weekly Maintenance (Automated)

The `runner-maintenance.yml` workflow runs every Sunday at 2 AM:

```yaml
schedule:
  - cron: '0 2 * * 0'  # 2 AM every Sunday
```

Tasks performed:
- Homebrew cleanup (`brew cleanup -s`, `brew autoremove`)
- Clear system caches (`~/Library/Caches/*`, `~/Library/Logs/*`)
- Remove old temp files (7+ days old)
- Report disk usage

You can also trigger manually:

```bash
# Via GitHub UI: Actions → Runner Maintenance → Run workflow
```

### Monthly Maintenance (Manual)

Perform these tasks monthly:

#### 1. Update Runner Software

```bash
cd ~/actions-runner

# Stop the service
./svc.sh stop

# Download latest runner (check GitHub releases)
curl -o actions-runner-osx-arm64-latest.tar.gz -L \
  [latest-release-url]

# Extract over existing
tar xzf ./actions-runner-osx-arm64-latest.tar.gz

# Restart service
./svc.sh start
```

#### 2. Update Homebrew Packages

```bash
brew update
brew upgrade shellcheck
brew cleanup
```

#### 3. Check Disk Space

```bash
df -h /
# Ensure at least 10GB free
```

If low on space:

```bash
# Deep clean
brew cleanup --prune=all -s
rm -rf ~/Library/Caches/*
rm -rf ~/actions-runner/_work/_temp/*
```

#### 4. Review Runner Logs

```bash
cd ~/actions-runner
ls -lh _diag/*.log | tail -5

# Check for errors
tail -100 _diag/Runner_*.log | grep -i error
```

## Troubleshooting

### Runner Not Picking Up Jobs

**Symptoms:** Jobs stay queued, runner shows as "Offline" in GitHub UI

**Diagnosis:**

```bash
# Check service status
./svc.sh status

# Check launchctl
launchctl list | grep actions.runner
```

**Solutions:**

1. **Service stopped:**
   ```bash
   cd ~/actions-runner
   ./svc.sh start
   ```

2. **Network connectivity:**
   ```bash
   # Test GitHub connectivity
   curl -I https://github.com
   ```

3. **Authentication expired:**
   ```bash
   # Re-configure runner
   ./config.sh remove
   # Follow Step 3 in Initial Setup
   ```

### Disk Space Issues

**Symptoms:** Jobs fail with "No space left on device"

**Diagnosis:**

```bash
df -h /
du -sh ~/actions-runner/_work
```

**Solutions:**

1. **Clear workspace manually:**
   ```bash
   cd ~/actions-runner
   rm -rf _work/*
   ```

2. **Deep Homebrew cleanup:**
   ```bash
   brew cleanup --prune=all -s
   rm -rf "$(brew --cache)"
   ```

3. **Clear system caches:**
   ```bash
   rm -rf ~/Library/Caches/*
   rm -rf ~/Library/Logs/*
   ```

### Permission Errors

**Symptoms:** Jobs fail with "Permission denied" when cleaning workspace

**Diagnosis:**

```bash
ls -la ~/actions-runner/_work
```

**Solutions:**

1. **Fix ownership:**
   ```bash
   cd ~/actions-runner
   chown -R $(whoami) _work/
   ```

2. **Fix permissions:**
   ```bash
   chmod -R u+rwX _work/
   ```

### Jobs Start but Fail Immediately

**Symptoms:** Workflow starts, then fails in pre-job cleanup or checkout

**Diagnosis:**

```bash
# Check recent logs
tail -100 ~/actions-runner/_diag/Runner_*.log
```

**Common Issues:**

1. **Missing labels:**
   - Verify runner has `self-hosted-macos` label
   - Re-configure if needed: `./config.sh remove && ./config.sh ...`

2. **Git not configured:**
   ```bash
   git config --global user.name "Runner Bot"
   git config --global user.email "runner@local"
   ```

3. **Node.js issues:**
   ```bash
   # actions/setup-node should handle this, but verify:
   which npm
   npm --version
   ```

### ShellCheck Not Found

**Symptoms:** Workflow fails with "shellcheck: command not found"

**Solution:**

```bash
# Install ShellCheck
brew install shellcheck

# Verify in PATH
which shellcheck
# Should show: /opt/homebrew/bin/shellcheck (ARM) or /usr/local/bin/shellcheck (Intel)
```

## Monitoring

### Health Check Script

Run the health check script to diagnose issues:

```bash
cd /path/to/CC_Agents_Commands
bash scripts/runner-health-check.sh
```

Output includes:
- Runner service status
- Disk usage
- Recent errors from logs
- Workspace size

### Manual Health Checks

#### Check Runner Status in GitHub UI

1. Go to: `https://github.com/[owner]/CC_Agents_Commands`
2. Navigate to: **Settings** → **Actions** → **Runners**
3. Verify:
   - Status: **Idle** (green) or **Active** (blue)
   - Labels: `self-hosted`, `macOS`, `ARM64`/`X64`, `self-hosted-macos`
   - Last contacted: Within last minute

#### Check Disk Space

```bash
df -h / | tail -1
```

**Healthy:** >10GB free
**Warning:** 5-10GB free (run cleanup)
**Critical:** <5GB free (immediate cleanup required)

#### Check Recent Job Success Rate

```bash
cd ~/actions-runner
# Count successful jobs in last 24 hours
grep "Job.*completed with result: Succeeded" _diag/Runner_*.log | grep "$(date +%Y-%m-%d)" | wc -l
```

#### Monitor Logs in Real-Time

```bash
tail -f ~/actions-runner/_diag/Runner_*.log
# Press Ctrl+C to stop
```

### Automated Monitoring (Advanced)

For production runners, consider:

1. **Disk space alerts:**
   ```bash
   # Add to crontab (crontab -e)
   0 */6 * * * df -h / | awk '$5 > 80% {print "Disk usage critical: " $5}' | mail -s "Runner Alert" you@example.com
   ```

2. **Runner health pings:**
   - Use [Healthchecks.io](https://healthchecks.io/docs/github_actions/) with `workflow_run` triggers

3. **Log aggregation:**
   - Forward `_diag/*.log` to centralized logging (Splunk, Datadog, etc.)

## Additional Resources

- [GitHub Actions Self-Hosted Runners Documentation](https://docs.github.com/en/actions/hosting-your-own-runners)
- [Runner Releases](https://github.com/actions/runner/releases)
- [Best Practices for Self-Hosted Runners](https://docs.github.com/en/actions/security-guides/security-hardening-for-github-actions#hardening-for-self-hosted-runners)

## Support

For issues specific to CC_Agents_Commands workflows:
- Open an issue: `https://github.com/[owner]/CC_Agents_Commands/issues`
- Review workflow file: `.github/workflows/docs-ci.yml`

For GitHub Actions runner issues:
- GitHub Community: https://github.community/c/code-to-cloud/github-actions
- Runner repository: https://github.com/actions/runner
