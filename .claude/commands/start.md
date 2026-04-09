# /start

Run this at the beginning of every session before doing anything else.

## Steps

1. Read @docs/PROJECT.md — current phase, what's completed, what's next
2. Read @lessons.md — load all rules learned from past mistakes
3. Read @CLAUDE.md — confirm hard rules and stack
4. Check git status: `git branch --show-current` and `git status --short`
5. Verify build: `xcodebuild -scheme Nova -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build 2>&1 | tail -5`
6. Report back:
   - Current phase and what has been completed
   - What the next task is
   - Any blockers (build errors, missing dependencies)
   - Current branch and any uncommitted changes
7. Ask: "Ready to continue with [next task]? Or is there something specific you want to work on?"

Do not write any code until the user confirms what to work on.

---

## Context management during this session

Context window degradation is the primary failure mode in long sessions. Follow these rules:

- **At ~50% context used:** run `/compact` before continuing. It summarises the conversation while preserving CLAUDE.md instructions.
- **When switching to a completely different task mid-session:** run `/clear` — a clean context is better than a compacted one for unrelated work.
- **Never `/compact` immediately before starting a large new feature** — use `/clear` instead.
- **If you notice yourself losing track of earlier decisions or repeating work:** run `/compact` immediately.
- **After `/compact`:** re-read @docs/PROJECT.md to restore task context before continuing.

The SessionStart hook already injects your current git branch into context automatically at the start of each session.
