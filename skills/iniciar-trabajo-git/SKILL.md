---
name: iniciar-trabajo-git
description: >
  Arranque seguro del gitflow ANTES de tocar código. Actívalo al iniciar una tarea,
  cuando el usuario diga "arranquemos", "empecemos el cambio", "nueva rama", o invoque
  /iniciar-trabajo-git, y SIEMPRE que estés en `main` o `dev` y vayas a modificar
  archivos. Te para en `dev` actualizado y crea la rama de trabajo con el prefijo
  Conventional correcto. Es la contraparte de apertura de `guardar-cambios-git` (cierre).
license: Apache-2.0
metadata:
  author: gentleman-programming
  version: "1.0"
---

## When to Use

- Al EMPEZAR cualquier cambio, antes de editar la primera línea.
- Cuando un hook (`PreToolUse`) te bloqueó por estar en `main` o `dev`.
- Cuando el usuario pide arrancar una tarea, feature o fix nuevo.

> Este es el ARRANQUE del flujo. El CIERRE (commitear, integrar a `dev`, sincronizar,
> limpiar ramas, promover a `main`) lo maneja la skill `guardar-cambios-git`.
> Referencia humana completa: `docs/git-flow.md`.

## Modelo de ramas

- Permanentes: `main` (releases) y `dev` (integración). **NUNCA se trabaja directo en ellas.**
- De trabajo: nacen SIEMPRE de `dev` con prefijo Conventional:
  `feat/*` · `fix/*` · `chore/*` · `docs/*` · `refactor/*` · `test/*` · `perf/*` · `style/*` · `ci/*` · `build/*`.

## Critical Patterns (reglas duras)

- NUNCA modificar código estando en `main` ni en `dev`. Siempre rama de trabajo.
- La rama SIEMPRE nace de `dev` actualizado (pull primero), nunca de `main` ni de otra rama de trabajo.
- El nombre va en `kebab-case`, en inglés, sin nombre de persona: `feat/theme-editor`, no `rodrigo/cambio` ni `feat/Cambio_Grande`.
- El tipo (`feat`/`fix`/...) lo elegís según la NATURALEZA del cambio, no al azar.
- Ante cualquier ambigüedad (rama actual rara, detached HEAD, árbol sucio): DETENTE y preguntá.

## Paso 0 — Diagnóstico (solo lectura)

```bash
git branch --show-current   # rama actual
git status -sb              # estado del árbol + upstream
git fetch --all --prune
```

- Si el árbol está SUCIO (cambios sin commitear) que NO son del cambio nuevo → DETENTE.
  Puede que ese trabajo pertenezca a otra rama. Preguntá antes de arrastrarlo.

## Paso 1 — Elegir el tipo y el nombre de la rama

Mapeá el cambio al prefijo:

| Tipo | Cuándo |
|------|--------|
| `feat` | nueva funcionalidad |
| `fix` | corrección de bug |
| `chore` | mantenimiento, deps, config |
| `docs` | solo documentación |
| `refactor` | refactor sin cambio de comportamiento |
| `test` | tests |
| `style` | formato sin lógica |

Nombre: `{tipo}/{descripcion-corta-en-kebab-case}`.

## Paso 2 — Sincronizar dev y crear la rama

```bash
git checkout dev
git pull origin dev
git checkout -b {tipo}/{nombre}
```

- Si `git pull origin dev` reporta conflicto o el remoto diverge → DETENTE y reportá.
  No fuerces nada.

## Paso 3 — Confirmar y arrancar

Reportá en una línea: rama creada y de qué base sale. Recién ahí empezás a editar.

> Si ya estabas en una rama de trabajo correcta (`feat/*`, `fix/*`, etc.) y el cambio
> pertenece a esa rama → NO crees una nueva. Seguí en ella.

## Commands

```bash
git branch --show-current
git status -sb
git fetch --all --prune
git checkout dev
git pull origin dev
git checkout -b feat/nombre-del-cambio
```

## Resources

- **Documentación**: ver `docs/git-flow.md` (guía completa del gitflow del equipo).
- **Cierre del flujo**: skill `guardar-cambios-git`.
