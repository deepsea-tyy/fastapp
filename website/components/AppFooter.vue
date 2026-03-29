<template>
  <footer class="bg-gray-900 text-white mt-auto">
    <div class="container mx-auto px-4 py-8">
      <div class="grid grid-cols-1 md:grid-cols-4 gap-8">
        <div>
          <h3 class="text-xl font-bold mb-4">FastApp</h3>
          <p class="text-gray-400 text-sm">
            {{ $t('footer.description') }}
          </p>
        </div>
        <div>
          <h4 class="font-semibold mb-4">{{ $t('footer.products') }}</h4>
          <ul class="space-y-2 text-sm text-gray-400">
            <li><NuxtLink :to="localePath('/site/products')" class="hover:text-white transition">{{ $t('footer.mobile') }}</NuxtLink></li>
            <li><NuxtLink :to="localePath('/site/products')" class="hover:text-white transition">{{ $t('footer.admin') }}</NuxtLink></li>
            <li><NuxtLink :to="localePath('/site/products')" class="hover:text-white transition">{{ $t('footer.backend') }}</NuxtLink></li>
          </ul>
        </div>
        <div>
          <h4 class="font-semibold mb-4">{{ $t('footer.resources') }}</h4>
          <ul class="space-y-2 text-sm text-gray-400">
            <li><NuxtLink :to="localePath('/site/blog')" class="hover:text-white transition">{{ $t('footer.blog') }}</NuxtLink></li>
            <li><NuxtLink :to="localePath('/site/support')" class="hover:text-white transition">{{ $t('footer.support') }}</NuxtLink></li>
          </ul>
        </div>
        <div>
          <h4 class="font-semibold mb-4">{{ $t('footer.contact') }}</h4>
          <ul class="space-y-2 text-sm text-gray-400">
            <li>{{ $t('contact.email') }}: <a href="mailto:649909457@qq.com" class="hover:text-white transition">649909457@qq.com</a></li>
            <li>{{ $t('contact.telegram') }}: <a href="https://t.me/deepsea159" target="_blank" class="hover:text-white transition">@deepsea159</a></li>
          </ul>
        </div>
      </div>
      <div class="border-t border-gray-800 mt-8 pt-8 text-center text-sm text-gray-400">
        <p>&copy; {{ new Date().getFullYear() }} FastApp. {{ $t('footer.copyright') }}.</p>
      </div>
    </div>
  </footer>
</template>

<script setup lang="ts">
const localePath = useLocalePath()
</script>

