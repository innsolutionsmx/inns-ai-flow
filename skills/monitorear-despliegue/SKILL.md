---
name: monitorear-despliegue
description: >
  Sigue el CI tras un push a `main` y prueba contra el sitio o servicio vivo que el
  commit liberado es el que se está sirviendo. Agnóstico de stack: detecta el CI, el
  mecanismo de deploy y el tipo de build en vez de asumirlos. Actívalo después de
  promover a `main` (lo invoca `guardar-cambios-git`, Paso 5.1), cuando el usuario diga
  "monitorear despliegue", "seguir el deploy", "¿ya subió a producción?", "¿está bien
  producción?", "verificar el release", o invoque /monitorear-despliegue.
  Cierra con un veredicto: verificado / fallido / no verificable, con evidencia.
license: Apache-2.0
metadata:
  author: gentleman-programming
  version: "1.0"
allowed-tools: Bash(gh:*), Bash(glab:*), Bash(git:*), Bash(curl:*), Bash(grep:*), Bash(jq:*), Read
---

## When to Use

- Inmediatamente después de un push a `main` (release).
- El usuario pregunta si un cambio ya está en producción o si producción está sana.
- Un deploy falló y hay que reportar en qué job y en qué fase murió.

## Principio

**Un CI verde NO es un deploy verificado.** Un job de deploy verde prueba, como mucho,
que la plataforma aceptó el artefacto o que el contenedor arrancó; no que producción
sirva el commit nuevo. Cachés, CDNs, builds viejos y rollbacks automáticos sirven
contenido viejo con todo en verde. Lo único que prueba el despliegue es una respuesta
real del entorno vivo que corresponda al commit liberado.

## Critical Patterns (reglas duras)

- NUNCA reportes "desplegado" sin una evidencia del Paso 4 que ate lo servido al `SHA`.
- NUNCA asumas stack, CI, plataforma ni nombres de jobs: se detectan (Pasos 0–3) o se
  leen de la configuración del proyecto.
- Si algo falla, DETENTE y reportá job y paso exactos. No reintentes el deploy, no
  re-ejecutes el run ni pushees de nuevo sin instrucción explícita.
- Solo lectura contra producción: `GET`/`HEAD`. Nunca requests que muten estado.
- No edites archivos del proyecto para "hacer pasar" la verificación. Si falta
  configuración (URL, endpoint de versión), proponé anotarla en una rama de trabajo.

## Paso 0 — Resolver la configuración (una sola vez)

Buscá en este orden en `CLAUDE.md`, luego `README.md` del proyecto:

| Clave | Para qué | Si falta |
|---|---|---|
| `URL de producción: <url>` | Base de todas las verificaciones | `gh variable get APP_URL` (u homólogo); si no, **preguntá una vez** |
| `Health check: <ruta>` | Salud del servicio | Probá `/up`, `/health`, `/healthz`, `/api/health`; el primero que dé `200`. Si ninguno, usá `/` |
| `Versión: <ruta o header>` | Evidencia directa del commit servido | Probá Paso 4.2 con los candidatos comunes |

Descartá `localhost`, `127.0.0.1` y cualquier URL de `.env*`: son del entorno local.
Guardá `URL` sin `/` final. Si tuviste que preguntar algo, proponé dejarlo anotado en
`CLAUDE.md` vía `/iniciar-trabajo-git` para no volver a preguntar.

Si el proyecto no expone nada por HTTP (librería, CLI, job batch), el "entorno vivo" es
el artefacto publicado (registry, release, imagen): verificá que su versión/digest
corresponda al `SHA` y saltá al Veredicto.

## Paso 1 — Detectar el CI e identificar el run del commit

```bash
SHA=$(git rev-parse origin/main)
ls .github/workflows/ .gitlab-ci.yml .circleci/ bitbucket-pipelines.yml 2>/dev/null
```

| CI detectado | Cómo listar el run del `SHA` |
|---|---|
| GitHub Actions | `gh run list --branch main --commit "$SHA" --limit 5 --json databaseId,workflowName,status,conclusion` |
| GitLab CI | `glab ci list --branch main` (si `glab` está instalado) |
| Otro / ninguno | Decí "CI no observable desde acá" y pasá al Paso 4 |

Si el run aún no aparece, esperá y repetí (máx. ~2 min) antes de reportar "el push no
disparó CI". Si hay varios workflows sobre el `SHA`, seguí todos los que corren en push.

## Paso 2 — Seguir el run hasta el final

```bash
gh run watch <id> --exit-status --interval 20
gh run view <id> --json conclusion,jobs -q '.conclusion, (.jobs[] | "\(.conclusion)\t\(.name)")'
```

Los nombres de los jobs se leen del run, no se asumen.

## Paso 3 — Clasificar cómo despliega el proyecto

