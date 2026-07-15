# Progreso actual — inns-ai-flow

> Source of truth de "dónde quedamos" en el desarrollo del plugin. Leelo primero al
> abrir sesión, actualizalo al cerrar cada batch. Sincroniza máquinas y compañeros
> vía git (engram es local de cada máquina y no viaja).

---

## Última actualización

- **Fecha**: 2026-07-15
- **Máquina**: Mac (oficina)
- **Rama actual**: `dev`
- **Última acción**: **RELEASE v0.4.0 a `main`** (aprobada por Pepe): dogfood
  (self-install + rama dev), hook progreso-status, regla de ownership de CLAUDE.md,
  template canónico, sweep de referencias legacy en SETUP, docs/ completos y
  autoUpdate en settings/ejemplos. Los proyectos con autoUpdate la reciben en su
  próxima sesión.

---

## Estado del plugin

- **Publicado en `main`**: v0.3.0 — skills gitflow (iniciar/guardar/briefing/seo),
  hooks (git-guard, git-session-status, briefing-detect, progreso-status), bootstrap
  con template CLAUDE.md canónico, SETUP.md con sweep de referencias legacy.
- **Proceso de release**: cambios en rama → merge a `dev` → promoción a `main` + bump
  de versión SOLO por decisión explícita de Pepe (main = lo que consumen los proyectos).

## Próximos pasos

- [ ] Migración de `base-project` (el boilerplate — la de mayor palanca): presentar
  plan detallado antes de ejecutar. Después los 6 proyectos restantes.
- [ ] Decidir si `main` lleva branch protection en GitHub además del guard local.
- [ ] Futuro plugin `inns-laravel` con las skills de stack (crear-proyecto,
  setup-proyecto, arrancar-desarrollo, landing-porting).
