import 'package:cloud_firestore/cloud_firestore.dart';

class PostulationModel {
  String? id;
  String level;
  String grade;
  String institutional_unit;
  String city;
  int amount_brothers;
  String student_name;
  String student_lastname;
  String student_ci;
  DateTime birth_day;
  String gender;
  String father_name;
  String father_lastname;
  String father_cellphone;
  String mother_name;
  String mother_lastname;
  String mother_cellphone;
  String telephone;
  String email;
  DateTime interview_date;
  String interview_hour;
  String userID;
  String status;
  double latitude;
  double longitude;
  DateTime register_date;

  //mio = Psicologia
  //rafa = cordinacion
  //erick = administracion

//Psicologia

  List<String> hermanosUEE; //mio
  //por ahora string, luegom array  //mio
  List<String> nombreHermano;
  String obs; ////mio
  DateTime fechaEntrevista; //cuando se hizo la entrevista
  String psicologoEncargado; //string

  String informeBreveEntrevista; //mio
  String recomendacionPsicologia; //mio
  String respuestaPPFF; //mio
  //de cristian y rafo por que ambos pueden manipular la fecha.

  //propongo
  DateTime fechaEntrevistaCoordinacion; // /mio yo propongo
  //pendiente a confirmado

  String vistoBuenoCoordinacion; //??rafa
  //respuesta de coordinacion como un mensaje
  String respuestaAPpff; //??rafa

  String administracion; //??erick
  String recepcionDocumentos; //?? erick

  String estadoEntrevistaPsicologia; //pendiente de ver
  //para verificar si paso de uno a otra
  String estadoGeneral; // estado (psico, admin, coor) pisco
  String estadoConfirmacion; // estado () cancelar para cada modulo
  String reasonRescheduleAppointment; // razón para reprogramar la cita
  String reasonMissAppointment; //razón de la cita perdida
  String estadoConfirmacionAdmin;
  String approvedAdm;
  DateTime
      fechaEntrevistaAdministracion; // de ericck ( manda una fecha de entrevista a qui)
  String horaEntrevistaAdministracion;
  //Atributo Añadido
  String? MensajeCoordinacion;
PostulationModel({
  this.id,
  required this.level,
  required this.grade,
  required this.institutional_unit,
  required this.city,
  required this.amount_brothers,
  required this.student_name,
  required this.student_lastname,
  required this.student_ci,
  required this.birth_day,
  required this.gender,
  required this.father_name,
  required this.father_lastname,
  required this.father_cellphone,
  required this.mother_name,
  required this.mother_lastname,
  required this.mother_cellphone,
  required this.telephone,
  required this.email,
  required this.interview_date,
  required this.interview_hour,
  required this.userID,
  required this.status,
  required this.latitude,
  required this.longitude,
  required this.register_date,
  required this.hermanosUEE,
  required this.nombreHermano,
  required this.obs,
  required this.fechaEntrevista,
  required this.psicologoEncargado,
  required this.informeBreveEntrevista,
  required this.recomendacionPsicologia,
  required this.respuestaPPFF,
  required this.fechaEntrevistaCoordinacion,
  required this.vistoBuenoCoordinacion,
  required this.respuestaAPpff,
  required this.administracion,
  required this.recepcionDocumentos,
  required this.estadoEntrevistaPsicologia,
  required this.estadoGeneral,
  required this.estadoConfirmacion,
  required this.reasonRescheduleAppointment,
  required this.reasonMissAppointment,
  required this.estadoConfirmacionAdmin,
  required this.approvedAdm,
  required this.fechaEntrevistaAdministracion,
  required this.horaEntrevistaAdministracion,
  this.MensajeCoordinacion = "Por Confirmar", // Valor predeterminado
});


