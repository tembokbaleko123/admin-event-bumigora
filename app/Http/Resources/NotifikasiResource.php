<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class NotifikasiResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'user_id' => $this->user_id,
            'event_id' => $this->event_id,
            'pesan' => $this->pesan,
            'status' => $this->status,
            'event' => new EventResource($this->whenLoaded('event')),
            'created_at' => $this->created_at,
        ];
    }
}
