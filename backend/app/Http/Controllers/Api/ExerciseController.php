<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Exercise;
use Illuminate\Http\Request;

class ExerciseController extends Controller
{
    public function index(Request $request)
    {
        $query = Exercise::query();

        if ($request->filled('category')) {
            $query->where('category', $request->category);
        }
        if ($request->filled('difficulty')) {
            $query->where('difficulty', $request->difficulty);
        }
        if ($request->filled('search')) {
            $query->where('name', 'like', '%' . $request->search . '%');
        }

        return response()->json($query->orderBy('name')->get());
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'name' => 'required|string|max:255',
            'category' => 'required|in:cardio,pesas,funcional,flexibilidad,tecnica',
            'description' => 'nullable|string',
            'technique' => 'nullable|string',
            'media_url' => 'nullable|string',
            'muscle_groups' => 'nullable|array',
            'difficulty' => 'integer|min:1|max:5',
            'variations' => 'nullable|array',
        ]);

        $data['created_by'] = $request->user()->id;
        $exercise = Exercise::create($data);

        return response()->json($exercise, 201);
    }

    public function show(string $id)
    {
        return response()->json(Exercise::findOrFail($id));
    }

    public function update(Request $request, string $id)
    {
        $exercise = Exercise::findOrFail($id);

        $data = $request->validate([
            'name' => 'sometimes|string|max:255',
            'category' => 'in:cardio,pesas,funcional,flexibilidad,tecnica',
            'description' => 'nullable|string',
            'technique' => 'nullable|string',
            'media_url' => 'nullable|string',
            'muscle_groups' => 'nullable|array',
            'difficulty' => 'integer|min:1|max:5',
            'variations' => 'nullable|array',
        ]);

        $exercise->update($data);

        return response()->json($exercise);
    }

    public function destroy(string $id)
    {
        Exercise::findOrFail($id)->delete();

        return response()->json(['message' => 'Ejercicio eliminado']);
    }
}
