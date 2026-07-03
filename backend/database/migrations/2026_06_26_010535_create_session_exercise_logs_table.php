<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('session_exercise_logs', function (Blueprint $table) {
            $table->id();
            $table->foreignId('session_exercise_id')->constrained('session_exercises')->cascadeOnDelete();
            $table->unsignedInteger('set_number')->default(1);
            $table->unsignedInteger('reps_done')->nullable();
            $table->decimal('weight_used', 6, 2)->nullable();
            $table->unsignedInteger('duration_seconds')->nullable();
            $table->unsignedInteger('rest_seconds')->nullable();
            $table->tinyInteger('rpe')->nullable();
            $table->enum('effort', ['facil', 'normal', 'dificil', 'muy_dificil'])->nullable();
            $table->boolean('technique_ok')->default(true);
            $table->boolean('completed')->default(false);
            $table->text('notes')->nullable();
            $table->dateTime('recorded_at')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('session_exercise_logs');
    }
};
