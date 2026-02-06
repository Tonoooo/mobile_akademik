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

  final String? studentName;
  final String? studentNim;
  final double? calculatedScore;

  EnrollmentModel({
    required this.id,
    required this.studentId,
    required this.classId,
    this.classSession,
    required this.status,
    this.grade,
    this.studentName,
    this.studentNim,
    this.calculatedScore,
  });

  factory EnrollmentModel.fromJson(Map<String, dynamic> json) {
    return EnrollmentModel(
      id: json['id'].toString(),
      studentId: json['student_id'].toString(),
      classId: json['class_id'].toString(),
      status: json['status'] ?? 'active',
      grade: json['grade'],
      studentName: json['student_name'],
      studentNim: json['student_nim'],
      calculatedScore: json['calculated_score'] != null ? double.tryParse(json['calculated_score'].toString()) : null,
      classSession: (json['course_name'] != null && json['day'] != null) ? ClassSessionModel.fromJson(json) : null,
    );
  }
}

class MaterialModel {
  final String id;
  final String classId;
  final String title;
  final String description;
  final String fileUrl;
  final String type; // 'material', 'tugas', 'ujian'
  final DateTime createdAt;
  final DateTime? deadline;
  final String? courseName; // Extra field for lists

  MaterialModel({
    required this.id,
    required this.classId,
    required this.title,
    required this.description,
    required this.fileUrl,
    required this.type,
    required this.createdAt,
    this.deadline,
    this.courseName,
  });

