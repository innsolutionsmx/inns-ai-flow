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

4. **CLAUDE.md — ownership rule.** CLAUDE.md contains ONLY what is specific to THIS
   project. The house convention lives in the plugin and must never be duplicated
   in CLAUDE.md (duplicated prose diverges — that's the disease this plugin cures).

   Stays in CLAUDE.md (project-owned):
   - Stack table, backend/frontend architecture, design system pointers.
   - Index table of the context folder files.
   - Project-specific conventions (naming, icons, client rules like copy language).
   - One short line: "Gitflow, guardias y protocolo de sesión los provee el plugin
     `inns-ai-flow` — sus skills y hooks son la fuente de verdad."

   Owned by the plugin (must NOT appear in CLAUDE.md):
   - Gitflow rules and branch workflow (they live in the `iniciar-trabajo-git` /
     `guardar-cambios-git` skills; `git-guard` enforces the blocking).
   - Skills tables describing plugin skills.
   - "Read progreso-actual.md first" session rules — the `progreso-status` SessionStart
     hook now injects that state automatically; prose is redundant.
   - Session close protocol (lives in `briefing` / `guardar-cambios-git`).

   If CLAUDE.md **doesn't exist**: create it with only the project-owned sections.
   If it **exists**: identify convention sections that the plugin now owns, show the
   user the list, and ask confirmation to REMOVE them (keeping anything with
   project-specific customizations — when a section mixes both, keep only the
   project-specific lines).

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
