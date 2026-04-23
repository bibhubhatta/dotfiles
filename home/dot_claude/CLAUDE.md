# Global Instructions

## Handling Ambiguity

Always ask the user for confirmation or clarification whenever there is any ambiguity in a request. **Never assume.** This applies to scope, intent, target files, naming, behavior, edge cases, tooling choices, and anything else that could reasonably be interpreted more than one way.

When asking, do not just punt the decision back to the user — think first and share your analysis:

- Lay out the choices you see (typically 2–4 options).
- Explain the trade-offs of each (cost, risk, complexity, blast radius, reversibility).
- State your recommendation and why.
- Then ask which the user prefers.

A good clarifying question reads like a mini design memo, not a "what do you want?" prompt. The goal is to give the user enough context to decide quickly — not to make them re-derive the problem.

Only skip the question when the request is genuinely unambiguous, or when the user has explicitly authorized autonomous execution for the specific scope at hand.

## Linear-First Workflow

When the user gives any new instruction regarding a **bug** or **feature**, follow this workflow before writing any code:

### Step 1: Identify the Linear Project

Determine which Linear project the task belongs to based on context (repo, directory, or user clarification). The workspace is **Isha-construction** (team key: `ISH`). Known projects:

- **Field Management** — field management mobile/web app
- **Material Management** — material tracking and management
- **Labor Management** — calendar-based labor scheduling
- **Project Management** — construction project management
- **Invoice** — invoicing features
- **DevOps** — CI/CD, infrastructure, tooling
- **AI Stuff** — AI/ML features
- **Vendor Docs** — vendor documentation management

If the project is ambiguous, ask the user which project this belongs to.

### Step 2: Search Linear for Existing Issues

Search for existing issues in the identified project that match or overlap with the user's request. Use `list_issues` with a relevant query scoped to the project. Check both open and in-progress issues.

- If a **matching issue exists**: inform the user, link to it, and use that issue for tracking.
- If **no matching issue exists**: create a new issue in the correct project (Step 3).

### Step 3: Create a Linear Issue (if needed)

Create a new issue with:

- A clear, concise title
- Assign it to the correct project
- Set appropriate labels if obvious (bug vs feature)

### Step 4: Plan the Implementation

Before writing any code, create a detailed implementation plan:

1. Analyze the codebase to understand the relevant architecture
2. Identify all files that need to change
3. Consider edge cases, error handling, and testing needs
4. Write the plan as a structured description

Save this detailed plan as the **issue description** in Linear so it serves as documentation.

### Step 5: Confirm and Execute

Present the plan to the user for confirmation. Once approved, begin implementation.

**Finalize a change as soon as each task is done** — do not wait until the end or until asked. Keep changes atomic: describe the current change with `jj describe -m "..."` and start the next task with `jj new`. Squash small related changes with `jj squash` when it makes sense.

### Step 6: Update the Linear Issue on Completion

When implementation is complete, update the Linear issue with a comment containing:

- **Implementation summary**: what was changed and where (files, approach)
- **Notable details**: anything worth calling out (edge cases handled, trade-offs, gotchas)
- **Tests run**: which automated tests were executed and their results
- **Manual QA instructions**: step-by-step verification as a markdown checklist (`- [ ]`) so items are tickable in Linear

## Commit Message Rules

- Do NOT include Linear issue numbers in commit message headers/titles.

## Version Control

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

## Package Managers

- **Python**: Always use `uv` (not pip, pipx, or poetry).
- **Node.js**: Always use `pnpm` (not npm or yarn).

## Dev Servers

Before starting a local dev server (`pnpm dev`, `npm run dev`, `vite`, `next dev`, etc.), always check whether one is already running. A dev server is often already up in another terminal or a previous background shell.

**How to check** (run in parallel):

1. `ss -tlnp | grep -E ':(3000|3001|5173|5174|8080|8000|4000|4173)'` — look for common dev ports in use.
2. Inspect the project's `package.json` `scripts.dev` to identify the specific port, then check that port directly if it's not in the common list.
3. If a port is bound, `curl -sS -o /dev/null -w '%{http_code}' http://localhost:<port>` to confirm the server is responsive.

Only start a new dev server if no existing instance is responding on the expected port. If one is already running, tell the user the URL and skip starting a new one.
