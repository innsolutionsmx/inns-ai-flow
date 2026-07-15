# inns-ai-flow

> **¿Sos un agente / LLM leyendo esto?** Si un humano te pidió instalar o integrar este
> plugin en su proyecto, no improvises: leé y ejecutá las instrucciones de
> [`SETUP.md`](./SETUP.md) (versión raw:
> `https://raw.githubusercontent.com/innsolutionsmx/inns-ai-flow/main/SETUP.md`).

Workflow de la casa Innsolutions como plugin de Claude Code. Centraliza las skills y
hooks que antes vivían copiados (y divergían) en cada proyecto: una mejora acá, un bump
de versión, y TODOS los proyectos la reciben.

## Qué trae

### Skills

| Skill | Qué hace | Se activa con |
|-------|----------|---------------|
| `iniciar-trabajo-git` | Te para en `dev` actualizado y crea la rama `{tipo}/{nombre}` con prefijo Conventional antes de tocar código | Arranque de una tarea, "nueva rama", o al estar en `main`/`dev` por editar |
| `guardar-cambios-git` | Cierre de tarea: commitea, corre tests, integra a `dev`, sincroniza, limpia ramas e inventaría pendientes (qué quedó solo en local vs producción) | Cierre de una tarea / "guardá los cambios" |
| `briefing` | Cierre de batch: qué se hizo y por qué, checklist de QA manual, handoff copiable + memoria | Tras push a `dev` (ofrecido automático por hook) o a pedido |
| `seo-frontend` | Meta tags, Open Graph, JSON-LD, canonical, sitemap, Core Web Vitals, accesibilidad | Trabajo en vistas públicas / SEO |

### Hooks (se cablean solos — cero config en el proyecto)

| Hook | Evento | Qué hace |
|------|--------|----------|
| `git-guard.sh` | PreToolUse (Edit/Write) | **Bloquea** ediciones si estás parado en `main` o `dev` — te obliga a abrir rama |
| `git-session-status.sh` | SessionStart | Reporta rama actual, avisos de rama protegida y árbol sucio al abrir sesión |
| `progreso-status.sh` | SessionStart | Inyecta la "Última actualización" de `progreso-actual.md` — el agente arranca sabiendo dónde quedó el trabajo, sin depender de prosa en CLAUDE.md |
| `briefing-detect.sh` | PostToolUse (Bash) | Detecta push a `dev` y ofrece el briefing de cierre |

### Comando

- `/inns-ai-flow:bootstrap` — deja un proyecto nuevo con la convención completa:
  carpeta `ai/context/` (con `progreso-actual.md`, el source of truth entre sesiones y
  máquinas), CLAUDE.md indexado, y `.claude/settings.json` declarativo (merge seguro).
  En proyectos con `ia/` existente, la respeta.

## Instalación

### Setup automático (recomendado — para agentes)

Pegale esto a Claude Code dentro del proyecto:

```
Lee https://raw.githubusercontent.com/innsolutionsmx/inns-ai-flow/main/SETUP.md
y ejecuta el setup en este proyecto.
```

### Manual

```
/plugin marketplace add innsolutionsmx/inns-ai-flow
/plugin install inns-ai-flow
```

Después: `/inns-ai-flow:bootstrap` si el proyecto todavía no tiene la convención.

## Actualizar el workflow (para el equipo)

1. Mejorá la skill o el hook **en este repo** (nunca en la copia de un proyecto —
   las copias por proyecto son legacy y se van eliminando).
2. Subí la versión en `.claude-plugin/plugin.json` (el cache de plugins es por versión —
   sin bump, los proyectos pueden quedarse con la copia vieja).
3. Commit + push a `main`. Los proyectos reciben el update al refrescar el marketplace.

## Relación con design-forge

- **inns-ai-flow** = CÓMO trabaja el equipo (gitflow, guardias, briefings, convención `ai/`).
- **[design-forge](https://github.com/innsolutionsmx/design-forge)** = QUÉ se construye
  y cómo se juzga (pipeline de diseño frontend).

Son independientes; un proyecto puede tener uno, el otro, o ambos.
