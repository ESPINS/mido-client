---
name: claude-init
description: Load all pipeline and skill configurations for mido-client development session. Invoke manually if session initialization did not complete automatically.
disable-model-invocation: true
---

Load the following files using the Read tool in order:

1. `.claude/pipeline.yaml`
2. `.claude/skills/dev-agent/SKILL.md`
3. `.claude/skills/test-agent/SKILL.md`
4. `.claude/skills/quality-agent/SKILL.md`
5. `.claude/skills/security-agent/SKILL.md`

After reading all files, output "Claude configuration loaded" and switch to standby state without further explanation.
Output "Claude configuration load failed" if any file read fails.
