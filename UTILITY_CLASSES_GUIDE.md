/**
 * UTILITY CLASSES - Tailwind-like utility system for rapid prototyping
 * These are pre-defined in styles-modular.css but documented here for reference
 * Version: 20251109.1
 */

/* 
   DISPLAY UTILITIES
   .block, .inline, .inline-block, .flex, .grid, .hidden, .visible
   
   Usage: <div class="flex gap-md">Content</div>
*/

/* 
   FLEXBOX UTILITIES
   .flex-center: Centered flex container (center items & content)
   .flex-between: Space-between flex (items centered, content spaced)
   .flex-col: Flex with column direction
   .flex-wrap: Flex with wrap enabled
   .gap-sm, .gap-md, .gap-lg: Gaps between flex items
   
   Usage: <div class="flex flex-center gap-lg">Centered items with spacing</div>
*/

/* 
   MARGIN UTILITIES
   .m-auto: margin: auto (center)
   .mt-md, .mb-md, .ml-md, .mr-md: Margin on specific sides
   .mx-auto: Horizontal auto margin
   .my-auto: Vertical auto margin
   
   Usage: <div class="mx-auto mt-md">Centered horizontally</div>
*/

/* 
   PADDING UTILITIES
   .p-md: Padding on all sides
   .px-md: Horizontal padding
   .py-md: Vertical padding
   .pt-md, .pb-md, .pl-md, .pr-md: Padding on specific sides
   
   Usage: <div class="p-md px-lg">More padding</div>
*/

/* 
   WIDTH UTILITIES
   .w-full: width: 100%
   .w-auto: width: auto
   .w-screen: width: 100vw
   .w-1/2, .w-1/3, .w-2/3: Fractional widths
   
   Usage: <div class="w-full">Full width</div>
          <div class="w-1/2">Half width</div>
*/

/* 
   TEXT UTILITIES
   .text-center, .text-left, .text-right: Text alignment
   .text-primary, .text-secondary, .text-white: Text colors
   .font-bold, .font-semibold: Font weights
   .text-sm, .text-lg, .text-xl: Font sizes
   .uppercase, .lowercase, .capitalize: Text transform
   
   Usage: <p class="text-center text-primary font-bold text-lg">Bold primary text</p>
*/

/* 
   BACKGROUND UTILITIES
   .bg-primary: Primary background color
   .bg-secondary: Secondary background
   .bg-light, .bg-dark: Light/dark backgrounds
   .bg-gradient-primary: Primary gradient
   
   Usage: <div class="bg-primary text-white">Primary background</div>
*/

/* 
   OPACITY UTILITIES
   .opacity-50: opacity: 0.5
   .opacity-75: opacity: 0.75
   .opacity-100: opacity: 1
   
   Usage: <div class="opacity-75">75% opaque</div>
*/

/* 
   BORDER UTILITIES
   .border: 1px border on all sides
   .border-t, .border-b, .border-l, .border-r: Border on specific sides
   .rounded: border-radius: var(--radius-md)
   .rounded-lg, .rounded-xl: Larger border radius
   .rounded-full: Fully rounded (pill shape)
   
   Usage: <div class="border rounded-lg">Bordered with round corners</div>
*/

/* 
   SHADOW UTILITIES
   .shadow-sm: Small shadow
   .shadow-md: Medium shadow
   .shadow-lg: Large shadow
   .shadow-xl: Extra large shadow
   .shadow-glow: Glowing primary shadow
   
   Usage: <div class="shadow-lg">Large shadow</div>
          <div class="shadow-glow">Glowing effect</div>
*/

/* 
   CURSOR UTILITIES
   .cursor-pointer: cursor: pointer
   .cursor-not-allowed: cursor: not-allowed
   .cursor-default: cursor: default
   
   Usage: <button class="cursor-pointer">Clickable</button>
          <div class="cursor-not-allowed">Not clickable</div>
*/

/* 
   OVERFLOW UTILITIES
   .overflow-hidden: overflow: hidden
   .overflow-auto: overflow: auto
   .overflow-x-auto: overflow-x: auto
   .overflow-y-auto: overflow-y: auto
   
   Usage: <div class="overflow-auto h-64">Scrollable content</div>
*/

/* 
   POSITION UTILITIES
   .relative: position: relative
   .absolute: position: absolute
   .fixed: position: fixed
   .sticky: position: sticky (sticky to top)
   
   Usage: <div class="relative">
            <div class="absolute top-0 right-0">Positioned</div>
          </div>
*/

