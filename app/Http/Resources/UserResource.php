<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class UserResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'nama' => $this->nama,
            'email' => $this->when(
    !$request->user() ||
    $request->user()->isAdmin() ||
    $request->user()->id === $this->id,
    $this->email,
),
            'role' => $this->role,
            'created_at' => $this->created_at,
        ];
    }
}
