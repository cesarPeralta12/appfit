<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Student;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class StudentController extends Controller
{
    public function index(Request $request)
    {
        $query = $request->user()->students();

        if ($request->filled('level')) {
            $query->where('level', $request->level);
        }
        if ($request->filled('goal')) {
            $query->where('goal', 'like', '%' . $request->goal . '%');
        }
        if ($request->filled('age_category')) {
            $query->where('age_category', $request->age_category);
        }
        if ($request->filled('search')) {
            $query->where('name', 'like', '%' . $request->search . '%');
        }
        if ($request->boolean('active_only')) {
            $query->where('active', true);
        }

        return response()->json($query->orderBy('name')->get());
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'name' => 'required|string|max:255',
            'birthdate' => 'nullable|date',
            'sex' => 'nullable|in:male,female,other',
            'age_category' => 'in:nino,joven,adulto',
            'phone' => 'nullable|string',
            'email' => 'nullable|email',
            'photo' => 'nullable|string',
            'injuries_notes' => 'nullable|string',
            'allergies' => 'nullable|string',
            'pathologies' => 'nullable|string',
            'weight' => 'nullable|numeric',
            'height' => 'nullable|numeric',
            'body_composition' => 'nullable|array',
            'level' => 'in:beginner,intermediate,advanced',
            'goal' => 'nullable|string',
            'availability' => 'nullable|array',
        ]);

        $student = $request->user()->students()->create($data);

        return response()->json($student, 201);
    }

    public function show(Request $request, string $id)
    {
        $student = $request->user()->students()
            ->with(['routines.exercises.exercise', 'injuries', 'progressMetrics', 'dietNotes'])
            ->findOrFail($id);

        return response()->json($student);
    }

    public function update(Request $request, string $id)
    {
        $student = $request->user()->students()->findOrFail($id);

        $data = $request->validate([
            'name' => 'sometimes|string|max:255',
            'birthdate' => 'nullable|date',
            'sex' => 'nullable|in:male,female,other',
            'age_category' => 'in:nino,joven,adulto',
            'phone' => 'nullable|string',
            'email' => 'nullable|email',
            'photo' => 'nullable|string',
            'injuries_notes' => 'nullable|string',
            'allergies' => 'nullable|string',
            'pathologies' => 'nullable|string',
            'weight' => 'nullable|numeric',
            'height' => 'nullable|numeric',
            'body_composition' => 'nullable|array',
            'level' => 'in:beginner,intermediate,advanced',
            'goal' => 'nullable|string',
            'availability' => 'nullable|array',
            'active' => 'boolean',
        ]);

        $student->update($data);

        return response()->json($student);
    }

    public function destroy(Request $request, string $id)
    {
        $student = $request->user()->students()->findOrFail($id);
        $student->delete();

        return response()->json(['message' => 'Alumno eliminado']);
    }

    public function uploadPhoto(Request $request, string $id)
    {
        $student = $request->user()->students()->findOrFail($id);

        $request->validate([
            'photo' => 'required|image|max:5120',
        ]);

        if ($student->photo) {
            $oldPath = str_replace('/storage/', '', $student->photo);
            Storage::disk('public')->delete($oldPath);
        }

        $path = $request->file('photo')->store('students', 'public');
        $student->update(['photo' => Storage::url($path)]);

        return response()->json($student);
    }
}
