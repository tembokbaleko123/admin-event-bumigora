<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class UserInterest extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'category',
        'score',
    ];

    protected function casts(): array
    {
        return [
            'score' => 'integer',
        ];
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function scopeByUser($query, int $userId)
    {
        return $query->where('user_id', $userId);
    }

    public static function trackInterest(int $userId, string $category, int $increment = 1): void
    {
        $interest = self::byUser($userId)->where('category', $category)->first();

        if ($interest) {
            $interest->increment('score', $increment);
        } else {
            self::create([
                'user_id' => $userId,
                'category' => $category,
                'score' => $increment,
            ]);
        }
    }

    public static function getTopCategories(int $userId, int $limit = 3): array
    {
        return self::byUser($userId)
            ->orderByDesc('score')
            ->limit($limit)
            ->pluck('category')
            ->toArray();
    }
}