/* 
   Z-INDEX UTILITIES
   .z-base: z-index: 0 (base layer)
   .z-above: z-index: 1 (above base)
   .z-dropdown: z-index: 100 (dropdown)
   .z-fixed: z-index: 1000 (fixed elements)
   .z-modal: z-index: 2000 (modals)
   .z-tooltip: z-index: 3000 (tooltips)
   
   Usage: <div class="z-fixed">Fixed positioning</div>
          <div class="z-modal">Modal on top</div>
*/

/* 
   RESPONSIVE UTILITIES
   .mobile-only: Visible only on mobile (< 768px)
   .desktop-only: Visible only on desktop (≥ 768px)
   .hidden@mobile: Hidden on mobile
   .hidden@desktop: Hidden on desktop
   
   Usage: <div class="mobile-only">Mobile content</div>
          <div class="desktop-only">Desktop content</div>
*/

/* 
   ANIMATION UTILITIES
   .transition-all: Smooth transition for all properties
   .transition-colors: Smooth color transitions
   .transition-transform: Smooth transform transitions
   .animate-fadeIn: Fade in animation
   .animate-slideUp: Slide up animation
   .animate-pulse: Pulsing animation (infinite)
   
   Usage: <div class="transition-all hover:scale-105">Smooth transform</div>
          <div class="animate-fadeIn">Fades in on load</div>
*/

/* 
   ADVANCED COMBINATIONS
   
   Centered container:
   <div class="flex flex-center gap-md">Content</div>
   
   Card layout:
   <div class="rounded-lg shadow-lg p-xl bg-secondary">Card</div>
   
   Button group:
   <div class="flex gap-md">
     <button class="flex-1">Button 1</button>
     <button class="flex-1">Button 2</button>
   </div>
   
   Responsive grid:
   <div class="grid gap-lg" style="grid-template-columns: repeat(auto-fit, minmax(280px, 1fr))">
     <div class="rounded-lg p-md bg-secondary">Item</div>
   </div>
   
   Sticky header:
   <header class="sticky top-0 z-fixed bg-secondary">Header</header>
   
   Scrollable section:
   <div class="overflow-auto max-h-screen">Long content</div>
*/

/*
   SPACING SCALE:
   xs: 0.25rem (4px)
   sm: 0.5rem (8px)
   md: 1rem (16px)
   lg: 1.5rem (24px)
   xl: 2rem (32px)
   2xl: 3rem (48px)
   3xl: 4rem (64px)
   4xl: 6rem (96px)
*/

/*
   RESPONSIVE BREAKPOINTS:
   Ultra-mobile: < 380px
   Mobile: 380px - 480px
   Tablet: 480px - 768px
   Desktop: 768px - 1200px
   Large desktop: 1200px+
*/

/*
   COLOR TOKENS:
   Primary: #0ea5e9
   Secondary: #8b5cf6
   Success: #10b981
   Warning: #f59e0b
   Danger: #ef4444
   
   Text on dark:
   Primary: #e8eef8
   Secondary: #cbd5e1
   Tertiary: #94a3b8
*/

/*
   SHADOWS:
   sm: 0 1px 2px 0 rgba(0, 0, 0, 0.05)
   md: 0 4px 6px -1px rgba(0, 0, 0, 0.1)
   lg: 0 10px 15px -3px rgba(0, 0, 0, 0.1)
   xl: 0 20px 25px -5px rgba(0, 0, 0, 0.1)
   glow: 0 0 20px rgba(14, 165, 233, 0.2)
*/

/*
   QUICK START COMPONENTS:
   
   1. Primary Button:
      <button class="btn btn-primary">Click me</button>
   
   2. Secondary Button:
      <button class="btn btn-secondary">Click me</button>
   
   3. Text Input:
      <input type="text" placeholder="Enter text" />
   
   4. Card:
      <div class="card">
        <h3>Title</h3>
        <p>Content here</p>
      </div>
   
   5. Centered Container:
      <div class="flex flex-center gap-md">
        <div>Content</div>
      </div>
   
   6. Grid Layout:
      <div class="grid gap-md" style="grid-template-columns: repeat(auto-fit, minmax(250px, 1fr))">
        <div>Item 1</div>
        <div>Item 2</div>
      </div>
   
   7. Responsive Text:
      <h1 class="text-xl md:text-3xl lg:text-4xl">Heading</h1>
   
   8. Badge:
      <span class="inline-block px-md py-xs bg-primary text-white rounded-full text-sm">Badge</span>
*/
