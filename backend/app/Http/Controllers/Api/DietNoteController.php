<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\DietNote;
use Illuminate\Http\Request;

class DietNoteController extends Controller
{
    public function index(Request $request)
    {
        $query = DietNote::whereHas('student', fn ($q) => $q->where('coach_id', $request->user()->id));

        if ($request->filled('student_id')) {
            $query->where('student_id', $request->student_id);
        }

        return response()->json($query->orderByDesc('date')->get());
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'student_id' => 'required|exists:students,id',
            'type' => 'in:habit,hydration,goal',
            'note' => 'required|string',
            'date' => 'required|date',
        ]);

        $note = DietNote::create($data);

        return response()->json($note, 201);
    }

    public function show(Request $request, string $id)
    {
        $note = DietNote::whereHas('student', fn ($q) => $q->where('coach_id', $request->user()->id))
            ->findOrFail($id);

        return response()->json($note);
    }

    public function update(Request $request, string $id)
    {
        $note = DietNote::whereHas('student', fn ($q) => $q->where('coach_id', $request->user()->id))
            ->findOrFail($id);

        $data = $request->validate([
            'type' => 'in:habit,hydration,goal',
            'note' => 'string',
            'date' => 'date',
        ]);

        $note->update($data);

        return response()->json($note);
    }

    public function destroy(Request $request, string $id)
    {
        DietNote::whereHas('student', fn ($q) => $q->where('coach_id', $request->user()->id))
            ->findOrFail($id)->delete();

        return response()->json(['message' => 'Nota eliminada']);
    }
}
