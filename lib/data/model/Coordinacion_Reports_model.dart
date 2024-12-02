import 'package:cloud_firestore/cloud_firestore.dart';

class CoordinacionModel {
  String? id;
  String email;
  String level;
  String course;
  String previousSchool;
  String hasSiblings;
  String siblingDetails;
  String studentFullName;
  String ci;
  DateTime birthDate;
  String fatherFullName;
  String fatherPhoneNumber;
  String motherFullName;
  String motherPhoneNumber;
  String familyPhoneNumber;
  
  // psicología
  DateTime interview_date_psicologia;
  String interview_hour_psicologia;
  String obs_Psychology;
  
  // coordinación
  DateTime interview_date_cord;
  String interview_hour_cord;
  String obs_Cord;
  
  // administración
  DateTime interview_date_admin;
  String interview_hour_admin;
  String obs_Admin;
  
  // para la validación
  String estadoRevisado;
  String estadoConfirmado;
  String approvedAdm;
  DateTime registrationDate;

  String reasonMissAppointment;
  String reasonRescheduleAppointment;

  CoordinacionModel({
    this.id,
    required this.email,
    required this.level,
    required this.course,
    required this.previousSchool,
    required this.hasSiblings,
    required this.siblingDetails,
    required this.studentFullName,
    required this.ci,
    required this.birthDate,
    required this.fatherFullName,
    required this.fatherPhoneNumber,
    required this.motherFullName,
    required this.motherPhoneNumber,
    required this.familyPhoneNumber,
    
    // psicología
    required this.interview_date_psicologia,
    required this.interview_hour_psicologia,
    required this.obs_Psychology,
    
    // coordinación
    required this.interview_date_cord,
    required this.interview_hour_cord,
    required this.obs_Cord,
    
    // administración
    required this.interview_date_admin,
    required this.interview_hour_admin,
    required this.obs_Admin,
    
    // para la validación
    this.estadoRevisado = 'coordinacion', // por defecto
    this.estadoConfirmado = 'pendiente', // por defecto
    this.approvedAdm = 'No Aprobado', // por defecto
    required this.registrationDate,
    required this.reasonMissAppointment,
    required this.reasonRescheduleAppointment,
  });

    factory CoordinacionModel.fromJson(Map<String, dynamic> json, String id) {
    return CoordinacionModel(
    id: id,
    email: json['email'] as String,
    level: json['level'] as String,
    course: json['course'] as String,
    previousSchool: json['previousSchool'] as String,
    hasSiblings: json['hasSiblings'] as String,
    siblingDetails: json['siblingDetails'] ?? 'no tiene hermanos' as String,
    studentFullName: json['studentFullName'] as String,
    birthDate: (json['birthDate'] as Timestamp).toDate(),
    ci: json['ci'] as String,
    fatherFullName: json['fatherFullName'] as String,
    fatherPhoneNumber: json['fatherPhoneNumber'] as String,
    motherFullName: json['motherFullName'] as String,
    motherPhoneNumber: json['motherPhoneNumber'] as String,
    familyPhoneNumber: json['familyPhoneNumber'] ?? '' as String,
    
    // psicología
    interview_date_psicologia: (json['interview_date_psicologia'] as Timestamp).toDate(),
    interview_hour_psicologia: json['interview_hour_psicologia'] as String,
    obs_Psychology: json['obs_Psychology'] as String,
    
    // coordinación
    interview_date_cord: (json['interview_date_cord'] as Timestamp).toDate(),
    interview_hour_cord: json['interview_hour_cord'] as String,
    obs_Cord: json['obs_Cord'] as String,
    
    // administración
    interview_date_admin: (json['interview_date_admin'] as Timestamp).toDate(),
    interview_hour_admin: json['interview_hour_admin'] as String,
    obs_Admin: json['obs_Admin'] as String,
    
    // para la validación
    estadoRevisado: json['estadoRevisado'] ?? 'coordinacion' as String,
    estadoConfirmado: json['estadoConfirmado'] ?? 'pendiente' as String,
    approvedAdm: json['approvedAdm'] ?? 'No Aprobado' as String,
    registrationDate: (json['registrationDate'] as Timestamp).toDate(),
      //razones
      reasonMissAppointment:json['reasonMissAppointment'] ?? '' as String,
      reasonRescheduleAppointment:json['reasonRescheduleAppointment'] ?? '' as String,
    );
  }
   Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'email': email,
      'level': level,
      'course': course,
      'previousSchool': previousSchool,
      'hasSiblings': hasSiblings,
      'siblingDetails': siblingDetails,
      'studentFullName': studentFullName,
      'birthDate': Timestamp.fromDate(birthDate),
      'ci': ci,
      'fatherFullName': fatherFullName,
      'fatherPhoneNumber': fatherPhoneNumber,
      'motherFullName': motherFullName,
      'motherPhoneNumber': motherPhoneNumber,
      'familyPhoneNumber': familyPhoneNumber,
      
      // día y hora de entrevista psicología
      'interview_date_psicologia': Timestamp.fromDate(interview_date_psicologia),
      'interview_hour_psicologia': interview_hour_psicologia,
      'obs_Psychology': obs_Psychology,
      
      // día y hora de entrevista coordinación
      'interview_date_cord': Timestamp.fromDate(interview_date_cord),
      'interview_hour_cord': interview_hour_cord,
      'obs_Cord': obs_Cord,
      
      // día y hora de entrevista administración
      'interview_date_admin': Timestamp.fromDate(interview_date_admin),
      'interview_hour_admin': interview_hour_admin,
      'obs_Admin': obs_Admin,
      
      // estados
      'estadoRevisado': estadoRevisado,
      'estadoConfirmado': estadoConfirmado,
      'approvedAdm': approvedAdm,
      //razones
      'reasonMissAppointment': reasonMissAppointment,
      'reasonRescheduleAppointment': reasonRescheduleAppointment,

      // fecha de registro
      'registrationDate': Timestamp.fromDate(registrationDate),
   };
  }
}
