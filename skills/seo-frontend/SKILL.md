---
name: seo-frontend
description: >
  Experto SEO técnico y on-page para vistas públicas, agnóstico de stack (referencias para Laravel + Blade y Astro).
  Trigger: vistas públicas (`.astro`, `.blade.php`, HTML), meta tags, Open Graph, Twitter Cards, JSON-LD / structured data, canonical, sitemap, robots.txt, Core Web Vitals, accesibilidad, performance frontend.
license: Apache-2.0
metadata:
  author: gentleman-programming
  version: "2.0"
---

## When to Use

- Trabajando en vistas públicas (`src/pages/**/*.astro`, `resources/views/**/*.blade.php`, HTML)
- Agregando o revisando meta tags, Open Graph, Twitter Cards
- Implementando JSON-LD / structured data
- Optimizando Core Web Vitals (LCP, CLS, INP)
- Configurando canonical URLs, robots.txt, sitemap.xml
- Revisando accesibilidad semántica (headings, aria, alt)
- Lazy loading de imágenes o assets
- Cualquier tarea de SEO técnico o on-page

## Paso 0 — Detectar el stack (OBLIGATORIO)

Antes de escribir código, detectá el stack en la raíz del proyecto y cargá **solo** la
referencia que corresponda:

| Señal | Stack | Leé |
|-------|-------|-----|
| Existe `astro.config.*` (`.mjs`, `.ts`, `.js`) | Astro | [`references/astro.md`](references/astro.md) |
| Existe `artisan`, o `composer.json` requiere `laravel/framework` | Laravel + Blade | [`references/laravel-blade.md`](references/laravel-blade.md) |
| Ninguna | Otro | Sin referencia stack-específica: aplicá las reglas de abajo con HTML plano y decíselo al usuario |

Las reglas de este archivo son universales; la referencia dice **cómo** implementarlas
en ese stack (sintaxis, layout, assets, sitemap). Si hay conflicto, manda la regla de acá.

## Critical Patterns

Los ejemplos son HTML plano; el equivalente por stack está en la referencia, con la misma numeración.

### 1. Head Tags — estructura obligatoria por página

Cada página pública DEBE renderizar en `<head>`, centralizado en el layout (nunca copiado a mano por página):

```html
<!-- Title único por página -->
<title>Nombre de la Página | Marca</title>

<!-- Meta básicos -->
<meta name="description" content="Descripción única, máximo 160 caracteres.">
<meta name="robots" content="index, follow">
<link rel="canonical" href="https://tudominio.com/ruta">

<!-- Open Graph -->
<meta property="og:title" content="Nombre de la Página">
<meta property="og:description" content="...">
<meta property="og:url" content="https://tudominio.com/ruta"> <!-- = canonical -->
<meta property="og:type" content="website">
<meta property="og:image" content="https://tudominio.com/images/og-default.jpg">
<meta property="og:locale" content="es_AR">
<meta property="og:site_name" content="Marca">

<!-- Twitter Card -->
<meta name="twitter:card" content="summary_large_image">
<meta name="twitter:title" content="Nombre de la Página">
<meta name="twitter:description" content="...">
<meta name="twitter:image" content="https://tudominio.com/images/og-default.jpg">
```

Defaults (nombre del sitio, descripción, imagen OG) salen de una sola fuente de configuración.

### 2. Por página — valores obligatorios

Cada página define como mínimo: **title**, **meta description** (única, ≤ 160 caracteres)
y **canonical**. El resto puede caer a los defaults del layout.

### 3. Headings — jerarquía estricta

- **UN SOLO `<h1>` por página** — título principal
- `<h2>` para secciones, `<h3>` para subsecciones
- NUNCA saltear niveles (h1 → h3 sin h2)
- NO usar headings para estilo — usar clases en `<p>` o `<span>`

```html
<!-- CORRECTO -->
<h1>Título principal</h1>
<section>
  <h2>Sección</h2>
</section>

<!-- MAL — heading para estilo -->
<h3 class="text-sm">Este no es un heading real</h3>
```

### 4. Imágenes — siempre con alt + dimensiones + lazy

```html
<!-- CORRECTO -->
<img src="/images/foto.jpg" alt="Descripción descriptiva de la imagen"
     loading="lazy" width="800" height="600">

<!-- MAL -->
<img src="..."> <!-- sin alt, sin dimensions, sin lazy -->
```

- `alt=""` solo para imágenes decorativas (`aria-hidden="true"` también)
- Siempre declarar `width` y `height` para evitar CLS
- La imagen LCP (hero / above the fold) NO va lazy: va eager + prioridad alta

