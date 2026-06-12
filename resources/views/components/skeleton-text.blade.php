@props(['lines' => 3, 'width' => 100])
<div {{ $attributes }}>
    @for($i = 0; $i < $lines; $i++)
    <div style="width: {{ $i === $lines - 1 ? min(60, $width) : $width }}%; height:12px; margin-bottom:8px; background: linear-gradient(90deg, var(--gray-200, #e2e8f0) 25%, var(--gray-100, #f1f5f9) 50%, var(--gray-200, #e2e8f0) 75%); background-size: 200% 100%; animation: skeleton-shimmer 1.5s ease-in-out infinite; border-radius:6px;"></div>
    @endfor
</div>
