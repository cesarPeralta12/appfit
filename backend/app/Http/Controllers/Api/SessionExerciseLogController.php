<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\SessionExercise;
use App\Models\SessionExerciseLog;
use Illuminate\Http\Request;

class SessionExerciseLogController extends Controller
{
    public function store(Request $request, string $sessionExerciseId)
    {
        $sessionExercise = SessionExercise::whereHas(
            'trainingSession',
            fn ($q) => $q->where('coach_id', $request->user()->id)
        )->findOrFail($sessionExerciseId);

        $data = $request->validate([
            'set_number' => 'required|integer',
            'reps_done' => 'nullable|integer',
            'weight_used' => 'nullable|numeric',
            'duration_seconds' => 'nullable|integer',
            'rest_seconds' => 'nullable|integer',
            'rpe' => 'nullable|integer|min:1|max:10',
            'effort' => 'nullable|in:facil,normal,dificil,muy_dificil',
            'technique_ok' => 'boolean',
            'completed' => 'boolean',
            'notes' => 'nullable|string',
        ]);

        $data['recorded_at'] = now();

        $log = $sessionExercise->logs()->create($data);

        return response()->json($log, 201);
    }

    public function update(Request $request, string $id)
    {
        $log = SessionExerciseLog::whereHas(
            'sessionExercise.trainingSession',
            fn ($q) => $q->where('coach_id', $request->user()->id)
        )->findOrFail($id);

        $data = $request->validate([
            'reps_done' => 'nullable|integer',
            'weight_used' => 'nullable|numeric',
            'duration_seconds' => 'nullable|integer',
            'rest_seconds' => 'nullable|integer',
            'rpe' => 'nullable|integer|min:1|max:10',
            'effort' => 'nullable|in:facil,normal,dificil,muy_dificil',
            'technique_ok' => 'boolean',
            'completed' => 'boolean',
            'notes' => 'nullable|string',
        ]);

        $log->update($data);

        return response()->json($log);
    }

    public function destroy(Request $request, string $id)
    {
        SessionExerciseLog::whereHas(
            'sessionExercise.trainingSession',
            fn ($q) => $q->where('coach_id', $request->user()->id)
        )->findOrFail($id)->delete();

        return response()->json(['message' => 'Registro eliminado']);
    }
}
