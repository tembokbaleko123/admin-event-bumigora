<?php

namespace App\Enums;

enum RegistrationStatus: string
{
    case Registered = 'registered';
    case Attended = 'attended';
    case Absent = 'absent';
    case Cancelled = 'cancelled';
}
