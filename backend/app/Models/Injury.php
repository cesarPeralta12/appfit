<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Injury extends Model
{
    protected $fillable = [
        'student_id', 'description', 'date_occurred', 'restricted_exercises',
        'recovery_plan', 'status', 'notes',
    ];

    protected $casts = [
        'date_occurred' => 'date',
        'restricted_exercises' => 'array',
    ];

    public function student(): BelongsTo
    {
        return $this->belongsTo(Student::class);
    }
}
