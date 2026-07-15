---
name: seo-frontend
description: >
  Experto SEO para proyectos server-side con Laravel + Blade + Tailwind v4 + DaisyUI v5.
  Trigger: vistas Blade, meta tags, Open Graph, structured data, Core Web Vitals, accesibilidad, performance frontend, canonical, sitemap, robots.txt.
license: Apache-2.0
metadata:
  author: gentleman-programming
  version: "1.0"
---

## When to Use

- Trabajando en vistas Blade (`resources/views/**/*.blade.php`)
- Agregando o revisando meta tags, Open Graph, Twitter Cards
- Implementando JSON-LD / structured data
- Optimizando Core Web Vitals (LCP, CLS, FID/INP)
- Configurando canonical URLs, robots.txt, sitemap.xml
- Revisando accesibilidad semántica (headings, aria, alt)
- Lazy loading de imágenes o assets
- Cualquier tarea de SEO técnico o on-page

## Stack del Proyecto

| Tecnología | Versión | Nota |
|------------|---------|------|
| Laravel Blade | — | Server-side rendering — SEO aplica directo en vistas |
| Tailwind CSS | v4 | Config en `app.css`, NO hay `tailwind.config.js` |
| DaisyUI | v5 | Componentes UI — NO usar clases de color genéricas de Tailwind |
| jQuery | v4 | DOM / AJAX |
| Vite | v7 | Bundler con HMR |
| Iconos | — | Google Material Symbols Outlined |

## Critical Patterns

### 1. Head Tags — estructura obligatoria por vista

Cada vista o layout DEBE tener en `<head>`:

```blade
{{-- Title único por página --}}
<title>@yield('title', config('app.name')) | {{ config('app.name') }}</title>

{{-- Meta básicos --}}
<meta name="description" content="@yield('meta_description', 'Descripción por defecto')">
<meta name="robots" content="@yield('robots', 'index, follow')">
<link rel="canonical" href="@yield('canonical', url()->current())">

{{-- Open Graph --}}
<meta property="og:title" content="@yield('og_title', config('app.name'))">
<meta property="og:description" content="@yield('og_description', '')">
<meta property="og:url" content="@yield('canonical', url()->current())">
<meta property="og:type" content="@yield('og_type', 'website')">
<meta property="og:image" content="@yield('og_image', asset('images/og-default.jpg'))">

{{-- Twitter Card --}}
<meta name="twitter:card" content="summary_large_image">
<meta name="twitter:title" content="@yield('og_title', config('app.name'))">
<meta name="twitter:description" content="@yield('og_description', '')">
<meta name="twitter:image" content="@yield('og_image', asset('images/og-default.jpg'))">
```

### 2. Por vista — slots obligatorios

```blade
@section('title', 'Nombre de la Página')
@section('meta_description', 'Descripción única y relevante de máximo 160 caracteres.')
@section('canonical', route('nombre.ruta'))
```

### 3. Headings — jerarquía estricta

- **UN SOLO `<h1>` por vista** — título principal de la página
- `<h2>` para secciones, `<h3>` para subsecciones
- NUNCA saltear niveles (h1 → h3 sin h2)
- NO usar headings para estilo — usar clases Tailwind en `<p>` o `<span>`

```blade
{{-- CORRECTO --}}
<h1 class="text-3xl font-bold">Título principal</h1>
<section>
  <h2 class="text-xl font-semibold">Sección</h2>
</section>

{{-- MAL — heading para estilo --}}
<h3 class="text-sm text-gray-500">Este no es un heading real</h3>
```

### 4. Imágenes — siempre con alt + lazy loading

```blade
{{-- CORRECTO --}}
<img src="{{ asset('images/foto.jpg') }}"
     alt="Descripción descriptiva de la imagen"
     loading="lazy"
     width="800"
     height="600">

{{-- MAL --}}
<img src="..."> {{-- sin alt, sin dimensions, sin lazy --}}
```

- `alt=""` solo para imágenes decorativas (aria-hidden="true" también)
- Siempre declarar `width` y `height` para evitar CLS

### 5. JSON-LD Structured Data

```blade
@push('scripts')
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "WebPage",
  "name": "{{ $page->title }}",
  "description": "{{ $page->description }}",
  "url": "{{ url()->current() }}"
}
</script>
@endpush
```

Tipos comunes: `WebPage`, `Article`, `Product`, `BreadcrumbList`, `Organization`, `LocalBusiness`.

### 6. Breadcrumbs — SEO + Schema

```blade
<nav aria-label="Breadcrumb">
  <ol itemscope itemtype="https://schema.org/BreadcrumbList">
    <li itemprop="itemListElement" itemscope itemtype="https://schema.org/ListItem">
      <a itemprop="item" href="{{ route('home') }}">
        <span itemprop="name">Inicio</span>
      </a>
      <meta itemprop="position" content="1">
    </li>
    <li itemprop="itemListElement" itemscope itemtype="https://schema.org/ListItem">
      <span itemprop="name">Página actual</span>
      <meta itemprop="position" content="2">
    </li>
  </ol>
</nav>
```

### 7. Core Web Vitals — reglas en Blade/Vite

| Métrica | Target | Acción |
|---------|--------|--------|
| LCP | < 2.5s | Preload hero image, fonts; evitar render-blocking CSS |
| CLS | < 0.1 | Siempre width+height en img; reservar espacio para ads/embeds |
| INP | < 200ms | Minimizar JS en el critical path; diferir jQuery si no es crítico |

```blade
{{-- Preload critical font --}}
<link rel="preload" href="{{ asset('fonts/inter.woff2') }}" as="font" type="font/woff2" crossorigin>

{{-- Preload hero image --}}
<link rel="preload" as="image" href="{{ asset('images/hero.jpg') }}">
```

### 8. Accesibilidad semántica (impacta SEO)

```blade
{{-- Landmarks obligatorios --}}
<header role="banner">...</header>
<nav aria-label="Navegación principal">...</nav>
<main id="main-content">...</main>
<footer role="contentinfo">...</footer>

{{-- Skip link --}}
<a href="#main-content" class="sr-only focus:not-sr-only">Saltar al contenido</a>

{{-- Formularios --}}
<label for="email">Email</label>
<input id="email" name="email" type="email" aria-describedby="email-hint">
<p id="email-hint">Usaremos tu email solo para...</p>
```

### 9. Robots y Canonicals — reglas

- Páginas de admin/dashboard: `<meta name="robots" content="noindex, nofollow">`
- Páginas paginadas: canonical apunta a la primera página o a sí misma (nunca en blanco)
- URLs con parámetros de filtro: canonical a la URL base

```blade
@if(request()->has('page') && request()->get('page') > 1)
  @section('canonical', route('productos.index'))
@else
  @section('canonical', url()->current())
@endif
```

### 10. Sitemap y Robots.txt

```php
// routes/web.php
Route::get('/sitemap.xml', [SitemapController::class, 'index']);
Route::get('/robots.txt', [RobotsController::class, 'index']);
```

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
├── Hero/above fold → preload + width/height + alt descriptivo
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

- **Template head**: Ver [assets/head-seo.blade.php](assets/head-seo.blade.php)
- **Contexto del proyecto**: `ai/context/frontend.md (o ia/context/ en proyectos legados)`
