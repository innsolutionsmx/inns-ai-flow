{{--
  Template SEO para <head>.
  Copiar en layouts/app.blade.php y layouts/guest.blade.php.
  Cada vista sobreescribe los @section correspondientes.
--}}

{{-- === BÁSICOS === --}}
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>@yield('title', config('app.name')) | {{ config('app.name') }}</title>
<meta name="description" content="@yield('meta_description', '')">
<meta name="robots" content="@yield('robots', 'index, follow')">
<link rel="canonical" href="@yield('canonical', url()->current())">

{{-- === OPEN GRAPH === --}}
<meta property="og:title" content="@yield('og_title', config('app.name'))">
<meta property="og:description" content="@yield('og_description', '')">
<meta property="og:url" content="@yield('canonical', url()->current())">
<meta property="og:type" content="@yield('og_type', 'website')">
<meta property="og:image" content="@yield('og_image', asset('images/og-default.jpg'))">
<meta property="og:locale" content="es_AR">
<meta property="og:site_name" content="{{ config('app.name') }}">

{{-- === TWITTER CARD === --}}
<meta name="twitter:card" content="summary_large_image">
<meta name="twitter:title" content="@yield('og_title', config('app.name'))">
<meta name="twitter:description" content="@yield('og_description', '')">
<meta name="twitter:image" content="@yield('og_image', asset('images/og-default.jpg'))">

{{-- === PERFORMANCE === --}}
<link rel="preconnect" href="https://fonts.googleapis.com">
@stack('preloads')

{{-- === VITE === --}}
@vite(['resources/css/app.css', 'resources/js/app.js'])

{{-- === JSON-LD (cada vista puede pushear su schema) === --}}
@stack('structured_data')
