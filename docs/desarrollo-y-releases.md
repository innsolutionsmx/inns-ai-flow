# Desarrollo del plugin y releases

## El principio

`main` es lo que consumen TODOS los proyectos — cada merge a `main` con bump de
versión es una **release**, y las releases se deciden, no se acumulan. El desarrollo
vive en `dev`.

```
rama de trabajo (feat/*, fix/*, docs/*)
        │  merge (via guardar-cambios-git)
        ▼
       dev          ← acá se integra y se prueba
        │  SOLO por decisión explícita del owner:
        │  bump de versión + merge
        ▼
       main         ← lo que reciben los proyectos (release)
```

## Dogfood: este repo usa su propio plugin

`.claude/settings.json` del repo instala inns-ai-flow desde el marketplace publicado
(la versión de `main` te protege mientras desarrollás la siguiente — self-hosting).
En la práctica: `git-guard` te bloquea editar en `main`/`dev` también acá, y el flujo
de ramas lo llevan las mismas skills que estás modificando.

## Cómo agregar o mejorar una pieza

1. **Rama** desde `dev` (la skill `iniciar-trabajo-git` lo hace bien parada).
2. El cambio:
   - **Skill nueva**: carpeta `skills/<nombre>/SKILL.md` con frontmatter
     (`name`, `description` — la description ES el trigger de auto-invocación).
   - **Hook nuevo**: script en `hooks/` (con `chmod +x`) + entrada en
     `hooks/hooks.json` referenciándolo como `"${CLAUDE_PLUGIN_ROOT}"/hooks/x.sh`.
     Regla de reparto: lo determinístico va en hooks, el juicio en skills.
   - **Cambio al bootstrap/template**: `commands/bootstrap.md` y
     `templates/CLAUDE.template.md`.
3. Actualizar `docs/referencia.md` (y `casos-de-uso.md` si aplica).
4. Cerrar con `guardar-cambios-git` → integra a `dev`.
5. Actualizar `ai/context/progreso-actual.md` (lo pide el propio workflow).

## Cómo se hace una release

Cuando el owner decide que lo que hay en `dev` sale:

1. **Bump de versión** en `.claude-plugin/plugin.json` (semver: fix = patch,
   feature = minor, cambio incompatible = major). Sin bump NO hay distribución —
   el cache de plugins es por versión y el mismo string no se re-descarga.
2. Merge `dev` → `main` y push.
3. Listo: los proyectos con `autoUpdate: true` la reciben en su próxima sesión.

**Qué NO requiere bump**: cambios que no viajan al consumidor — `docs/`, `SETUP.md`,
`README.md`, `.claude/settings.json` del repo, `ai/context/`. Se sirven raw desde
`main` o son locales del repo. (Sí requiere bump: `skills/`, `hooks/`, `commands/`,
`templates/`, `plugin.json`.)

## Reglas de proceso

- Nunca commitear directo en `main` ni `dev` (el propio git-guard lo bloquea).
- Cambios relacionados se agrupan en UNA propuesta/rama, no en ráfagas de commits.
- Antes de cambios de fondo: plan corto → OK del owner → ejecutar.
- Todo gotcha descubierto usando el plugin en un proyecto real vuelve acá como
  mejora (issue, handoff o rama) — así evoluciona el workflow.
