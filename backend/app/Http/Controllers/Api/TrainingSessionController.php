<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\TrainingSession;
use Illuminate\Http\Request;

class TrainingSessionController extends Controller
{
    public function index(Request $request)
    {
        $query = TrainingSession::where('coach_id', $request->user()->id)->with('student', 'exercises.exercise');

        if ($request->filled('student_id')) {
            $query->where('student_id', $request->student_id);
        }
        if ($request->filled('status')) {
            $query->where('status', $request->status);
        }
        if ($request->filled('from')) {
            $query->where('scheduled_at', '>=', $request->from);
        }
        if ($request->filled('to')) {
            $query->where('scheduled_at', '<=', $request->to);
        }

        return response()->json($query->orderBy('scheduled_at')->get());
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'student_id' => 'nullable|exists:students,id',
            'group_session_id' => 'nullable|exists:group_sessions,id',
            'type' => 'required|in:fuerza,cardio,mixta,recuperacion',
            'scheduled_at' => 'required|date',
            'duration_minutes' => 'nullable|integer',
            'notes' => 'nullable|string',
            'exercises' => 'array',
            'exercises.*.exercise_id' => 'required_with:exercises|exists:exercises,id',
            'exercises.*.planned_sets' => 'nullable|integer',
            'exercises.*.planned_reps' => 'nullable|integer',
            'exercises.*.planned_weight' => 'nullable|numeric',
            'exercises.*.planned_duration_seconds' => 'nullable|integer',
            'exercises.*.notes' => 'nullable|string',
        ]);

        $session = TrainingSession::create([
            ...collect($data)->except('exercises')->toArray(),
            'coach_id' => $request->user()->id,
        ]);

        foreach ($data['exercises'] ?? [] as $i => $ex) {
            $session->exercises()->create([...$ex, 'order' => $i]);
        }

        return response()->json($session->load('exercises.exercise'), 201);
    }

    public function show(Request $request, string $id)
    {
        $session = TrainingSession::where('coach_id', $request->user()->id)
            ->with('exercises.exercise', 'exercises.logs', 'student', 'vitalsLogs')
            ->findOrFail($id);

        return response()->json($session);
    }

    public function update(Request $request, string $id)
    {
        $session = TrainingSession::where('coach_id', $request->user()->id)->findOrFail($id);

        $data = $request->validate([
            'type' => 'in:fuerza,cardio,mixta,recuperacion',
            'scheduled_at' => 'date',
            'duration_minutes' => 'nullable|integer',
            'notes' => 'nullable|string',
            'status' => 'in:planned,completed,missed,cancelled',
            'started_at' => 'nullable|date',
            'finished_at' => 'nullable|date',
        ]);

        $session->update($data);

        return response()->json($session->load('exercises.exercise', 'exercises.logs'));
    }

    public function destroy(Request $request, string $id)
    {
        TrainingSession::where('coach_id', $request->user()->id)->findOrFail($id)->delete();

        return response()->json(['message' => 'Sesion eliminada']);
    }

    public function start(Request $request, string $id)
    {
        $session = TrainingSession::where('coach_id', $request->user()->id)->findOrFail($id);
        $session->update(['started_at' => now()]);

        return response()->json($session);
    }

    public function finish(Request $request, string $id)
    {
        $session = TrainingSession::where('coach_id', $request->user()->id)->findOrFail($id);
        $session->update(['finished_at' => now(), 'status' => 'completed']);

        return response()->json($session);
    }
}
