<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class TrainingSession extends Model
{
    protected $fillable = [
        'student_id', 'coach_id', 'group_session_id', 'type', 'scheduled_at',
        'duration_minutes', 'notes', 'status', 'started_at', 'finished_at',
    ];

    protected $casts = [
        'scheduled_at' => 'datetime',
        'started_at' => 'datetime',
        'finished_at' => 'datetime',
    ];

    public function student(): BelongsTo
    {
        return $this->belongsTo(Student::class);
    }

    public function coach(): BelongsTo
    {
        return $this->belongsTo(User::class, 'coach_id');
    }

    public function groupSession(): BelongsTo
    {
        return $this->belongsTo(GroupSession::class);
    }

    public function exercises(): HasMany
    {
        return $this->hasMany(SessionExercise::class)->orderBy('order');
    }

    public function vitalsLogs(): HasMany
    {
        return $this->hasMany(VitalsLog::class);
    }
}