  factory MaterialModel.fromJson(Map<String, dynamic> json) {
    return MaterialModel(
      id: json['id'].toString(),
      classId: json['class_id']?.toString() ?? json['class_session_id'].toString(),
      title: json['title'],
      description: json['description'] ?? '',
      fileUrl: json['file_url'],
      type: json['type'],
      createdAt: DateTime.parse(json['created_at']),
      deadline: json['deadline'] != null ? DateTime.parse(json['deadline']) : null,
      courseName: json['course_name'],
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
  final String? answer;
  final String? studentName;
  final String? studentNim;

  SubmissionModel({
    required this.id,
    required this.materialId,
    required this.studentId,
    required this.fileUrl,
    required this.submittedAt,
    this.score,
    this.answer,
    this.studentName,
    this.studentNim,
  });

  factory SubmissionModel.fromJson(Map<String, dynamic> json) {
    return SubmissionModel(
      id: json['id'].toString(),
      materialId: json['material_id'].toString(),
      studentId: json['student_id'].toString(),
      fileUrl: json['file_url'] ?? '',
      submittedAt: DateTime.parse(json['submitted_at']),
      score: json['grade'] != null ? double.tryParse(json['grade'].toString()) : null,
      answer: json['answer'],
      studentName: json['student_name'],
      studentNim: json['student_nim'],
    );
  }
}

class AttendanceSessionModel {
  final String id;
  final String classId;
  final String title;
  final int meetingNumber;
  final DateTime createdAt;

  AttendanceSessionModel({
    required this.id,
    required this.classId,
    required this.title,
    required this.meetingNumber,
    required this.createdAt,
  });

  factory AttendanceSessionModel.fromJson(Map<String, dynamic> json) {
    return AttendanceSessionModel(
      id: json['id'].toString(),
      classId: json['class_id'].toString(),
      title: json['title'],
      meetingNumber: int.parse(json['meeting_number'].toString()),
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class AttendanceRecordModel {
  final String id;
  final String sessionId;
  final String studentId;
  final String status; // H, S, I, A
  final String? studentName;
  final String? studentNim;
  final String? sessionTitle; // For student view
  final int? meetingNumber; // For student view
  final DateTime? sessionDate; // For student view

  AttendanceRecordModel({
    required this.id,
    required this.sessionId,
    required this.studentId,
    required this.status,
    this.studentName,
    this.studentNim,
    this.sessionTitle,
    this.meetingNumber,
    this.sessionDate,
  });

  factory AttendanceRecordModel.fromJson(Map<String, dynamic> json) {
    return AttendanceRecordModel(
      id: json['id']?.toString() ?? '',
      sessionId: json['session_id']?.toString() ?? '',
      studentId: json['student_id']?.toString() ?? '',
      status: json['status'],
      studentName: json['student_name'],
      studentNim: json['student_nim'],
      sessionTitle: json['title'],
      meetingNumber: json['meeting_number'] != null ? int.parse(json['meeting_number'].toString()) : null,
      sessionDate: json['session_date'] != null ? DateTime.parse(json['session_date']) : null,
    );
  }
}

class AttendanceSummaryModel {
  final String classId;
  final String courseName;
  final String courseCode;
  final int totalMeetings;
  final int totalHadir;
  final int totalSakit;
  final int totalIzin;
  final int totalAlpha;

  AttendanceSummaryModel({
    required this.classId,
    required this.courseName,
    required this.courseCode,
    required this.totalMeetings,
    required this.totalHadir,
    required this.totalSakit,
    required this.totalIzin,
    required this.totalAlpha,
  });

  factory AttendanceSummaryModel.fromJson(Map<String, dynamic> json) {
    return AttendanceSummaryModel(
      classId: json['class_id'].toString(),
      courseName: json['course_name'],
      courseCode: json['course_code'],
      totalMeetings: int.parse(json['total_meetings'].toString()),
      totalHadir: int.parse(json['total_hadir'].toString()),
      totalSakit: int.parse(json['total_sakit'].toString()),
      totalIzin: int.parse(json['total_izin'].toString()),
      totalAlpha: int.parse(json['total_alpha'].toString()),
    );
  }
}

class GradeDetailModel {
  final String studentId;
  final String enrollmentId;
  final String? storedGrade;
  final AttendanceGradeDetail attendance;
  final ComponentGradeDetail tasks;
  final ComponentGradeDetail exams;
  final double finalScoreCalculated;

  GradeDetailModel({
    required this.studentId,
    required this.enrollmentId,
    this.storedGrade,
    required this.attendance,
    required this.tasks,
    required this.exams,
    required this.finalScoreCalculated,
  });

  factory GradeDetailModel.fromJson(Map<String, dynamic> json) {
    return GradeDetailModel(
      studentId: json['student_id'].toString(),
      enrollmentId: json['enrollment_id'].toString(),
      storedGrade: json['stored_grade'],
      attendance: AttendanceGradeDetail.fromJson(json['attendance']),
      tasks: ComponentGradeDetail.fromJson(json['tasks']),
      exams: ComponentGradeDetail.fromJson(json['exams']),
      finalScoreCalculated: double.parse(json['final_score_calculated'].toString()),
    );
  }
}

class AttendanceGradeDetail {
  final int totalSessions;
  final int presentCount;
  final double score;

  AttendanceGradeDetail({
    required this.totalSessions,
    required this.presentCount,
    required this.score,
  });

  factory AttendanceGradeDetail.fromJson(Map<String, dynamic> json) {
    return AttendanceGradeDetail(
      totalSessions: int.parse(json['total_sessions'].toString()),
      presentCount: int.parse(json['present_count'].toString()),
      score: double.parse(json['score'].toString()),
    );
  }
}

class ComponentGradeDetail {
  final List<GradeItem> items;
  final double average;

  ComponentGradeDetail({required this.items, required this.average});

  factory ComponentGradeDetail.fromJson(Map<String, dynamic> json) {
    return ComponentGradeDetail(
      items: (json['items'] as List).map((i) => GradeItem.fromJson(i)).toList(),
      average: double.parse(json['average'].toString()),
    );
  }
}

class GradeItem {
  final String title;
  final double score;

  GradeItem({required this.title, required this.score});

  factory GradeItem.fromJson(Map<String, dynamic> json) {
    return GradeItem(
      title: json['title'],
      score: double.parse(json['score'].toString()),
    );
  }
}

class AnnouncementModel {
  final String id;
  final String title;
  final String content;
  final String? attachmentUrl;
  final String? authorName;
  final DateTime createdAt;

  AnnouncementModel({
    required this.id,
    required this.title,
    required this.content,
    this.attachmentUrl,
    this.authorName,
    required this.createdAt,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      id: json['id'].toString(),
      title: json['title'],
      content: json['content'] ?? '',
      attachmentUrl: json['attachment_url'],
      authorName: json['author_name'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
