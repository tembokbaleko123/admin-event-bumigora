<?php

namespace Tests\Feature\Api;

use Tests\TestCase;

class CorsPreflightTest extends TestCase
{
    public function test_api_preflight_request_returns_cors_headers(): void
    {
        $this->app['config']->set('cors.allowed_origins', ['http://localhost:5173']);
        $this->app['config']->set('cors.supports_credentials', true);

        $server = $this->transformHeadersToServerVars([
            'Origin' => 'http://localhost:5173',
            'Access-Control-Request-Method' => 'POST',
            'Access-Control-Request-Headers' => 'Authorization, Content-Type',
        ]);

        $response = $this->call('OPTIONS', '/api/v1/events', [], [], [], $server);

        $response->assertNoContent();
        $response->assertHeader('Access-Control-Allow-Origin', 'http://localhost:5173');
        $response->assertHeader('Access-Control-Allow-Credentials', 'true');
    }
}
