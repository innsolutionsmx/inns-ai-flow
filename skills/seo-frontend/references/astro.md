# SEO frontend — Astro

Referencia stack-específica de `seo-frontend` para Astro 5. Las reglas viven en
`SKILL.md`; acá está **cómo** se implementan siguiendo las convenciones del template de
la casa (`base-landing-astro`). La numeración sigue la de los Critical Patterns.

## Convenciones del template de la casa (no inventes paralelas)

| Qué | Dónde | Nota |
|-----|-------|------|
| `<head>` SEO | `src/layouts/Base.astro` | Ya renderiza title, description, canonical, OG y Twitter Card. **Es** el head: no le sumes otro componente de head |
| Datos por cliente | `src/config/site.ts` (`site`) | `siteName`, `description`, `url`, `locale`, `logo`, contacto, redes. Única fuente de verdad: defaults de SEO salen de acá |
| URL de producción | `site` en `astro.config.mjs` | Base de canonical/OG (`Astro.site`). Debe coincidir con `site.url` |
| Output | `output: "static"` | HTML estático, deploy en Cloudflare Workers |
| Estáticos | `public/` | `robots.txt`, favicon, imagen OG |

Si el proyecto **no** tiene `Base.astro` (u otro layout que ya haga el head), copiá
[`assets/astro/SEOHead.astro`](../assets/astro/SEOHead.astro) a `src/components/` y
renderizalo dentro del `<head>` del layout. Tiene el mismo contrato de props que
`Base.astro` (`title`, `description`) más los opcionales `image`, `type`, `noindex`,
`canonical`.

## 1. Head Tags

En el template, `Base.astro` arma:

- `title`: `"{title} | {site.siteName}"` (o solo `siteName` en la home).
- `canonical` y `og:url`: `new URL(Astro.url.pathname, Astro.site ?? site.url)` — absoluta.
- `og:locale`: `site.locale` con `-` → `_` (`es-MX` → `es_MX`).
- `<html lang={site.locale}>` y `<main id="main">`.

**Huecos conocidos de `Base.astro`** respecto a `SKILL.md` — si la tarea los necesita,
extendé `Base.astro` (props opcionales con default, mismo estilo de `interface Props`
documentada) en vez de duplicar tags en la página:

| Falta | Regla | Cómo extender |
|-------|-------|---------------|
| `og:image` / `twitter:image` | Patrón 1 | prop `image?: string` → `new URL(image, Astro.site ?? site.url)`; imagen default (1200×630) en `public/` — el template todavía no trae una |
| `meta robots` | Patrón 9 (404, `gracias` → `noindex`) | prop `noindex?: boolean` |
| canonical override | Patrón 9 (paginado/filtros) | prop `canonical?: string` |
| extras en `<head>` | Patrón 5/7 (JSON-LD, preloads) | `<slot name="head" />` dentro de `<head>` |

`SEOHead.astro` ya implementa exactamente esos props: usalo como referencia del diff.

## 2. Por página — props al layout

Cada página pasa sus valores al layout; nada de `<meta>` sueltos en la página:

```astro
---
import Base from "../layouts/Base.astro";
---
<Base title="Servicios" description="Descripción única, máximo 160 caracteres.">
  <h1>Servicios</h1>
</Base>
```

La home puede omitir props (cae a `site.siteName` / `site.description`).

## 3. Headings

Un solo `<h1>` por página. Ojo con componentes reutilizables (`Hero.astro`, `CTA.astro`):
si un componente renderiza un heading, verificá que el nivel encaje donde se usa
(un `Hero` con `<h1>` no puede aparecer dos veces en la misma página).

## 4. Imágenes — `astro:assets`

Usá `<Image />` (o `<Picture />` para AVIF/WebP) en vez de `<img>` crudo: optimiza,
emite `width`/`height` (anti-CLS) y por defecto pone `loading="lazy"`.

```astro
---
import { Image } from "astro:assets";
import hero from "../assets/hero.jpg"; // en src/: dimensiones inferidas
---
<!-- LCP / above the fold: priority = loading="eager" decoding="sync" fetchpriority="high" -->
<Image src={hero} alt="Descripción descriptiva" priority />

<!-- Below the fold: lazy por defecto -->
<Image src={hero} alt="Descripción descriptiva" />

<!-- Desde public/ o remota: width y height obligatorios -->
<Image src="/images/foto.jpg" alt="..." width={800} height={600} />
```

