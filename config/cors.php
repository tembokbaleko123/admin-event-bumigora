<?php

return [
    'paths' => ['api/*', 'sanctum/csrf-cookie'],
    'allowed_methods' => ['*'],
    'allowed_origins' => explode(',', env('CORS_ALLOWED_ORIGINS', '')),
    'allowed_origins_patterns' => [
        '~^http://localhost(:\d+)?$~',
    ],
    'allowed_headers' => ['*'],
    'exposed_headers' => ['X-Total-Count', 'X-Page-Count'],
    'max_age' => 86400,
    'supports_credentials' => env('CORS_ALLOWED_ORIGINS') ? true : false,
];
