---
name: guardar-cambios-git
description: >
  Flujo seguro para guardar e integrar cambios en Git. Actívalo cuando el usuario
  diga "guardemos cambios", "guarda los cambios", "integremos a dev", o invoque
  /guardar-cambios. Verifica el estado, integra la rama de trabajo a dev, sincroniza
  local y remoto, y limpia ramas de trabajo SOLO tras confirmar el push. Promueve a
  main SOLO si se pide explícito. Siempre pide confirmación antes de borrar o promover.
license: Apache-2.0
metadata:
  author: gentleman-programming
  version: "1.2"
allowed-tools: Bash(git:*), Bash(docker compose:*), Bash(php artisan test:*), Bash(./vendor/bin/pest:*), Bash(npx playwright:*), Read
---

## When to Use

- El usuario quiere guardar e integrar trabajo a `dev` de forma segura.
- Cierre de una tarea: commitear, testear, integrar, sincronizar y limpiar.
- Promover `dev` a `main` (release) cuando se pide explícitamente.

## Modelo de ramas

- Permanentes: `main` (releases) y `dev` (integración). **NUNCA se borran.**
- De trabajo: ramas con prefijo Conventional Commits — `feat/*` (o `feature/*`),
  `fix/*`, `chore/*`, `docs/*`, `refactor/*`, `test/*`, `perf/*`, `style/*`, `ci/*`,
  `build/*` — nacidas de `dev`.

## Critical Patterns (reglas duras — no negociables)

- NUNCA `git push --force` (ni `--force-with-lease`) a `dev` ni a `main`.
- NUNCA borrar `main` ni `dev`.
- Borrar una rama de trabajo SOLO con `-d` (nunca `-D`) y SOLO después de confirmar
  que el `push` a `dev` fue exitoso.
- Ante CUALQUIER conflicto de merge: `git merge --abort`, DETENTE y reporta.
- Si el remoto está adelante o el push es rechazado: re-sincronizar y reintentar.
  Jamás resolver con `--force`.
- Ante cualquier ambigüedad o caso no contemplado: DETENTE y pregunta.

## Paso 0 — Diagnóstico (solo lectura)

Capturá y guardá el nombre de la rama actual ANTES de cualquier checkout:
- `git branch --show-current`  → guardá el resultado como `RAMA_ORIGEN`.
- `git status -sb`
- `git fetch --all --prune`
- Upstream: `git rev-parse --abbrev-ref --symbolic-full-name @{u}` 2>/dev/null
  - Si TIENE upstream → divergencia: `git rev-list --left-right --count @{u}...HEAD`
  - Si NO tiene upstream (rama nueva sin pushear) → no corras el `rev-list`; anotá
    "rama local sin upstream".
- Ramas sin mergear: `git branch --no-merged dev`

## Paso 1 — Reportar y validar

Resumí en pocas líneas: `RAMA_ORIGEN`, archivos sin commitear, estado del upstream
(adelante/atrás/sin upstream) y ramas pendientes (solo informativo).

- Si el remoto está ADELANTE → DETENTE y proponé `git pull --rebase`. No mergees a ciegas.
- Si `RAMA_ORIGEN` NO es `dev` ni una rama de trabajo con prefijo Conventional
  (`feat`/`feature`/`fix`/`chore`/`docs`/`refactor`/`test`/`perf`/`style`/`ci`/`build`)
  — ej: `main` o detached HEAD — → DETENTE (ver Paso 4, Caso C).

## Paso 2 — Commitear lo pendiente

Si hay cambios sin commitear: revisá `git diff`, redactá un mensaje
`tipo(scope): descripción` (feat/fix/refactor/docs/test/chore), luego `git add -A`
y `git commit`. Si decidís NO incluir algo, dejalo committeado o stasheado: el árbol
debe quedar LIMPIO antes de cualquier checkout (`git status --porcelain` vacío).

## Paso 3 — Verificación (binario, salvo diff sin código)

Mirá qué archivos cambió el branch (`git diff --name-only origin/dev...HEAD`):

- Si el diff toca **CUALQUIER archivo de código** (`.php`, `.js`, `.blade.php`, `.css`,
  etc.) y existen tests (Pest / Playwright) → corré la suite relevante. **No hay
  criterio de "esto es chiquito, no corro nada".** Si algo falla → DETENTE y reportá.
  No se integra nada en rojo.
- Si el diff es **solo documentación/config** (`.md`, archivos bajo `.claude/`, etc.,
  sin un solo archivo de código) → tests **N/A**: no verifican nada de lo que cambió.
  Anotá "diff sin código, tests omitidos" y seguí.

