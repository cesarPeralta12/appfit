<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class GroupSession extends Model
{
    protected $fillable = ['coach_id', 'name', 'scheduled_at', 'duration_minutes', 'notes'];

    protected $casts = ['scheduled_at' => 'datetime'];

    public function coach(): BelongsTo
    {
        return $this->belongsTo(User::class, 'coach_id');
    }

    public function attendees(): HasMany
    {
        return $this->hasMany(GroupSessionAttendee::class);
    }

    public function trainingSessions(): HasMany
    {
        return $this->hasMany(TrainingSession::class);
    }
}
