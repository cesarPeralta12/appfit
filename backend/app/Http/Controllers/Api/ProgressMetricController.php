<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ProgressMetric;
use Illuminate\Http\Request;

class ProgressMetricController extends Controller
{
    public function index(Request $request)
    {
        $query = ProgressMetric::whereHas('student', fn ($q) => $q->where('coach_id', $request->user()->id));

        if ($request->filled('student_id')) {
            $query->where('student_id', $request->student_id);
        }
        if ($request->filled('exercise_id')) {
            $query->where('exercise_id', $request->exercise_id);
        }
        if ($request->filled('metric_type')) {
            $query->where('metric_type', $request->metric_type);
        }

        return response()->json($query->orderBy('recorded_at')->get());
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'student_id' => 'required|exists:students,id',
            'exercise_id' => 'nullable|exists:exercises,id',
            'label' => 'nullable|string|max:255',
            'metric_type' => 'required|in:weight,reps,time,bodyweight,imc,measurement',
            'value' => 'required|numeric',
            'unit' => 'nullable|string',
            'recorded_at' => 'required|date',
        ]);

        $metric = ProgressMetric::create($data);

        return response()->json($metric, 201);
    }

    public function show(Request $request, string $id)
    {
        $metric = ProgressMetric::whereHas('student', fn ($q) => $q->where('coach_id', $request->user()->id))
            ->findOrFail($id);

        return response()->json($metric);
    }

    public function update(Request $request, string $id)
    {
        $metric = ProgressMetric::whereHas('student', fn ($q) => $q->where('coach_id', $request->user()->id))
            ->findOrFail($id);

        $data = $request->validate([
            'label' => 'nullable|string|max:255',
            'value' => 'numeric',
            'unit' => 'nullable|string',
            'recorded_at' => 'date',
        ]);

        $metric->update($data);

        return response()->json($metric);
    }

    public function destroy(Request $request, string $id)
    {
        ProgressMetric::whereHas('student', fn ($q) => $q->where('coach_id', $request->user()->id))
            ->findOrFail($id)->delete();

        return response()->json(['message' => 'Metrica eliminada']);
    }
}
