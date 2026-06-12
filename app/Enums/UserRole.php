<?php

namespace App\Enums;

enum UserRole: string
{
    case Admin = 'admin';
    case Mahasiswa = 'mahasiswa';
    case Dosen = 'dosen';

    public function label(): string
    {
        return match($this) {
            self::Admin => 'Admin',
            self::Mahasiswa => 'Mahasiswa',
            self::Dosen => 'Dosen',
        };
    }
}
