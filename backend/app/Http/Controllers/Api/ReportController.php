<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Student;
use App\Models\TrainingSession;
use Illuminate\Http\Request;

class ReportController extends Controller
{
    public function student(Request $request, string $id)
    {
        $student = Student::where('coach_id', $request->user()->id)->findOrFail($id);

        $sessions = TrainingSession::where('student_id', $student->id)->get();
        $total = $sessions->count();
        $completed = $sessions->where('status', 'completed')->count();
        $missed = $sessions->where('status', 'missed')->count();

        $weightProgress = $student->progressMetrics()->where('metric_type', 'weight')->orderBy('recorded_at')->get();
        $bodyweightProgress = $student->progressMetrics()->where('metric_type', 'bodyweight')->orderBy('recorded_at')->get();

        return response()->json([
            'student' => $student,
            'attendance' => [
                'total_sessions' => $total,
                'completed' => $completed,
                'missed' => $missed,
                'rate' => $total > 0 ? round($completed / $total * 100, 1) : 0,
            ],
            'weight_progress' => $weightProgress,
            'bodyweight_progress' => $bodyweightProgress,
            'active_injuries' => $student->injuries()->where('status', '!=', 'recovered')->get(),
        ]);
    }

    public function overview(Request $request)
    {
        $coachId = $request->user()->id;

        $students = Student::where('coach_id', $coachId)->get();
        $sessions = TrainingSession::where('coach_id', $coachId)->get();

        return response()->json([
            'total_students' => $students->count(),
            'active_students' => $students->where('active', true)->count(),
            'by_level' => $students->groupBy('level')->map->count(),
            'sessions_this_month' => $sessions->where('scheduled_at', '>=', now()->startOfMonth())->count(),
            'completed_this_month' => $sessions->where('status', 'completed')
                ->where('scheduled_at', '>=', now()->startOfMonth())->count(),
        ]);
    }
}
