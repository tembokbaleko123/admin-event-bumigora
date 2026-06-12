<div wire:init="loadStats">
    @if(!$loaded)
        <div class="row g-3 mb-4">
            @for($i = 0; $i < 4; $i++)
            <div class="col-md-3 col-6">
                <x-skeleton-card :lines="1" />
            </div>
            @endfor
        </div>
    @else
        <div class="row g-3 mb-4">
            @foreach($stats as $key => $value)
            <div class="col-md-3 col-6">
                <div class="stat-card">
                    <div class="stat-value">{{ $value }}</div>
                    <div class="stat-label">{{ Str::title(str_replace('_', ' ', $key)) }}</div>
                </div>
            </div>
            @endforeach
        </div>
    @endif
</div>
