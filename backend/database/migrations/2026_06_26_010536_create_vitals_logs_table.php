<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('vitals_logs', function (Blueprint $table) {
            $table->id();
            $table->foreignId('training_session_id')->nullable()->constrained('training_sessions')->cascadeOnDelete();
            $table->foreignId('student_id')->constrained('students')->cascadeOnDelete();
            $table->unsignedInteger('heart_rate_start')->nullable();
            $table->unsignedInteger('heart_rate_end')->nullable();
            $table->string('blood_pressure')->nullable();
            $table->tinyInteger('rpe')->nullable();
            $table->dateTime('recorded_at');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('vitals_logs');
    }
};
