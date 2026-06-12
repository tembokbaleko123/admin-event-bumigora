<?php

namespace App\Enums;

enum EventStatus: string
{
    case Pending = 'pending';
    case Draft = 'draft';
    case Published = 'published';
    case Approved = 'approved';
    case Rejected = 'rejected';
    case Cancelled = 'cancelled';
}
