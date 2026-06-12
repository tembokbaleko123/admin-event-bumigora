<?php

namespace App\Traits;

use App\Models\AuditLog;

trait Auditable
{
    /**
     * Boot the auditable trait
     */
    public static function bootAuditable(): void
    {
        // Log creation
        static::created(function ($model) {
            AuditLog::log(
                AuditLog::ACTION_CREATE,
                get_class($model),
                $model->getKey(),
                null,
                $model->getAttributes()
            );
        });

        // Log update
        static::updated(function ($model) {
            $dirty = $model->getDirty();
            if (!empty($dirty)) {
                $oldValues = [];
                foreach (array_keys($dirty) as $key) {
                    $oldValues[$key] = $model->getOriginal($key);
                }
                AuditLog::log(
                    AuditLog::ACTION_UPDATE,
                    get_class($model),
                    $model->getKey(),
                    $oldValues,
                    $dirty
                );
            }
        });

        // Log deletion
        static::deleted(function ($model) {
            AuditLog::log(
                AuditLog::ACTION_DELETE,
                get_class($model),
                $model->getKey(),
                $model->getAttributes(),
                null
            );
        });
    }
}
