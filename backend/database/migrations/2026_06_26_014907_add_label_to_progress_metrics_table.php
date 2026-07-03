<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('progress_metrics', function (Blueprint $table) {
            $table->string('label')->nullable()->after('exercise_id');
        });

        DB::statement("ALTER TABLE progress_metrics MODIFY metric_type ENUM('weight','reps','time','bodyweight','imc','measurement')");
    }

    public function down(): void
    {
        Schema::table('progress_metrics', function (Blueprint $table) {
            $table->dropColumn('label');
        });
    }
};
