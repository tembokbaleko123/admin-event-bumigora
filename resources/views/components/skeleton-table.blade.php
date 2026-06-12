@props(['rows' => 5, 'cols' => 4])
<div {{ $attributes->merge(['class' => 'skeleton-table']) }}>
    @for($i = 0; $i < $rows; $i++)
    <div class="skeleton-row" style="display:flex; gap:12px; padding:12px 0; border-bottom:1px solid var(--border-color, #e2e8f0);">
        @for($j = 0; $j < $cols; $j++)
        <div class="skeleton-cell" style="flex:1; height:16px; background: linear-gradient(90deg, var(--gray-200, #e2e8f0) 25%, var(--gray-100, #f1f5f9) 50%, var(--gray-200, #e2e8f0) 75%); background-size: 200% 100%; animation: skeleton-shimmer 1.5s ease-in-out infinite; border-radius:6px;"></div>
        @endfor
    </div>
    @endfor
</div>
