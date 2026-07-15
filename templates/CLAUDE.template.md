# {{nombre-proyecto}} — Claude Instructions

{{Una línea: qué ES este proyecto y para quién. Ej: "Sistema de punto de venta
multi-sucursal para X (producto en producción)" / "Landing corporativa de Y".}}

{{Solo si existen: punteros a ai/prd/, ai/runbooks/, runbook de deploy, docs clave.
Formato lista, una línea por puntero.}}

## Flujo de trabajo (LEER PRIMERO)

Gitflow, guardias y protocolo de sesión los provee el plugin **`inns-ai-flow`** —
sus skills (`iniciar-trabajo-git`, `guardar-cambios-git`, `briefing`) y hooks
(`git-guard`, `git-session-status`, `progreso-status`) son la fuente de verdad.
No dupliques sus reglas en este archivo.

{{Solo si el proyecto tiene flujo propio ADICIONAL (ej. crear-proyecto → setup.sh →
setup-proyecto en el boilerplate): resumilo en 2-3 líneas + puntero al doc completo.}}

## Stack

| Capa | Tecnología |
|------|------------|
{{detectado del repo — backend, frontend, DB, runtime}}

## Comandos

{{Nota de runtime si aplica (ej: "Runtime Docker — los comandos corren DENTRO del
container `app`").}}

| Acción | Comando |
|--------|---------|
{{comandos REALES del proyecto: levantar entorno, tests, migraciones, build, lint}}

{{Blockquote de setup inicial + puntero a la guía de arranque/onboarding si existe.}}

## Arquitectura Backend

{{Patrón de capas + reglas duras (qué NO se usa) + puntero a ai/context/arquitectura.md.}}

{{## Secciones específicas del proyecto — Idempotencia, Sidebar/Nav-items, etc.
Solo si aplican; acá vive el conocimiento que hace único a este proyecto.}}

## Design System

{{Regla de tokens (qué está PROHIBIDO) + puntero a ai/context/design-system.md.}}

## Skills del Proyecto

Las skills de workflow (gitflow, briefing, seo-frontend) vienen del plugin
`inns-ai-flow` y NO van en esta tabla. Acá van SOLO las skills propias del proyecto
en `.claude/skills/`:

| Skill | Se activa con |
|-------|--------------|
{{solo skills locales — ej. ux-polish, playwright-auto-qa, landing-porting}}

## Contexto del Proyecto

Todos los archivos de contexto están en `{{ai|ia}}/context/`:

| Archivo | Qué cubre |
|---------|-----------|
{{índice real de la carpeta, incluida progreso-actual.md}}

## Convenciones Generales

{{Bullets propios del proyecto: naming de vistas/componentes/JS, iconos, idioma del
copy, etc. Commits Conventional y "una rama por cambio" NO van acá — son del plugin.}}
