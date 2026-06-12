<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class EventResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'judul' => $this->judul,
            'tanggal' => $this->tanggal,
            'tanggal_selesai' => $this->tanggal_selesai,
            'batas_daftar' => $this->batas_daftar,
            'lokasi' => $this->lokasi,
            'deskripsi' => $this->deskripsi,
            'kategori' => $this->kategori,
            'kapasitas' => $this->kapasitas,
            'status' => $this->status,
            'gambar' => $this->gambar,
            'gambar_url' => $this->gambar_url,
            'sisa_kuota' => $this->sisa_kuota,
            'total_pendaftar' => $this->when($this->total_pendaftar !== null, $this->total_pendaftar),
            'pendaftar_aktif' => $this->when($this->pendaftar_aktif !== null, $this->pendaftar_aktif),
            'created_by' => $this->created_by,
            'creator' => new UserResource($this->whenLoaded('creator')),
            'confirmed_registrations_count' => $this->when($this->confirmed_registrations_count !== null, $this->confirmed_registrations_count),
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}
