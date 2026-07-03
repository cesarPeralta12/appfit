<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Student extends Model
{
    protected $fillable = [
        'coach_id', 'user_id', 'name', 'birthdate', 'sex', 'age_category', 'phone', 'email', 'photo',
        'injuries_notes', 'allergies', 'pathologies', 'weight', 'height', 'body_composition',
        'level', 'goal', 'availability', 'active',
    ];

    protected $casts = [
        'birthdate' => 'date',
        'body_composition' => 'array',
        'availability' => 'array',
        'active' => 'boolean',
    ];

    public function coach(): BelongsTo
    {
        return $this->belongsTo(User::class, 'coach_id');
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    public function routines(): HasMany
    {
        return $this->hasMany(Routine::class);
    }

    public function trainingSessions(): HasMany
    {
        return $this->hasMany(TrainingSession::class);
    }

    public function injuries(): HasMany
    {
        return $this->hasMany(Injury::class);
    }

    public function progressMetrics(): HasMany
    {
        return $this->hasMany(ProgressMetric::class);
    }

    public function dietNotes(): HasMany
    {
        return $this->hasMany(DietNote::class);
    }

    public function vitalsLogs(): HasMany
    {
        return $this->hasMany(VitalsLog::class);
    }

    public function getImcAttribute(): ?float
    {
        if (! $this->weight || ! $this->height) {
            return null;
        }
        $heightMeters = $this->height / 100;
        return round($this->weight / ($heightMeters * $heightMeters), 2);
    }
}
