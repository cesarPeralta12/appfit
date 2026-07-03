class AvailabilitySlot {
  String day;
  String start;
  String end;

  AvailabilitySlot({required this.day, required this.start, required this.end});

  factory AvailabilitySlot.fromJson(Map<String, dynamic> json) => AvailabilitySlot(
        day: json['day'],
        start: json['start'],
        end: json['end'],
      );

  Map<String, dynamic> toJson() => {'day': day, 'start': start, 'end': end};
}

class Student {
  final int id;
  final String name;
  final String? birthdate;
  final String? sex;
  final String ageCategory;
  final String? phone;
  final String? email;
  final String? photo;
  final String? injuriesNotes;
  final String? allergies;
  final String? pathologies;
  final double? weight;
  final double? height;
  final String level;
  final String? goal;
  final bool active;
  final List<AvailabilitySlot> availability;

  Student({
    required this.id,
    required this.name,
    this.birthdate,
    this.sex,
    this.ageCategory = 'adulto',
    this.phone,
    this.email,
    this.photo,
    this.injuriesNotes,
    this.allergies,
    this.pathologies,
    this.weight,
    this.height,
    required this.level,
    this.goal,
    this.active = true,
    this.availability = const [],
  });

  double? get imc {
    if (weight == null || height == null || height == 0) return null;
    final h = height! / 100;
    return weight! / (h * h);
  }

  factory Student.fromJson(Map<String, dynamic> json) => Student(
        id: json['id'],
        name: json['name'],
        birthdate: json['birthdate'],
        sex: json['sex'],
        ageCategory: json['age_category'] ?? 'adulto',
        phone: json['phone'],
        email: json['email'],
        photo: json['photo'],
        injuriesNotes: json['injuries_notes'],
        allergies: json['allergies'],
        pathologies: json['pathologies'],
        weight: json['weight'] != null ? double.tryParse(json['weight'].toString()) : null,
        height: json['height'] != null ? double.tryParse(json['height'].toString()) : null,
        level: json['level'] ?? 'beginner',
        goal: json['goal'],
        active: json['active'] ?? true,
        availability: json['availability'] != null
            ? (json['availability'] as List).map((e) => AvailabilitySlot.fromJson(e)).toList()
            : [],
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'birthdate': birthdate,
        'sex': sex,
        'age_category': ageCategory,
        'phone': phone,
        'email': email,
        'injuries_notes': injuriesNotes,
        'allergies': allergies,
        'pathologies': pathologies,
        'weight': weight,
        'height': height,
        'level': level,
        'goal': goal,
        'availability': availability.map((e) => e.toJson()).toList(),
      };
}
