<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Routine;
use Illuminate\Http\Request;

class RoutineController extends Controller
{
    public function index(Request $request)
    {
        $query = Routine::where('coach_id', $request->user()->id)->with('exercises.exercise', 'student');

        if ($request->filled('student_id')) {
            $query->where('student_id', $request->student_id);
        }

        return response()->json($query->orderByDesc('id')->get());
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'student_id' => 'required|exists:students,id',
            'name' => 'required|string|max:255',
            'notes' => 'nullable|string',
            'exercises' => 'array',
            'exercises.*.exercise_id' => 'required_with:exercises|exists:exercises,id',
            'exercises.*.sets' => 'nullable|integer',
            'exercises.*.reps' => 'nullable|integer',
            'exercises.*.weight' => 'nullable|numeric',
            'exercises.*.duration_seconds' => 'nullable|integer',
            'exercises.*.rest_seconds' => 'nullable|integer',
            'exercises.*.notes' => 'nullable|string',
        ]);

        $routine = Routine::create([
            'student_id' => $data['student_id'],
            'coach_id' => $request->user()->id,
            'name' => $data['name'],
            'notes' => $data['notes'] ?? null,
        ]);

        foreach ($data['exercises'] ?? [] as $i => $ex) {
            $routine->exercises()->create([...$ex, 'order' => $i]);
        }

        return response()->json($routine->load('exercises.exercise'), 201);
    }

    public function show(Request $request, string $id)
    {
        $routine = Routine::where('coach_id', $request->user()->id)
            ->with('exercises.exercise', 'student')
            ->findOrFail($id);

        return response()->json($routine);
    }

    public function update(Request $request, string $id)
    {
        $routine = Routine::where('coach_id', $request->user()->id)->findOrFail($id);

        $data = $request->validate([
            'name' => 'sometimes|string|max:255',
            'notes' => 'nullable|string',
            'active' => 'boolean',
            'exercises' => 'array',
            'exercises.*.exercise_id' => 'required_with:exercises|exists:exercises,id',
            'exercises.*.sets' => 'nullable|integer',
            'exercises.*.reps' => 'nullable|integer',
            'exercises.*.weight' => 'nullable|numeric',
            'exercises.*.duration_seconds' => 'nullable|integer',
            'exercises.*.rest_seconds' => 'nullable|integer',
            'exercises.*.notes' => 'nullable|string',
        ]);

        $routine->update(collect($data)->except('exercises')->toArray());

        if ($request->has('exercises')) {
            $routine->exercises()->delete();
            foreach ($data['exercises'] as $i => $ex) {
                $routine->exercises()->create([...$ex, 'order' => $i]);
            }
        }

        return response()->json($routine->load('exercises.exercise'));
    }

    public function destroy(Request $request, string $id)
    {
        Routine::where('coach_id', $request->user()->id)->findOrFail($id)->delete();

        return response()->json(['message' => 'Rutina eliminada']);
    }
}
