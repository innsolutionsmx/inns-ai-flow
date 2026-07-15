---
description: "Deja el proyecto actual con la convención AI de la casa: CLAUDE.md indexado + carpeta ai/context + settings declarativo"
---

You are bootstrapping the Innsolutions AI convention in the current project. The
inns-ai-flow plugin already ships the skills and hooks — your job is to create the
PROJECT-SIDE pieces a plugin cannot inject. Everything here is MERGE-based: never
overwrite existing content.

## Steps

1. **Respect the project's git rules.** If a CLAUDE.md with a git workflow exists,
   follow it. Default: work on a branch `chore/ai-flow-bootstrap`, never on `main`/`dev`.

2. **Context folder.** Detect an existing AI-context folder (`ai/` or `ia/`). If one
   exists, use it as-is — do NOT rename it. If none exists, create the canonical
   skeleton:
   ```
   ai/context/
   ├── progreso-actual.md   ← source of truth de "dónde quedamos" (plantilla abajo)
   ├── arquitectura.md      ← patrón de capas y decisiones estructurales
   ├── design-system.md     ← tokens y patrones visuales (si aplica)
   └── frontend.md          ← stack y estructura de vistas (si aplica)
   ```
   Fill each file with what you can DETECT from the codebase (stack, structure,
   conventions) — mark unknowns as `TODO` rather than inventing.

3. **progreso-actual.md template** (only if it doesn't exist):
   - Header explaining it's the single source of truth read FIRST each session and
     updated at every session close (this syncs work across machines and teammates,
     since local memory like engram does not travel with the repo).
   - Sections: Última actualización (fecha/máquina/rama/última acción), Estado del
     proyecto (en progreso / completado), Próximos pasos.

4. **CLAUDE.md.** If it exists: add only what's missing (a "Skills del Proyecto"
   note pointing to the plugin, the context-folder index, the session rules). If it
   doesn't exist, create it with:
   - Stack table (detected from the repo).
   - Note that gitflow skills and hooks come from the `inns-ai-flow` plugin (do NOT
     duplicate their rules in CLAUDE.md — the plugin versions are the source of truth).
   - Index table of the context folder files.
   - Session rules: read `progreso-actual.md` first; update it + save session summary
     at close; the `briefing` skill offer fires automatically after a push to `dev`.

5. **Settings.** Merge into `.claude/settings.json` (create if missing, PRESERVE all
   existing keys — hooks, permissions, other plugins):
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
   Note: the plugin's hooks wire themselves via its own hooks.json — do NOT add hook
   entries to the project settings for git-guard/git-session-status/briefing-detect.
   If the project has LEGACY copies of these hooks/skills in `.claude/`, list them and
   ask the user whether to remove them now (they duplicate what the plugin provides —
   two copies means the divergence problem returns).

6. **Commit** on the branch from step 1, conventional message
   (`chore(tooling): bootstrap inns-ai-flow convention`). Push only if the project's
   workflow allows agent pushes.

7. **Report**: what was created vs already present, legacy duplicates found, and the
   human steps: restart Claude Code → Trust → the gitflow skills and hooks are live.
