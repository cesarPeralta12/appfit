<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ProgressMetric extends Model
{
    protected $fillable = ['student_id', 'exercise_id', 'label', 'metric_type', 'value', 'unit', 'recorded_at'];

    protected $casts = ['recorded_at' => 'date'];

    public function student(): BelongsTo
    {
        return $this->belongsTo(Student::class);
    }

    public function exercise(): BelongsTo
    {
        return $this->belongsTo(Exercise::class);
    }
}