  factory PostulationModel.fromJson(Map<String, dynamic> json, String id) {
  return PostulationModel(
    id: id,
    level: json['level'] as String,
    grade: json['grade'] as String,
    institutional_unit: json['institutional_unit'] as String,
    city: json['city'] as String,
    amount_brothers: json['amount_brothers'] as int,
    student_name: json['student_name'] as String,
    student_lastname: json['student_lastname'] as String,
    student_ci: json['student_ci'] as String,
    birth_day: (json['birth_day'] as Timestamp).toDate(),
    gender: json['gender'] as String,
    father_name: json['father_name'] as String,
    father_lastname: json['father_lastname'] as String,
    father_cellphone: json['father_cellphone'] as String,
    mother_name: json['mother_name'] as String,
    mother_lastname: json['mother_lastname'] as String,
    mother_cellphone: json['mother_cellphone'] as String,
    telephone: json['telephone'] as String,
    email: json['email'] as String,
    interview_date: (json['interview_date'] as Timestamp).toDate(),
    interview_hour: json['interview_hour'] as String,
    userID: json['userID'] as String,
    status: json['status'] as String,
    latitude: json['latitude'] ?? -17.407771,
    longitude: json['longitude'] ?? -66.136627,
    register_date: (json['register_date'] as Timestamp).toDate(),
    hermanosUEE: List<String>.from(json['hermanosUEE'] ?? []),
    nombreHermano: List<String>.from(json['nombreHermano'] ?? []),
    obs: json['obs'] as String? ?? '',
    fechaEntrevista: (json['fechaEntrevista'] as Timestamp?)?.toDate() ?? DateTime.now(),
    psicologoEncargado: json['psicologoEncargado'] as String? ?? 'Desconocido',
    informeBreveEntrevista: json['informeBreveEntrevista'] as String? ?? '',
    recomendacionPsicologia: json['recomendacionPsicologia'] as String? ?? '',
    respuestaPPFF: json['respuestaPPFF'] as String? ?? '',
    fechaEntrevistaCoordinacion: (json['fechaEntrevistaCoordinacion'] as Timestamp?)?.toDate() ?? DateTime.now(),
    vistoBuenoCoordinacion: json['vistoBuenoCoordinacion'] as String? ?? 'Pendiente',
    respuestaAPpff: json['respuestaAPpff'] as String? ?? '',
    administracion: json['administracion'] as String? ?? '',
    recepcionDocumentos: json['recepcionDocumentos'] as String? ?? '',
    estadoEntrevistaPsicologia: json['estadoEntrevistaPsicologia'] as String? ?? 'Pendiente',
    estadoGeneral: json['estadoGeneral'] as String? ?? 'Pendiente',
    estadoConfirmacion: json['estadoConfirmacion'] as String? ?? '',
    reasonRescheduleAppointment: json['reasonRescheduleAppointment'] as String? ?? '',
    reasonMissAppointment: json['reasonMissAppointment'] as String? ?? '',
    estadoConfirmacionAdmin: json['estadoConfirmacionAdmin'] as String? ?? '',
    approvedAdm: json['approvedAdm'] as String? ?? '',
    fechaEntrevistaAdministracion: (json['fechaEntrevistaAdministracion'] as Timestamp?)?.toDate() ?? DateTime.now(),
    horaEntrevistaAdministracion: json['horaEntrevistaAdministracion'] as String? ?? '',
    MensajeCoordinacion: json['MensajeCoordinacion'] as String? ?? 'Por Confirmar',
  );
}



  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'level': level,
      'grade': grade,
      'institutional_unit': institutional_unit,
      'city': city,
      'amount_brothers': amount_brothers,
      'student_name': student_name,
      'student_lastname': student_lastname,
      'student_ci': student_ci,
      'birth_day': Timestamp.fromDate(birth_day),
      'gender': gender,
      'father_name': father_name,
      'father_lastname': father_lastname,
      'father_cellphone': father_cellphone,
      'mother_name': mother_name,
      'mother_lastname': mother_lastname,
      'mother_cellphone': mother_cellphone,
      'telephone': telephone,
      'email': email,
      'interview_date': Timestamp.fromDate(interview_date),
      'interview_hour': interview_hour,
      'userID': userID,
      'status': status,
      'latitude': latitude,
      'longitude': longitude,
      'register_date': Timestamp.fromDate(register_date),
      'hermanosUEE': hermanosUEE,
      'nombreHermano': nombreHermano,
      'obs': obs,
      'fechaEntrevista': Timestamp.fromDate(fechaEntrevista),
      'psicologoEncargado': psicologoEncargado,
      'informeBreveEntrevista': informeBreveEntrevista,
      'recomendacionPsicologia': recomendacionPsicologia,
      'respuestaPPFF': respuestaPPFF,
      'fechaEntrevistaCoordinacion':
          Timestamp.fromDate(fechaEntrevistaCoordinacion),
      'vistoBuenoCoordinacion': vistoBuenoCoordinacion,
      'respuestaAPpff': respuestaAPpff,
      'administracion': administracion,
      'recepcionDocumentos': recepcionDocumentos,
      'estadoEntrevistaPsicologia': estadoEntrevistaPsicologia,
      'estadoGeneral': estadoGeneral,
      'estadoConfirmacion': estadoConfirmacion,
      'reasonRescheduleAppointment': reasonRescheduleAppointment,
      'reasonMissAppointment': reasonMissAppointment,
      'estadoConfirmacionAdmin': estadoConfirmacionAdmin,
      'approvedAdm': approvedAdm,
      'fechaEntrevistaAdministracion':
          Timestamp.fromDate(fechaEntrevistaAdministracion),
      'horaEntrevistaAdministracion': horaEntrevistaAdministracion,
       'MensajeCoordinacion': MensajeCoordinacion,
    };
  }
}
