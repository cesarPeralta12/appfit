<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Exercise extends Model
{
    protected $fillable = [
        'created_by', 'name', 'category', 'description', 'technique',
        'media_url', 'muscle_groups', 'difficulty', 'variations',
    ];

    protected $casts = [
        'muscle_groups' => 'array',
        'variations' => 'array',
    ];

    public function creator(): BelongsTo
    {
        return $this->belongsTo(User::class, 'created_by');
    }
}