Leé los workflows para ubicar el job de deploy (por `name`, `environment:` o comandos
como `deploy`, `vercel`, `netlify`, `flyctl`, `kubectl`, `helm`, `docker push`, `ssh`,
`rsync`, webhooks a Dokploy/Coolify/Render).

| Situación | Acción |
|---|---|
| Run en curso | Seguí con el Paso 2 |
| Falla un job previo al deploy (lint, test, gate, build) | DETENTE: nunca llegó a desplegar. Veredicto **fallido** |
| Falla el deploy | El código está en `main` pero NO en producción. Reportá la fase (`gh run view <id> --log-failed`). Veredicto **fallido** |
| Deploy verde | Paso 4, obligatorio |
| Deploy `skipped` o sin job de deploy | El deploy es externo al CI (integración Git de la plataforma, webhook, manual). Decílo explícito y hacé el Paso 4; puede tardar: reintentá unos minutos antes de concluir |

## Paso 4 — Verificar el entorno vivo (el paso que de verdad prueba algo)

**4.1 Salud.** `200` en el health check y en la home (o raíz del API):

```bash
curl -sS -o /dev/null -w '%{http_code}\n' "$URL<health>"
curl -sS -o /dev/null -w '%{http_code}\n' "$URL/"
```

Sumá las rutas públicas que tocó el release.

**4.2 Correspondencia con el commit.** Hace falta al menos UNA evidencia que ate lo
servido al `SHA`. Probá en este orden y quedate con la primera concluyente:

1. **Versión expuesta** (la más fuerte y barata). El `Versión:` del Paso 0, o candidatos
   comunes: endpoints `/version`, `/api/version`, `/version.json`, `/health` con campo
   de commit; headers `X-Commit`, `X-Version`, `X-Release`; `<meta name="version">` o
   similar en el HTML. Debe contener el `SHA` (o su prefijo corto) o el tag del release.
   ```bash
   curl -sSI "$URL/" | grep -iE '^x-(commit|version|release)'
   ```
2. **Header de la plataforma** que identifique el deployment, contrastado con el
   deployment del `SHA` en la plataforma (`vercel inspect`, `netlify api`, etc.) si su
   CLI está disponible y autenticada.
3. **Assets con hash de contenido** (frontends con bundler). Extraé los assets que
   referencia el HTML vivo, confirmá que responden `200`, y comparálos con los que
   produce un build del `SHA` aislado en un worktree temporal, usando el comando de
   build y la versión de runtime del proyecto (lockfile, `Dockerfile`, `.nvmrc`, etc.).
   Solo vale si el build es determinista para ese bundler; si no lo es (ej. IDs de
   build aleatorios), descartá esta vía y decílo.
4. **Marcador del cambio.** Un texto, clase, ruta, campo de respuesta o endpoint que el
   release introdujo, presente en la respuesta viva o dentro de un asset servido. Más
   débil: prueba que el cambio llegó, no que sea exactamente ese commit.

Si una evidencia contradice al `SHA` (versión distinta, hashes que no coinciden): el
entorno sirve otro build (caché, CDN, deploy viejo, rollback). Veredicto **fallido**,
con ambos valores como evidencia.

**4.3 Gates post-deploy (opcional).** Si el proyecto los tiene (ej. `.gate/baseline.json`
con el plugin release-gate → `/release-gate:deploy-check`), corrélos cuando el cambio
sea visual o de headers. Si no existen, no los inventes.

## Veredicto

| Veredicto | Cuándo |
|---|---|
| **verificado** | CI verde (o no observable, dicho), salud `200` y al menos una evidencia de 4.2 que ata lo servido al `SHA` |
| **fallido** | Falla un job, un HTTP distinto de `200`, un asset que no carga o una evidencia que contradice al `SHA` |
| **no verificable** | Sin URL resoluble, entorno inaccesible desde acá, o ninguna vía de 4.2 aplicable. Decí qué faltó y qué agregar al proyecto (ej. un endpoint `/version`) para que la próxima vez sea verificable |

Al cerrar, `mem_save` con `SHA`, id del run, URL, evidencia usada y veredicto.

## Output Contract

1. `SHA` corto y rama (`main`) liberados.
2. CI detectado y estado por job con el id del run; o "CI no observable".
3. Cómo despliega el proyecto (job de CI o externo).
4. **Entorno vivo**: URL usada (y de dónde salió), códigos HTTP y la evidencia de 4.2.
   Sin esto el reporte está incompleto.
5. Resultado de gates post-deploy, o por qué no aplicaban.
6. **Veredicto**: verificado / fallido / no verificable.
7. Qué quedó sin verificar y necesita una persona (flujos con login, pagos, móvil).

## References

- `CLAUDE.md` / `README.md` del proyecto — `URL de producción`, `Health check`, `Versión`.
- Workflows de CI del proyecto — jobs y condición del deploy.
- `skills/guardar-cambios-git/SKILL.md` — Paso 5.1, que invoca esta skill.
