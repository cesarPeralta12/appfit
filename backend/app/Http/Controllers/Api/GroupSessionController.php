<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\GroupSession;
use Illuminate\Http\Request;

class GroupSessionController extends Controller
{
    public function index(Request $request)
    {
        $sessions = GroupSession::where('coach_id', $request->user()->id)
            ->with('attendees.student')
            ->orderBy('scheduled_at')
            ->get();

        return response()->json($sessions);
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'name' => 'required|string|max:255',
            'scheduled_at' => 'required|date',
            'duration_minutes' => 'nullable|integer',
            'notes' => 'nullable|string',
            'student_ids' => 'array',
            'student_ids.*' => 'exists:students,id',
        ]);

        $session = GroupSession::create([
            ...collect($data)->except('student_ids')->toArray(),
            'coach_id' => $request->user()->id,
        ]);

        foreach ($data['student_ids'] ?? [] as $studentId) {
            $session->attendees()->create(['student_id' => $studentId]);
        }

        return response()->json($session->load('attendees.student'), 201);
    }

    public function show(Request $request, string $id)
    {
        $session = GroupSession::where('coach_id', $request->user()->id)
            ->with('attendees.student', 'trainingSessions.exercises.exercise')
            ->findOrFail($id);

        return response()->json($session);
    }

    public function update(Request $request, string $id)
    {
        $session = GroupSession::where('coach_id', $request->user()->id)->findOrFail($id);

        $data = $request->validate([
            'name' => 'sometimes|string|max:255',
            'scheduled_at' => 'date',
            'duration_minutes' => 'nullable|integer',
            'notes' => 'nullable|string',
        ]);

        $session->update($data);

        return response()->json($session);
    }

    public function destroy(Request $request, string $id)
    {
        GroupSession::where('coach_id', $request->user()->id)->findOrFail($id)->delete();

        return response()->json(['message' => 'Sesion grupal eliminada']);
    }

    public function attendance(Request $request, string $id)
    {
        $session = GroupSession::where('coach_id', $request->user()->id)->findOrFail($id);

        $data = $request->validate([
            'attendees' => 'required|array',
            'attendees.*.student_id' => 'required|exists:students,id',
            'attendees.*.attended' => 'boolean',
            'attendees.*.individual_notes' => 'nullable|string',
        ]);

        foreach ($data['attendees'] as $a) {
            $session->attendees()->updateOrCreate(
                ['student_id' => $a['student_id']],
                ['attended' => $a['attended'] ?? false, 'individual_notes' => $a['individual_notes'] ?? null]
            );
        }

        return response()->json($session->load('attendees.student'));
    }
}
