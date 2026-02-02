// Model Jurusan
class MajorModel {
  final String id;
  final String code;
  final String name;

  MajorModel({
    required this.id,
    required this.code,
    required this.name,
  });

  factory MajorModel.fromJson(Map<String, dynamic> json) {
    return MajorModel(
      id: json['id'].toString(),
      code: json['code'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
    };
  }
}

// Model Mata Kuliah (Master Data)
class CourseModel {
  final String id;
  final String code;
  final String name;
  final int sks;
  final int semester;
  final String majorId;

  CourseModel({
    required this.id,
    required this.code,
    required this.name,
    required this.sks,
    required this.semester,
    required this.majorId,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'].toString(),
      code: json['code'],
      name: json['name'],
      sks: int.parse(json['sks'].toString()),
      semester: int.parse(json['semester'].toString()),
      majorId: json['major_id'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'sks': sks,
      'semester': semester,
      'major_id': majorId,
    };
  }
}

// Model Jadwal Kelas (Yang dipilih saat KRS)
class ClassSessionModel {
  final String id;
  final String courseId;
  final CourseModel? course; // Joined data
  final String dosenId;
  final String dosenName;
  final String day; // Senin, Selasa, etc
  final String timeStart;
  final String timeEnd;
  final String room;
  final int quota;
  final int enrolledCount;

  ClassSessionModel({
    required this.id,
    required this.courseId,
    this.course,
    required this.dosenId,
    required this.dosenName,
    required this.day,
    required this.timeStart,
    required this.timeEnd,
    required this.room,
    required this.quota,
    required this.enrolledCount,
    this.section = '',
  });

  final String section;

  factory ClassSessionModel.fromJson(Map<String, dynamic> json) {
    return ClassSessionModel(
      id: json['id'].toString(),
      courseId: json['course_id'].toString(),
      course: json['course_name'] != null ? CourseModel(
        id: json['course_id'].toString(),
        code: json['course_code'] ?? '',
        name: json['course_name'] ?? '',
        sks: int.tryParse(json['course_sks'].toString()) ?? 0,
        semester: int.tryParse(json['course_semester'].toString()) ?? 0,
        majorId: '', // Not needed for display here
      ) : null,
      dosenId: json['dosen_id'].toString(),
      dosenName: json['dosen_name'] ?? '',
      day: json['day'],
      timeStart: json['time_start'],
      timeEnd: json['time_end'],
      room: json['room'],
      quota: int.parse(json['quota'].toString()),
      enrolledCount: int.parse(json['enrolled_count'].toString()),
      section: json['section'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course_id': courseId,
      'dosen_id': dosenId,
      'section': section,
      'day': day,
      'time_start': timeStart,
      'time_end': timeEnd,
      'room': room,
      'quota': quota,
    };
  }
}

// Model KRS / Enrollment (Data pengambilan kelas oleh mahasiswa)
class EnrollmentModel {
  final String id;
  final String studentId;
  final String classId;
  final ClassSessionModel? classSession; // Joined data
  final String status; // 'active', 'dropped'
  final String? grade; // 'A', 'B', etc.

  EnrollmentModel({
    required this.id,
    required this.studentId,
    required this.classId,
    this.classSession,
    required this.status,
    this.grade,
  });
}

class MaterialModel {
  final String id;
  final String classId;
  final String title;
  final String description;
  final String fileUrl;
  final String type; // 'material', 'tugas', 'ujian'
  final DateTime createdAt;

  MaterialModel({
    required this.id,
    required this.classId,
    required this.title,
    required this.description,
    required this.fileUrl,
    required this.type,
    required this.createdAt,
  });

  factory MaterialModel.fromJson(Map<String, dynamic> json) {
    return MaterialModel(
      id: json['id'].toString(),
      classId: json['class_session_id'].toString(),
      title: json['title'],
      description: json['description'] ?? '',
      fileUrl: json['file_url'],
      type: json['type'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class SubmissionModel {
  final String id;
  final String materialId; // Link to the assignment/exam
  final String studentId;
  final String fileUrl;
  final DateTime submittedAt;
  final double? score;

  SubmissionModel({
    required this.id,
    required this.materialId,
    required this.studentId,
    required this.fileUrl,
    required this.submittedAt,
    this.score,
  });
}
