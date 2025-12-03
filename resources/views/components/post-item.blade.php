<div class="bg-white block border border-default rounded-base shadow-xs flex mb-8">
    <div class="p-5 flex-1">
        <h5 class="mb-3 text-2xl font-semibold tracking-tight text-heading leading-8">
            {{ $post->title }}</h5>
        <p class="text-body mb-6">{{ Str::words($post->content, 20) }}
        </p>
        <a href="#">
            <x-primary-button>
                Read more
                <svg class="w-4 h-4 ms-1.5 rtl:rotate-180 -me-0.5" aria-hidden="true" xmlns="http://www.w3.org/2000/svg"
                    width="24" height="24" fill="none" viewBox="0 0 24 24">
                    <path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                        d="M19 12H5m14 0-4 4m4-4-4-4" />
                </svg>
            </x-primary-button>

        </a>
    </div>
    <a href="#">
        <img class="rounded-r-lg w-48 h-full max-h-64 object-cover" src="{{ Storage::url($post->image) }}" alt="">
    </a>
</div>
