<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\DietNoteController;
use App\Http\Controllers\Api\ExerciseController;
use App\Http\Controllers\Api\GroupSessionController;
use App\Http\Controllers\Api\InjuryController;
use App\Http\Controllers\Api\MessageThreadController;
use App\Http\Controllers\Api\ProgressMetricController;
use App\Http\Controllers\Api\ReportController;
use App\Http\Controllers\Api\RoutineController;
use App\Http\Controllers\Api\SessionExerciseLogController;
use App\Http\Controllers\Api\StudentController;
use App\Http\Controllers\Api\TrainingSessionController;
use Illuminate\Support\Facades\Route;

Route::post('/auth/register', [AuthController::class, 'register']);
Route::post('/auth/login', [AuthController::class, 'login']);

Route::middleware('auth:sanctum')->group(function () {
    Route::post('/auth/logout', [AuthController::class, 'logout']);
    Route::get('/auth/me', [AuthController::class, 'me']);
    Route::post('/auth/photo', [AuthController::class, 'uploadPhoto']);

    Route::apiResource('students', StudentController::class);
    Route::post('/students/{id}/photo', [StudentController::class, 'uploadPhoto']);
    Route::apiResource('exercises', ExerciseController::class);
    Route::apiResource('routines', RoutineController::class);

    Route::apiResource('training-sessions', TrainingSessionController::class);
    Route::post('/training-sessions/{id}/start', [TrainingSessionController::class, 'start']);
    Route::post('/training-sessions/{id}/finish', [TrainingSessionController::class, 'finish']);

    Route::post('/session-exercises/{sessionExerciseId}/logs', [SessionExerciseLogController::class, 'store']);
    Route::put('/session-exercise-logs/{id}', [SessionExerciseLogController::class, 'update']);
    Route::delete('/session-exercise-logs/{id}', [SessionExerciseLogController::class, 'destroy']);

    Route::apiResource('group-sessions', GroupSessionController::class);
    Route::post('/group-sessions/{id}/attendance', [GroupSessionController::class, 'attendance']);

    Route::apiResource('injuries', InjuryController::class);
    Route::apiResource('progress-metrics', ProgressMetricController::class);
    Route::apiResource('diet-notes', DietNoteController::class);

    Route::get('/message-threads', [MessageThreadController::class, 'index']);
    Route::post('/message-threads', [MessageThreadController::class, 'store']);
    Route::get('/message-threads/{id}', [MessageThreadController::class, 'show']);
    Route::post('/message-threads/{id}/reply', [MessageThreadController::class, 'reply']);
    Route::delete('/message-threads/{id}', [MessageThreadController::class, 'destroy']);

    Route::get('/reports/overview', [ReportController::class, 'overview']);
    Route::get('/reports/students/{id}', [ReportController::class, 'student']);
});
