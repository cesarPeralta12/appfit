<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class SessionExercise extends Model
{
    protected $fillable = [
        'training_session_id', 'exercise_id', 'planned_sets', 'planned_reps',
        'planned_weight', 'planned_duration_seconds', 'order', 'notes',
    ];

    public function trainingSession(): BelongsTo
    {
        return $this->belongsTo(TrainingSession::class);
    }

    public function exercise(): BelongsTo
    {
        return $this->belongsTo(Exercise::class);
    }

    public function logs(): HasMany
    {
        return $this->hasMany(SessionExerciseLog::class)->orderBy('set_number');
    }
}
