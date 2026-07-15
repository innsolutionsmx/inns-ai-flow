# Cómo se instala y cómo se actualiza

## Instalación

**Vía agente (recomendado)** — pegale a Claude Code dentro del proyecto:

```
Lee https://raw.githubusercontent.com/innsolutionsmx/inns-ai-flow/main/SETUP.md
y ejecuta el setup en este proyecto.
```

**Manual**:

```
/plugin marketplace add innsolutionsmx/inns-ai-flow
/plugin install inns-ai-flow@inns-ai-flow
```

**Por settings del repo** (lo que deja el SETUP/bootstrap): `.claude/settings.json`
declara el marketplace + `enabledPlugins`; cada persona que clona y acepta **Trust**
recibe el plugin. *Fallback conocido*: en algunas versiones de Claude Code el prompt
de instalación no aparece en el primer open — usar la vía manual de arriba una vez.

## Actualización — automática por diseño

Con `autoUpdate: true` en la entrada del marketplace (los settings que genera este
plugin ya lo traen), el ciclo es:

1. Se publica una release (bump de versión + merge a `main` en este repo).
2. Claude Code revisa los marketplaces **después de arrancar cada sesión** (delay
   aleatorio de hasta 10 min).
3. Si hay versión nueva: te notifica para correr `/reload-plugins`, o la carga
   directamente en la próxima sesión.

**Nadie tiene que pedir la actualización.** No hay que decirle a Claude "revisá el
plugin" — llega sola.

Detalles del mecanismo que conviene saber:

- **La sesión corriendo no cambia de versión** — los updates aplican al recargar o en
  la próxima sesión. Es intencional: el workflow no muta a mitad de una tarea.
- **La versión es el gatillo**: mismo string de versión en `plugin.json` = no hay
  update aunque `main` haya cambiado. Por eso toda release lleva bump (y por eso los
  pushes a `main` sin bump no distribuyen nada).
- **Cache por versión**: cada versión instalada vive en
  `~/.claude/plugins/cache/inns-ai-flow/inns-ai-flow/<version>/`; las viejas se
  limpian solas a los 7 días.
- Los marketplaces de terceros traen auto-update **apagado por defecto** — por eso
  nuestros settings lo declaran explícito.

## Actualización manual (si no querés esperar)

```
/plugin marketplace update inns-ai-flow
```

y recargá la sesión (o `/reload-plugins` si la notificación lo ofrece).

## Verificar qué versión tenés

`/plugin` → pestaña de plugins instalados muestra la versión activa. La última
publicada es el `version` de `.claude-plugin/plugin.json` en la rama `main` de este
repo.
