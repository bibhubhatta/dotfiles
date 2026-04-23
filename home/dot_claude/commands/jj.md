---
description: Jujutsu (jj) command reference plus the rule that auto-generated code must land in its own commit
---

# Version Control (Jujutsu)

Use **Jujutsu (`jj`)** for all version control operations — not `git`. Repos are colocated (`.git/` still present), so remotes and CI continue to work, but author commands go through `jj`.

**Core command mapping** (jj ↔ git):

- `jj st` / `jj log` — status / history (prefer `jj log` over `git log`)
- `jj diff` — show diff of the current change (working copy is auto-snapshotted; no staging)
- `jj describe -m "msg"` — set or update the message on the current change (equivalent to writing a commit message)
- `jj new` — start a new empty change on top (equivalent to "commit + start next work")
- `jj commit -m "msg"` — shortcut for `describe` + `new`
- `jj squash` / `jj split` — combine or split changes (replaces `git rebase -i` for the common cases)
- `jj bookmark set <name> -r @-` — move a bookmark (jj's term for branch) to the just-finalized change
- `jj git push` — push bookmarks to the git remote
- `jj git fetch` — fetch from the git remote

**Key behavioral differences to keep in mind:**

- There is **no staging area**. Edits are snapshotted into the current change (`@`) on every `jj` invocation. Don't look for `git add`.
- The current change is always mutable until you move off it with `jj new`. Amending is the default, not a special flag.
- Branches are called **bookmarks** and do not auto-advance; move them explicitly with `jj bookmark set`.
- Never run `git commit`, `git add`, `git rebase`, or `git reset` in a jj-managed repo — use the `jj` equivalents instead. Read-only git commands (`git log`, `git status`, `git diff`) are fine if needed for debugging.

**Destructive operations** (`jj abandon`, `jj op restore`, `jj bookmark delete`, force pushes) still require user confirmation per the normal safety rules.

## Auto-Generated Code in Commits

Any code produced by a generator (OpenAPI/Swagger clients, Prisma or other ORM client output, gRPC/Protobuf stubs, GraphQL codegen, generated types, snapshot fixtures, large lockfile regenerations, formatter or codemod sweeps) must land in its **own commit**, separate from any hand-written changes.

- **Why:** reviewers should be able to tell at a glance that a diff is the mechanical output of a tool, not work authored by hand. Mixing the two hides what the human actually changed and bloats review.
- **How to apply:**
  - Commit the hand-written change first (e.g. the updated API schema, the edited `.proto` file, the new endpoint).
  - Then run the generator and commit the generated output as a separate, follow-up change.
  - In the generation commit's message, say it is auto-generated and name the tool/command (e.g. `regenerate openapi client (pnpm gen:api)` or `regenerate prisma client`).
  - Never squash a generation commit into a hand-written one, or vice-versa — keep them distinct in history even after rebases.
  - In `jj`: `jj commit -m "..."` for the source change → run the generator → `jj commit -m "regenerate ..."` for the output. If you accidentally snapshot both into the same change, use `jj split` to separate them before finalizing.

This rule applies even for tiny generated diffs — clarity of provenance matters more than commit count.
