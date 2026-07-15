# inns-ai-flow — Setup para agentes

> **Humano**: pegale esto a tu agente (Claude Code) dentro del proyecto:
>
> ```
> Lee https://raw.githubusercontent.com/innsolutionsmx/inns-ai-flow/main/SETUP.md
> y ejecuta el setup en este proyecto.
> ```

---

**Agent instructions.** You are installing the Innsolutions workflow plugin in the
current project. Follow these steps exactly; do not improvise extra installs.

## 1. Respect the project's rules first

If the project has a `CLAUDE.md` with a git workflow (protected branches, branch
naming), follow it. Default: create a branch `chore/inns-ai-flow-setup` — never
commit directly to `main` or `dev`.

## 2. Configure `.claude/settings.json` — MERGE, never overwrite

The project may already have `settings.json` with `hooks`, `permissions`, or other
plugins. **Read the existing file first** and merge these keys into it, preserving
everything else:

```json
{
  "extraKnownMarketplaces": {
    "inns-ai-flow": {
      "source": { "source": "github", "repo": "innsolutionsmx/inns-ai-flow" }
    }
  },
  "enabledPlugins": {
    "inns-ai-flow@inns-ai-flow": true
  }
}
```

## 3. Remove legacy duplicates (CRITICAL — hooks run twice otherwise)

Plugin hooks and project hooks BOTH execute (they merge, they don't override). Check
the project for legacy copies of what this plugin now provides and, if found, list
them and ask the human to confirm removal:

- `.claude/hooks/git-guard.sh`, `.claude/hooks/git-session-status.sh`,
  `.claude/hooks/briefing-detect.sh` **and their entries in `settings.json` "hooks"**
  (SessionStart / PreToolUse Edit|Write|MultiEdit|NotebookEdit / PostToolUse Bash).
- `.claude/skills/iniciar-trabajo-git`, `.claude/skills/guardar-cambios-git`,
  `.claude/skills/briefing`, `.claude/skills/seo-frontend`.

Keep any OTHER project hooks/skills untouched (e.g. project-specific ones like
`ux-polish`, `playwright-auto-qa`, `detect-ui-change.js`).

## 4. Bootstrap the convention (only if missing)

If the project has no `ai/` or `ia/` context folder or no CLAUDE.md, tell the human
that after restarting they should run `/inns-ai-flow:bootstrap`, which creates the
full convention (context folder + `progreso-actual.md` + CLAUDE.md index). Do not
hand-build those files yourself in this setup — the bootstrap command owns that.

## 5. Commit

Commit on the branch from step 1, conventional message
(`chore(tooling): install inns-ai-flow plugin via settings.json`). Push only if the
project workflow says agents push; otherwise leave local and say so.

## 6. Hand back to the human

1. Reiniciá Claude Code en este proyecto.
2. Aceptá el diálogo de **Trust** — ahí se instala el marketplace y el plugin.
3. Los hooks quedan activos solos (git-guard, git-session-status, briefing-detect)
   y las skills de gitflow disponibles.
4. Si el proyecto no tiene la convención `ai/` + CLAUDE.md: `/inns-ai-flow:bootstrap`.

## Notes

- The GitHub repo above must be reachable (it is public). Marketplace errors appear
  in `/plugin` → Errors.
- This file is fetched from `main`; reference it by URL, never copy it into projects.
- Design pipeline (design-forge) is a SEPARATE plugin — install it only if the
  project does frontend design work: https://github.com/innsolutionsmx/design-forge
