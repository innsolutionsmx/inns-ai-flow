# SEO frontend — Laravel + Blade

Referencia stack-específica de `seo-frontend`. Las reglas viven en `SKILL.md`; acá
está **cómo** se implementan en un proyecto Laravel + Blade. La numeración sigue la
de los Critical Patterns de `SKILL.md`.

## Stack del Proyecto

| Tecnología | Versión | Nota |
|------------|---------|------|
| Laravel Blade | — | Server-side rendering — SEO aplica directo en vistas |
| Tailwind CSS | v4 | Config en `app.css`, NO hay `tailwind.config.js` |
| DaisyUI | v5 | Componentes UI — NO usar clases de color genéricas de Tailwind |
| jQuery | v4 | DOM / AJAX |
| Vite | v7 | Bundler con HMR |
| Iconos | — | Google Material Symbols Outlined |

Archivos donde aplica: vistas Blade (`resources/views/**/*.blade.php`) y layouts
(`layouts/app.blade.php`, `layouts/guest.blade.php`).

## 1. Head Tags — estructura obligatoria por vista

Template completo listo para copiar: [`assets/laravel/head-seo.blade.php`](../assets/laravel/head-seo.blade.php)
(se pega en `layouts/app.blade.php` y `layouts/guest.blade.php`). Cada vista o layout
DEBE tener en `<head>`:

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

## 2. Por vista — slots obligatorios

```blade
@section('title', 'Nombre de la Página')
@section('meta_description', 'Descripción única y relevante de máximo 160 caracteres.')
@section('canonical', route('nombre.ruta'))
```

## 3. Headings

Estilo con clases Tailwind en `<p>` o `<span>`, nunca con el nivel del heading:

```blade
{{-- CORRECTO --}}
<h1 class="text-3xl font-bold">Título principal</h1>
<section>
  <h2 class="text-xl font-semibold">Sección</h2>
</section>

{{-- MAL — heading para estilo --}}
<h3 class="text-sm text-gray-500">Este no es un heading real</h3>
```

## 4. Imágenes

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

## 5. JSON-LD

Cada vista pushea su schema. El template del head expone `@stack('structured_data')`;
algunos layouts usan `@stack('scripts')` — usá el stack que tenga el layout.

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

## 6. Breadcrumbs

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

## 7. Core Web Vitals — Blade/Vite

- INP: diferir jQuery si no es crítico.
- Los preloads de cada vista van al `@stack('preloads')` del template del head.

```blade
{{-- Preload critical font --}}
<link rel="preload" href="{{ asset('fonts/inter.woff2') }}" as="font" type="font/woff2" crossorigin>

{{-- Preload hero image --}}
<link rel="preload" as="image" href="{{ asset('images/hero.jpg') }}">
```

## 8. Accesibilidad semántica

Skip link con utilidades de Tailwind:

```blade
<a href="#main-content" class="sr-only focus:not-sr-only">Saltar al contenido</a>
```

## 9. Canonical en páginas paginadas

```blade
@if(request()->has('page') && request()->get('page') > 1)
  @section('canonical', route('productos.index'))
@else
  @section('canonical', url()->current())
@endif
```

Admin/dashboard: `@section('robots', 'noindex, nofollow')`.

## 10. Sitemap y Robots.txt

Se sirven desde rutas propias (dinámicos):

```php
// routes/web.php
Route::get('/sitemap.xml', [SitemapController::class, 'index']);
Route::get('/robots.txt', [RobotsController::class, 'index']);
```

El contenido mínimo de `robots.txt` está en `SKILL.md` (Patrón 10).
