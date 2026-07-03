<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class VitalsLog extends Model
{
    protected $fillable = [
        'training_session_id', 'student_id', 'heart_rate_start', 'heart_rate_end',
        'blood_pressure', 'rpe', 'recorded_at',
    ];

    protected $casts = ['recorded_at' => 'datetime'];

    public function trainingSession(): BelongsTo
    {
        return $this->belongsTo(TrainingSession::class);
    }

    public function student(): BelongsTo
    {
        return $this->belongsTo(Student::class);
    }
}
