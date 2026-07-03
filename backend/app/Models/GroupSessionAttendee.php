<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class GroupSessionAttendee extends Model
{
    protected $fillable = ['group_session_id', 'student_id', 'attended', 'individual_notes'];

    protected $casts = ['attended' => 'boolean'];

    public function groupSession(): BelongsTo
    {
        return $this->belongsTo(GroupSession::class);
    }

    public function student(): BelongsTo
    {
        return $this->belongsTo(Student::class);
    }
}