- `priority` existe desde Astro **5.10**. Si el `package.json` fija una versión menor,
  usá `loading="eager" fetchpriority="high"` a mano.
- Imágenes que se optimizan van en `src/assets/`; `public/` es para lo que se sirve tal cual
  (favicon, imagen OG).
- Decorativas: `alt=""` + `aria-hidden="true"`.

## 5. JSON-LD

Serializá un objeto con `set:html` — nunca interpoles strings dentro del `<script>`:

```astro
---
import { site } from "../config/site";

const schema = {
  "@context": "https://schema.org",
  "@type": "LocalBusiness",
  name: site.siteName,
  description: site.description,
  url: site.url,
  email: site.contact.email,
  telephone: site.contact.phone,
  sameAs: site.social.map((s) => s.url),
};
---
<script type="application/ld+json" set:html={JSON.stringify(schema)} />
```

Astro no procesa ni empaqueta `<script>` con `type="application/ld+json"` (no genera JS
de cliente). Puede ir en el `<body>` de la página (válido para Google) o en el `<head>`
vía `<slot name="head" />` si extendiste el layout. `Organization` / `LocalBusiness` sale
de `site.ts`; `WebPage`, `Article`, `BreadcrumbList` por página.

## 6. Breadcrumbs

Mismo markup que `SKILL.md` (Patrón 6), con `href` absolutos armados desde `Astro.site`
si los necesitás en el schema: `new URL("/servicios", Astro.site).href`.

## 7. Core Web Vitals — cero JS de cliente

- El template no usa islas ni frameworks de UI: **cero JS de cliente por defecto**. No
  agregues `client:*` ni integraciones de UI salvo que la interacción lo exija; si hace
  falta, preferí `client:visible` / `client:idle` sobre `client:load`.
- `<script>` en componentes Astro se empaqueta y se carga como módulo (diferido); mantenelo mínimo.
- LCP: hero con `<Image priority />` (ver 4). Fonts: el template declara las familias en
  `src/styles/tokens.css` sin archivos propios (cae a system fonts). Si el proyecto
  self-hostea un `.woff2` en `public/fonts/`, precargá solo el crítico:

```astro
<link rel="preload" href="/fonts/inter.woff2" as="font" type="font/woff2" crossorigin />
```

## 8. Accesibilidad semántica

`Base.astro` ya da `<Nav />`, `<main id="main">` y `<Footer />`, pero no trae skip link:
si lo agregás, va primero en el `<body>` del layout y apunta a `#main` (no `#main-content`).

## 9. Robots y canonicals

- 404 (`src/pages/404.astro`) y `gracias.astro` → `noindex` (requiere el prop `noindex`
  del hueco de la sección 1).
- Paginado/filtros → prop `canonical` con la URL base.
- Canonical siempre absoluta: depende de que `site` en `astro.config.mjs` sea el dominio
  real del cliente (el template trae `https://example.com` — cambialo).

## 10. Sitemap y robots.txt

**Sitemap**: revisá `package.json`. Si `@astrojs/sitemap` **no** está (el template base no
lo trae), instalalo:

```bash
npx astro add sitemap
```

Eso lo agrega a `integrations` en `astro.config.mjs`. Requiere `site` configurado y genera
`sitemap-index.xml` (+ `sitemap-0.xml`) en el build. Excluí páginas `noindex`:

```js
// astro.config.mjs
import sitemap from "@astrojs/sitemap";

export default defineConfig({
  site: "https://www.cliente.com",
  output: "static",
  integrations: [
    sitemap({ filter: (page) => !page.includes("/gracias") && !page.includes("/404") }),
  ],
});
```

**robots.txt**: archivo estático en `public/robots.txt` (el template ya lo trae). Al
activar el sitemap, descomentá la línea y poné el dominio real:

```
User-agent: *
Allow: /

Sitemap: https://www.cliente.com/sitemap-index.xml
```

## Validación

`npm run check` (`astro check`) para tipos de props, `npm run build` y revisar el HTML de
`dist/` (head, JSON-LD, sitemap). Luego los validadores de `SKILL.md` contra el deploy.