### 5. JSON-LD Structured Data

```html
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "WebPage",
  "name": "Título de la página",
  "description": "Descripción de la página",
  "url": "https://tudominio.com/ruta"
}
</script>
```

Tipos comunes: `WebPage`, `Article`, `Product`, `BreadcrumbList`, `Organization`, `LocalBusiness`.
Generalo serializando un objeto (no concatenando strings) para evitar JSON roto o escapes inválidos.

### 6. Breadcrumbs — SEO + Schema

```html
<nav aria-label="Breadcrumb">
  <ol itemscope itemtype="https://schema.org/BreadcrumbList">
    <li itemprop="itemListElement" itemscope itemtype="https://schema.org/ListItem">
      <a itemprop="item" href="/"><span itemprop="name">Inicio</span></a>
      <meta itemprop="position" content="1">
    </li>
    <li itemprop="itemListElement" itemscope itemtype="https://schema.org/ListItem">
      <span itemprop="name">Página actual</span>
      <meta itemprop="position" content="2">
    </li>
  </ol>
</nav>
```

### 7. Core Web Vitals

| Métrica | Target | Acción |
|---------|--------|--------|
| LCP | < 2.5s | Preload hero image, fonts; evitar render-blocking CSS |
| CLS | < 0.1 | Siempre width+height en img; reservar espacio para ads/embeds |
| INP | < 200ms | Minimizar JS en el critical path; diferir JS no crítico |

```html
<!-- Preload critical font -->
<link rel="preload" href="/fonts/inter.woff2" as="font" type="font/woff2" crossorigin>

<!-- Preload hero image -->
<link rel="preload" as="image" href="/images/hero.jpg">
```

### 8. Accesibilidad semántica (impacta SEO)

```html
<!-- Landmarks obligatorios -->
<header role="banner">...</header>
<nav aria-label="Navegación principal">...</nav>
<main id="main-content">...</main>
<footer role="contentinfo">...</footer>

<!-- Skip link (visible al recibir foco) -->
<a href="#main-content" class="sr-only focus:not-sr-only">Saltar al contenido</a>

<!-- Formularios -->
<label for="email">Email</label>
<input id="email" name="email" type="email" aria-describedby="email-hint">
<p id="email-hint">Usaremos tu email solo para...</p>
```

### 9. Robots y Canonicals — reglas

- Páginas de admin/dashboard: `<meta name="robots" content="noindex, nofollow">`
- Páginas utilitarias (404, "gracias", confirmaciones): `noindex`
- Páginas paginadas: canonical apunta a la primera página o a sí misma (nunca en blanco)
- URLs con parámetros de filtro: canonical a la URL base
- Canonical siempre absoluta, con el dominio de producción

### 10. Sitemap y Robots.txt

- `sitemap.xml` generado (nunca a mano) con todas las URLs públicas indexables.
- `robots.txt` en la raíz del dominio, apuntando al sitemap.

`robots.txt` mínimo:
```
User-agent: *
Allow: /
Disallow: /admin/
Disallow: /profile/
Sitemap: https://tudominio.com/sitemap.xml
```

## Decision Tree — ¿Qué aplico?

```
¿Es una página pública?
├── Sí → title + meta description + canonical + OG tags OBLIGATORIOS
│         └── ¿Tiene contenido rico? → agregar JSON-LD
└── No (admin/auth) → robots noindex + sin OG tags

¿Tiene imágenes?
├── Hero/above fold → preload/prioridad alta + width/height + alt descriptivo
└── Below fold → loading="lazy" + width/height + alt descriptivo

¿Tiene lista de items/productos?
└── Sí → BreadcrumbList schema + ItemList schema
```

## Commands

```bash
# Validar structured data
# Pegar URL en: https://validator.schema.org/

# Verificar meta tags parseados
# Pegar URL en: https://metatags.io/

# Analizar Core Web Vitals
# Usar PageSpeed Insights o Lighthouse en Chrome DevTools
```

## Resources

- **Laravel + Blade**: [references/laravel-blade.md](references/laravel-blade.md) · template head [assets/laravel/head-seo.blade.php](assets/laravel/head-seo.blade.php)
- **Astro**: [references/astro.md](references/astro.md) · componente [assets/astro/SEOHead.astro](assets/astro/SEOHead.astro)
- **Contexto del proyecto**: `ai/context/frontend.md (o ia/context/ en proyectos legados)`
