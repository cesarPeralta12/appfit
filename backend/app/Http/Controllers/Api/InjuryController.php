<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Injury;
use Illuminate\Http\Request;

class InjuryController extends Controller
{
    public function index(Request $request)
    {
        $query = Injury::whereHas('student', fn ($q) => $q->where('coach_id', $request->user()->id));

        if ($request->filled('student_id')) {
            $query->where('student_id', $request->student_id);
        }
        if ($request->filled('status')) {
            $query->where('status', $request->status);
        }

        return response()->json($query->orderByDesc('date_occurred')->get());
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'student_id' => 'required|exists:students,id',
            'description' => 'required|string',
            'date_occurred' => 'required|date',
            'restricted_exercises' => 'nullable|array',
            'recovery_plan' => 'nullable|string',
            'status' => 'in:active,recovering,recovered',
            'notes' => 'nullable|string',
        ]);

        $injury = Injury::create($data);

        return response()->json($injury, 201);
    }

    public function show(Request $request, string $id)
    {
        $injury = Injury::whereHas('student', fn ($q) => $q->where('coach_id', $request->user()->id))
            ->findOrFail($id);

        return response()->json($injury);
    }

    public function update(Request $request, string $id)
    {
        $injury = Injury::whereHas('student', fn ($q) => $q->where('coach_id', $request->user()->id))
            ->findOrFail($id);

        $data = $request->validate([
            'description' => 'sometimes|string',
            'date_occurred' => 'date',
            'restricted_exercises' => 'nullable|array',
            'recovery_plan' => 'nullable|string',
            'status' => 'in:active,recovering,recovered',
            'notes' => 'nullable|string',
        ]);

        $injury->update($data);

        return response()->json($injury);
    }

    public function destroy(Request $request, string $id)
    {
        Injury::whereHas('student', fn ($q) => $q->where('coach_id', $request->user()->id))
            ->findOrFail($id)->delete();

        return response()->json(['message' => 'Lesion eliminada']);
    }
}
