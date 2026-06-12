@props(['lines' => 3])
<div {{ $attributes->merge(['class' => 'skeleton-card', 'style' => 'padding:20px; border-radius:12px; background:var(--card-bg, #fff); border:1px solid var(--border-color, #e2e8f0);']) }}>
    <div style="display:flex; align-items:center; gap:12px; margin-bottom:16px;">
        <div class="skeleton-avatar" style="width:44px; height:44px; border-radius:50%; background: linear-gradient(90deg, var(--gray-200, #e2e8f0) 25%, var(--gray-100, #f1f5f9) 50%, var(--gray-200, #e2e8f0) 75%); background-size: 200% 100%; animation: skeleton-shimmer 1.5s ease-in-out infinite;"></div>
        <div style="flex:1;">
            <div style="width:60%; height:14px; background: linear-gradient(90deg, var(--gray-200, #e2e8f0) 25%, var(--gray-100, #f1f5f9) 50%, var(--gray-200, #e2e8f0) 75%); background-size: 200% 100%; animation: skeleton-shimmer 1.5s ease-in-out infinite; border-radius:6px; margin-bottom:8px;"></div>
            <div style="width:40%; height:10px; background: linear-gradient(90deg, var(--gray-200, #e2e8f0) 25%, var(--gray-100, #f1f5f9) 50%, var(--gray-200, #e2e8f0) 75%); background-size: 200% 100%; animation: skeleton-shimmer 1.5s ease-in-out infinite; border-radius:6px;"></div>
        </div>
    </div>
    @for($i = 0; $i < $lines; $i++)
    <div style="width: {{ rand(70, 100) }}%; height:12px; margin-bottom:8px; background: linear-gradient(90deg, var(--gray-200, #e2e8f0) 25%, var(--gray-100, #f1f5f9) 50%, var(--gray-200, #e2e8f0) 75%); background-size: 200% 100%; animation: skeleton-shimmer 1.5s ease-in-out infinite; border-radius:6px;"></div>
    @endfor
</div>
