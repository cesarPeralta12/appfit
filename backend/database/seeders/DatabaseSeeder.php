<?php

namespace Database\Seeders;

use App\Models\DietNote;
use App\Models\Exercise;
use App\Models\Injury;
use App\Models\ProgressMetric;
use App\Models\Routine;
use App\Models\Student;
use App\Models\TrainingSession;
use App\Models\User;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    public function run(): void
    {
        $coach = User::create([
            'name' => 'Entrenador Demo',
            'email' => 'coach@gymapp.test',
            'password' => Hash::make('password'),
            'role' => 'coach',
            'phone' => '+54 9 11 0000-0000',
        ]);

        $exercisesData = [
            ['name' => 'Sentadilla con barra', 'category' => 'pesas', 'muscle_groups' => ['cuadriceps', 'gluteos'], 'difficulty' => 3,
                'description' => 'Ejercicio basico de fuerza para piernas y gluteos, base de cualquier rutina de tren inferior.',
                'technique' => 'Pies al ancho de hombros, espalda recta, bajar hasta que los muslos queden paralelos al piso, empujar con los talones al subir.'],
            ['name' => 'Peso muerto', 'category' => 'pesas', 'muscle_groups' => ['espalda', 'femorales'], 'difficulty' => 4,
                'description' => 'Ejercicio compuesto que fortalece cadena posterior completa: espalda baja, gluteos y femorales.',
                'technique' => 'Barra cerca de las espinillas, espalda neutra, empujar el piso con las piernas mientras la barra sube pegada al cuerpo.'],
            ['name' => 'Press de banca', 'category' => 'pesas', 'muscle_groups' => ['pecho', 'triceps'], 'difficulty' => 3,
                'description' => 'Ejercicio clasico para desarrollar fuerza y volumen en el pecho, hombros y triceps.',
                'technique' => 'Escapulas retraidas, bajar la barra controlada hasta el pecho y empujar sin despegar gluteos del banco.'],
            ['name' => 'Dominadas', 'category' => 'pesas', 'muscle_groups' => ['espalda', 'biceps'], 'difficulty' => 4,
                'description' => 'Ejercicio de traccion vertical para espalda y biceps, requiere buena fuerza relativa.',
                'technique' => 'Agarre prono al ancho de hombros, subir hasta que el menton supere la barra, bajar controlado sin balanceo.'],
            ['name' => 'Plancha abdominal', 'category' => 'funcional', 'muscle_groups' => ['core'], 'difficulty' => 2,
                'description' => 'Ejercicio isometrico para fortalecer el core y mejorar la estabilidad de la zona media.',
                'technique' => 'Apoyo en antebrazos y puntas de pie, cuerpo en linea recta, sin elevar ni hundir la cadera.'],
            ['name' => 'Burpees', 'category' => 'funcional', 'muscle_groups' => ['full body'], 'difficulty' => 3,
                'description' => 'Ejercicio funcional de alta intensidad que combina fuerza y cardio en un solo movimiento.',
                'technique' => 'Sentadilla, apoyo de manos, flexion, salto a sentadilla y salto vertical final. Mantener ritmo constante.'],
            ['name' => 'Carrera continua', 'category' => 'cardio', 'muscle_groups' => ['piernas', 'cardiovascular'], 'difficulty' => 2,
                'description' => 'Trabajo cardiovascular de baja-media intensidad para mejorar la resistencia aerobica.',
                'technique' => 'Ritmo constante y conversable, pisada media, brazos relajados acompañando el movimiento.'],
            ['name' => 'Salto a la cuerda', 'category' => 'cardio', 'muscle_groups' => ['piernas', 'cardiovascular'], 'difficulty' => 2,
                'description' => 'Ejercicio cardiovascular que mejora coordinacion, ritmo y capacidad aerobica.',
                'technique' => 'Saltos cortos sobre la punta de los pies, muñecas haciendo el giro, mirada al frente.'],
            ['name' => 'Estiramiento de isquiotibiales', 'category' => 'flexibilidad', 'muscle_groups' => ['femorales'], 'difficulty' => 1,
                'description' => 'Estiramiento estatico para mejorar la flexibilidad de la parte posterior del muslo.',
                'technique' => 'Sentado o de pie, pierna extendida, inclinar el torso al frente manteniendo la espalda recta, sostener 20-30s.'],
            ['name' => 'Movilidad de hombros', 'category' => 'flexibilidad', 'muscle_groups' => ['hombros'], 'difficulty' => 1,
                'description' => 'Ejercicio de movilidad articular para prevenir lesiones de hombro y mejorar el rango de movimiento.',
                'technique' => 'Circulos amplios de brazos, movimientos lentos y controlados en ambas direcciones.'],
            ['name' => 'Zancadas con mancuernas', 'category' => 'pesas', 'muscle_groups' => ['cuadriceps', 'gluteos'], 'difficulty' => 2,
                'description' => 'Ejercicio unilateral que mejora fuerza, equilibrio y simetria entre ambas piernas.',
                'technique' => 'Paso al frente, rodilla de atras casi toca el piso, tronco erguido, volver con impulso del talon delantero.'],
            ['name' => 'Remo con barra', 'category' => 'pesas', 'muscle_groups' => ['espalda'], 'difficulty' => 3,
                'description' => 'Ejercicio de traccion horizontal para desarrollar grosor de espalda.',
                'technique' => 'Torso inclinado 45 grados, espalda recta, llevar la barra hacia el abdomen apretando escapulas.'],
        ];

        $exercises = [];
        foreach ($exercisesData as $ex) {
            $exercises[] = Exercise::create([...$ex, 'created_by' => $coach->id]);
        }

        $studentsData = [
            ['name' => 'Lucia Fernandez', 'level' => 'beginner', 'goal' => 'Perdida de peso', 'sex' => 'female',
                'age_category' => 'adulto', 'weight' => 68, 'height' => 165, 'birthdate' => '1995-03-12',
                'phone' => '+54 9 11 5551-0001',
                'availability' => [
                    ['day' => 'mon', 'start' => '18:00', 'end' => '19:00'],
                    ['day' => 'wed', 'start' => '18:00', 'end' => '19:00'],
                    ['day' => 'fri', 'start' => '09:00', 'end' => '10:00'],
                ]],
            ['name' => 'Martin Gomez', 'level' => 'intermediate', 'goal' => 'Ganancia muscular', 'sex' => 'male',
                'age_category' => 'joven', 'weight' => 78, 'height' => 178, 'birthdate' => '2005-07-20',
                'phone' => '+54 9 11 5551-0002',
                'availability' => [
                    ['day' => 'tue', 'start' => '19:00', 'end' => '20:00'],
                    ['day' => 'thu', 'start' => '19:00', 'end' => '20:00'],
                    ['day' => 'sat', 'start' => '10:00', 'end' => '11:00'],
                ]],
            ['name' => 'Sofia Ruiz', 'level' => 'advanced', 'goal' => 'Resistencia', 'sex' => 'female',
                'age_category' => 'adulto', 'weight' => 60, 'height' => 162, 'birthdate' => '1990-11-02',
                'phone' => '+54 9 11 5551-0003',
                'availability' => [
                    ['day' => 'mon', 'start' => '07:00', 'end' => '08:00'],
                    ['day' => 'wed', 'start' => '07:00', 'end' => '08:00'],
                    ['day' => 'fri', 'start' => '07:00', 'end' => '08:00'],
                ]],
            ['name' => 'Tomas Lopez', 'level' => 'beginner', 'goal' => 'Iniciacion deportiva', 'sex' => 'male',
                'age_category' => 'nino', 'weight' => 42, 'height' => 150, 'birthdate' => '2014-05-15',
                'phone' => '+54 9 11 5551-0004',
                'availability' => [
                    ['day' => 'tue', 'start' => '17:00', 'end' => '17:45'],
                    ['day' => 'thu', 'start' => '17:00', 'end' => '17:45'],
                ]],
        ];

        $students = [];
        foreach ($studentsData as $s) {
            $students[] = Student::create([...$s, 'coach_id' => $coach->id]);
        }

        [$lucia, $martin, $sofia, $tomas] = $students;

        $exByName = collect($exercises)->keyBy('name');

        $routine1 = Routine::create(['student_id' => $lucia->id, 'coach_id' => $coach->id, 'name' => 'Full body principiante', 'notes' => 'Enfoque en tecnica y resistencia general.']);
        $this->addExercises($routine1, [
            [$exByName['Sentadilla con barra'], 3, 12, 20, null, 60],
            [$exByName['Plancha abdominal'], 3, null, null, 30, 45],
            [$exByName['Carrera continua'], 1, null, null, 900, 0],
        ]);

        $routine2 = Routine::create(['student_id' => $martin->id, 'coach_id' => $coach->id, 'name' => 'Hipertrofia tren superior', 'notes' => 'Progresion de cargas semanal.']);
        $this->addExercises($routine2, [
            [$exByName['Press de banca'], 4, 10, 60, null, 90],
            [$exByName['Dominadas'], 4, 8, null, null, 90],
            [$exByName['Remo con barra'], 3, 10, 40, null, 75],
        ]);

        $routine3 = Routine::create(['student_id' => $sofia->id, 'coach_id' => $coach->id, 'name' => 'Resistencia avanzada', 'notes' => 'Circuitos de alta intensidad.']);
        $this->addExercises($routine3, [
            [$exByName['Burpees'], 4, 15, null, null, 30],
            [$exByName['Salto a la cuerda'], 4, null, null, 60, 30],
            [$exByName['Zancadas con mancuernas'], 3, 12, 10, null, 45],
        ]);

        $routine4 = Routine::create(['student_id' => $tomas->id, 'coach_id' => $coach->id, 'name' => 'Iniciacion ludica', 'notes' => 'Ejercicios cortos y dinamicos, con descansos amplios.']);
        $this->addExercises($routine4, [
            [$exByName['Movilidad de hombros'], 2, null, null, 60, 30],
            [$exByName['Salto a la cuerda'], 3, null, null, 30, 45],
        ]);

        $sessionPlans = [
            ['student' => $lucia, 'routine' => $routine1, 'type' => 'fuerza'],
            ['student' => $martin, 'routine' => $routine2, 'type' => 'fuerza'],
            ['student' => $sofia, 'routine' => $routine3, 'type' => 'mixta'],
            ['student' => $tomas, 'routine' => $routine4, 'type' => 'mixta'],
        ];

        foreach ($sessionPlans as $plan) {
            foreach ([-7, -4, -1] as $daysAgo) {
                $session = TrainingSession::create([
                    'student_id' => $plan['student']->id,
                    'coach_id' => $coach->id,
                    'type' => $plan['type'],
                    'scheduled_at' => now()->addDays($daysAgo)->setTime(18, 0),
                    'duration_minutes' => 60,
                    'status' => 'completed',
                    'started_at' => now()->addDays($daysAgo)->setTime(18, 0),
                    'finished_at' => now()->addDays($daysAgo)->setTime(19, 0),
                ]);
                foreach ($plan['routine']->exercises as $i => $re) {
                    $se = $session->exercises()->create([
                        'exercise_id' => $re->exercise_id,
                        'planned_sets' => $re->sets,
                        'planned_reps' => $re->reps,
                        'planned_weight' => $re->weight,
                        'planned_duration_seconds' => $re->duration_seconds,
                        'order' => $i,
                    ]);
                    for ($set = 1; $set <= ($re->sets ?? 1); $set++) {
                        $se->logs()->create([
                            'set_number' => $set,
                            'reps_done' => $re->reps,
                            'weight_used' => $re->weight,
                            'duration_seconds' => $re->duration_seconds,
                            'completed' => true,
                            'effort' => ['facil', 'normal', 'dificil'][array_rand(['facil', 'normal', 'dificil'])],
                            'recorded_at' => now()->addDays($daysAgo),
                        ]);
                    }
                }
            }

            foreach ([1, 4, 8] as $daysAhead) {
                $session = TrainingSession::create([
                    'student_id' => $plan['student']->id,
                    'coach_id' => $coach->id,
                    'type' => $plan['type'],
                    'scheduled_at' => now()->addDays($daysAhead)->setTime(18, 0),
                    'duration_minutes' => 60,
                    'status' => 'planned',
                ]);
                foreach ($plan['routine']->exercises as $i => $re) {
                    $session->exercises()->create([
                        'exercise_id' => $re->exercise_id,
                        'planned_sets' => $re->sets,
                        'planned_reps' => $re->reps,
                        'planned_weight' => $re->weight,
                        'planned_duration_seconds' => $re->duration_seconds,
                        'order' => $i,
                    ]);
                }
            }
        }

        Injury::create([
            'student_id' => $martin->id,
            'description' => 'Molestia leve en hombro derecho',
            'date_occurred' => now()->subDays(10),
            'status' => 'recovering',
            'recovery_plan' => 'Evitar press por encima de cabeza, priorizar movilidad.',
        ]);

        $dietNotesData = [
            [$lucia, 'habit', 'Reducir consumo de harinas refinadas, priorizar vegetales en cada comida.'],
            [$lucia, 'hydration', 'Tomar al menos 2 litros de agua por dia, llevar botella al entrenamiento.'],
            [$martin, 'goal', 'Aumentar ingesta de proteina a 1.8g por kg de peso corporal para favorecer ganancia muscular.'],
            [$sofia, 'habit', 'Buena adherencia a comidas regulares, mantener carbohidratos antes de entrenar resistencia.'],
            [$tomas, 'habit', 'Fomentar desayuno completo antes de entrenar, evitar bebidas azucaradas.'],
        ];
        foreach ($dietNotesData as [$student, $type, $note]) {
            DietNote::create([
                'student_id' => $student->id,
                'type' => $type,
                'note' => $note,
                'date' => now()->subDays(rand(1, 5)),
            ]);
        }

        // Estadisticas de progreso (6 puntos cada 7 dias, las ultimas 6 semanas)
        $this->seedProgress($lucia->id, 'bodyweight', 'kg', [71, 70.4, 69.8, 69.3, 68.6, 68]);
        $this->seedProgress($lucia->id, 'measurement', 'cm', [82, 81, 80, 79, 78.5, 78], label: 'Cintura');
        $this->seedProgress($lucia->id, 'weight', 'kg', [12, 14, 15, 16, 18, 20], exerciseId: $exByName['Sentadilla con barra']->id);

        $this->seedProgress($martin->id, 'bodyweight', 'kg', [75, 75.6, 76.2, 76.8, 77.4, 78]);
        $this->seedProgress($martin->id, 'weight', 'kg', [45, 48, 50, 55, 58, 60], exerciseId: $exByName['Press de banca']->id);
        $this->seedProgress($martin->id, 'measurement', 'cm', [33, 33.5, 34, 34.3, 34.7, 35], label: 'Brazo');

        $this->seedProgress($sofia->id, 'bodyweight', 'kg', [60.5, 60.2, 60.1, 60, 60, 60]);
        $this->seedProgress($sofia->id, 'time', 'seg', [1560, 1530, 1500, 1470, 1410, 1380], exerciseId: $exByName['Carrera continua']->id);
        $this->seedProgress($sofia->id, 'reps', 'reps', [40, 42, 45, 48, 50, 54], exerciseId: $exByName['Burpees']->id);

        $this->seedProgress($tomas->id, 'bodyweight', 'kg', [40, 40.4, 40.9, 41.3, 41.7, 42]);
        $this->seedProgress($tomas->id, 'reps', 'reps', [25, 28, 32, 35, 38, 42], exerciseId: $exByName['Salto a la cuerda']->id);
    }

    private function seedProgress(int $studentId, string $type, string $unit, array $values, ?int $exerciseId = null, ?string $label = null): void
    {
        $weeksAgo = count($values) - 1;
        foreach ($values as $value) {
            ProgressMetric::create([
                'student_id' => $studentId,
                'exercise_id' => $exerciseId,
                'label' => $label,
                'metric_type' => $type,
                'value' => $value,
                'unit' => $unit,
                'recorded_at' => now()->subWeeks($weeksAgo),
            ]);
            $weeksAgo--;
        }
    }

    private function addExercises(Routine $routine, array $rows): void
    {
        foreach ($rows as $i => [$exercise, $sets, $reps, $weight, $duration, $rest]) {
            $routine->exercises()->create([
                'exercise_id' => $exercise->id,
                'sets' => $sets,
                'reps' => $reps,
                'weight' => $weight,
                'duration_seconds' => $duration,
                'rest_seconds' => $rest,
                'order' => $i,
            ]);
        }
    }
}