> Proyecto Docker-only: la suite es `docker compose exec app php artisan test`
> (no `php artisan test` en el host). Si Docker no está arriba y hay que correr tests,
> levantalo (`docker compose up -d`) antes.

## Paso 4 — Integración según `RAMA_ORIGEN`

Pre-condición para todos los casos: árbol limpio (`git status --porcelain` vacío).

**Caso A — rama de trabajo (`feat`/`feature`/`fix`/`chore`/`docs`/`refactor`/`test`/`perf`/`style`/`ci`/`build`):**
1. `git checkout dev`
2. `git pull --rebase origin dev`
3. `git merge --no-ff "$RAMA_ORIGEN"`
   - Si hay CONFLICTO → `git merge --abort`, DETENTE y reportá.
4. `git push origin dev`
   - Si el push es RECHAZADO (non-fast-forward): `git pull --rebase origin dev`,
     re-verificá (Paso 3 si aplica) y reintentá el push. Nunca `--force`.
5. **Solo si el push del paso 4 fue exitoso**, confirmá con el usuario y borrá:
   - `git branch -d "$RAMA_ORIGEN"` (con `-d`; si falla por no estar mergeada, NO fuerces)
   - `git push origin --delete "$RAMA_ORIGEN"`

**Caso B — `dev` directo (cambio pequeño):**
Ya commiteado en Paso 2 →
1. `git pull --rebase origin dev`
2. `git push origin dev` (mismo manejo de push rechazado que Caso A, paso 4).

**Caso C — `main`, detached HEAD, u otra rama:**
DETENTE. No integres. Reportá la situación y pedí instrucciones explícitas.

## Paso 5 — Promover a main (SOLO si se pide: "súbelo a main" / "release")

Confirmá con el usuario antes de empezar.
1. Asegurá `dev` sincronizado: estando en `dev`, `git pull --rebase origin dev`.
2. `git checkout main`
3. `git pull --rebase origin main`
4. `git merge --no-ff dev`
   - Si hay CONFLICTO → `git merge --abort`, DETENTE y reportá.
5. `git push origin main` (mismo manejo de push rechazado que Caso A, paso 4).
6. (Opcional, si el usuario lo pide) etiquetar release: `git tag -a vX.Y.Z -m "..."`
   y `git push origin vX.Y.Z`.
7. `git checkout dev` (volvé a dev).

## Paso 6 — Reporte final

Confirmá: rama final, qué se pusheó, qué ramas se borraron (y que el push las precedió),
y que local y remoto están sincronizados (`git status -sb`).

### Inventario de pendientes (SIEMPRE, al cierre)

Antes de dar por terminado, reportá explícitamente qué quedó **solo en local** o
**fuera de producción (`main`)**. El objetivo es que el usuario NUNCA crea que algo
está arriba cuando en realidad sigue local. Reportá:

1. **Ramas locales sin pushear** (existen en local pero no en `origin/*`): trabajo que
   solo vive en esta máquina. Si se borra el repo local, se pierde.
2. **Commits en `dev` que NO están en `main` (producción)**: trabajo integrado pero aún
   no liberado. Listalo para que el usuario decida si quiere promover (Paso 5).
3. **Ramas de trabajo sin mergear a `dev`**: cambios que ni siquiera llegaron a integración.
4. **Estado de sincronización** de cada rama permanente con su remoto (adelante/atrás).

Si TODO está pusheado y `dev`/`main` coinciden con sus remotos, decílo explícito:
"nada pendiente solo en local; producción al día". Si hay pendientes, listalos con su
hash corto y una línea de qué son.

```bash
# 1. Ramas locales sin remoto (no pusheadas)
for b in $(git for-each-ref --format='%(refname:short)' refs/heads/); do
  git rev-parse --verify --quiet "origin/$b" >/dev/null || echo "  $b (solo local, sin remoto)"
done
# 2. Commits en dev no en main (en integración, no en producción)
git log --oneline origin/main..origin/dev
# 3. Ramas de trabajo sin mergear a dev
git branch --no-merged dev
# 4. Sincronización local vs remoto de dev y main
git rev-list --left-right --count origin/dev...dev
git rev-list --left-right --count origin/main...main
```

## Commands

```bash
git branch --show-current
git status -sb
git fetch --all --prune
git rev-parse --abbrev-ref --symbolic-full-name @{u}
git rev-list --left-right --count @{u}...HEAD
git branch --no-merged dev
git merge --no-ff "$RAMA_ORIGEN"
git merge --abort
git branch -d "$RAMA_ORIGEN"
git push origin --delete "$RAMA_ORIGEN"
# Inventario de pendientes (Paso 6)
git for-each-ref --format='%(refname:short)' refs/heads/
git log --oneline origin/main..origin/dev
git rev-list --left-right --count origin/dev...dev
```
