<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class SessionExerciseLog extends Model
{
    protected $fillable = [
        'session_exercise_id', 'set_number', 'reps_done', 'weight_used',
        'duration_seconds', 'rest_seconds', 'rpe', 'effort', 'technique_ok',
        'completed', 'notes', 'recorded_at',
    ];

    protected $casts = [
        'technique_ok' => 'boolean',
        'completed' => 'boolean',
        'recorded_at' => 'datetime',
    ];

    public function sessionExercise(): BelongsTo
    {
        return $this->belongsTo(SessionExercise::class);
    }
}
