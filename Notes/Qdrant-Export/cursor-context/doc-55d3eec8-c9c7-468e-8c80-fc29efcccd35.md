---
collection: cursor-context
exported_at: '2026-01-11T22:30:22.009630'
id: 55d3eec8-c9c7-468e-8c80-fc29efcccd35
title: doc-55d3eec8-c9c7-468e-8c80-fc29efcccd35
---

Best practices for Git commit messages:
1) Use the Conventional Commits spec for consistent structure: <type>(optional scope): <short summary>. Common types: feat, fix, refactor, docs, test, chore, perf, style, ci, build, revert.
2) Write subject line in English, in the imperative mood, max ~50 chars: e.g. "feat(cart): add HelloAsso OAuth service".
3) Separate subject from body with a blank line.
4) In the body, explain what and why (context, rationale), not just how; wrap lines at ~72 chars.
5) Reference issues and tickets when relevant (e.g. "Refs #123", "Fixes #123").
6) Make commits small and focused: one logical change per commit.
7) Avoid noisy or unhelpful messages like "wip", "fix stuff", "update"; make the message understandable in isolation.
8) Use consistent tense and style across the repo (match existing history if it conflicts with general rules).
9) For breaking changes, use a clear marker, e.g. "feat!: change payment API" or add a "BREAKING CHANGE:" section in the body.
10) Squash trivial fixup commits before merging to keep history clean.