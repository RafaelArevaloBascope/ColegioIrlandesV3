class AttentionCallsModel {
  final String id;
  final String student;
  final String teacher;
  final String motive;
  final String level;
  final String course;
  final String studentId;
  final String registrationDate;

  AttentionCallsModel({
    required this.id,
    required this.student,
    required this.teacher,
    required this.motive,
    required this.level,
    required this.course,
    required this.studentId,
    required this.registrationDate,
  });

  // Factory method to create an instance from JSON
  factory AttentionCallsModel.fromJson(Map<String, dynamic> json) {
    return AttentionCallsModel(
      id: json['id'],
      student: json['student'],
      teacher: json['teacher'],
      motive: json['motive'],
      level: json['level'],
      course: json['course'],
      studentId: json['studentId'],
      registrationDate: json['registrationDate'],
    );
  }

  // Method to convert an instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student': student,
      'teacher': teacher,
      'motive': motive,
      'level': level,
      'course': course,
      'studentId': studentId,
      'registrationDate': registrationDate,
    };
  }
}