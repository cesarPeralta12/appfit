<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('exercises', function (Blueprint $table) {
            $table->id();
            $table->foreignId('created_by')->nullable()->constrained('users')->nullOnDelete();
            $table->string('name');
            $table->enum('category', ['cardio', 'pesas', 'funcional', 'flexibilidad', 'tecnica'])->default('pesas');
            $table->text('description')->nullable();
            $table->text('technique')->nullable();
            $table->string('media_url')->nullable();
            $table->json('muscle_groups')->nullable();
            $table->tinyInteger('difficulty')->default(1);
            $table->json('variations')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('exercises');
    }
};
