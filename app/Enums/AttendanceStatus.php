<?php

namespace App\Enums;

enum AttendanceStatus: string
{
    case Valid = 'valid';
    case Late = 'late';
    case Invalid = 'invalid';
}
