import 'package:pr_h23_irlandes_web/data/model/postulation_model.dart';
class IntervieweeModel {
  final String? id;
  final String nivel; //rescatar del mismo
  final String curso;//rescatar del mismo
  final String ueProcedencia; //rescatar del mismo
  final String hermanosUEE;//mio
  final String nombreHermano; //por ahora string, luegom array  //mio
  final String nombreEstudiante; //rescartar mismo
  final String obs; ////mio
  final String fechaEntrevista;//cuando se hizo la entrevista
  final String psicologoEncargado; //string
  final String informeBreveEntrevista;//mio
  final String recomendacionPsicologia;//mio
  final String respuestaPPFF;//mio
  final String fechaEntrevistaCoordinacion; // //mio
  final String vistoBuenoCoordinacion; //??rafa
  final String respuestaAPpff; //??rafa
  final String administracion; //??erick
  final String recepcionDocumentos; //?? erick

  final String estadoEntrevistaPsicologia;//pendiente de ver
  final String estadoGeneral; // estado (psico, admin, coor) pisco
  final String estadoConfirmacion; // estado () cancelar para cada modulo
  final PostulationModel postulation; // id en confirmada

  IntervieweeModel({
    this.id,
    required this.nivel,
    required this.curso,
    required this.ueProcedencia,
    required this.hermanosUEE,
    required this.nombreHermano,
    required this.nombreEstudiante,
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
    required this.postulation, // Inicialización de postulation
  });

  // Método factory para crear una instancia desde JSON
  factory IntervieweeModel.fromJson(Map<String, dynamic> json) {
    return IntervieweeModel(
      id: json['id'],
      nivel: json['nivel'],
      curso: json['curso'],
      ueProcedencia: json['ueProcedencia'],
      hermanosUEE: json['hermanosUEE'],
      nombreHermano: json['nombreHermano'],
      nombreEstudiante: json['nombreEstudiante'],
      obs: json['obs'],
      fechaEntrevista: json['fechaEntrevista'],
      psicologoEncargado: json['psicologoEncargado'],
      informeBreveEntrevista: json['informeBreveEntrevista'],
      recomendacionPsicologia: json['recomendacionPsicologia'],
      respuestaPPFF: json['respuestaPPFF'],
      fechaEntrevistaCoordinacion: json['fechaEntrevistaCoordinacion'],
      vistoBuenoCoordinacion: json['vistoBuenoCoordinacion'],
      respuestaAPpff: json['respuestaAPpff'],
      administracion: json['administracion'],
      recepcionDocumentos: json['recepcionDocumentos'],
      estadoEntrevistaPsicologia: json['estadoEntrevistaPsicologia'],
      estadoGeneral: json['estadoGeneral'],
      estadoConfirmacion: json['estadoConfirmacion'],
      postulation: PostulationModel.fromJson(json['postulation'], json['postulation']['id']), // Cargar postulation desde JSON
    );
  }

  // Método para convertir una instancia a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nivel': nivel,
      'curso': curso,
      'ueProcedencia': ueProcedencia,
      'hermanosUEE': hermanosUEE,
      'nombreHermano': nombreHermano,
      'nombreEstudiante': nombreEstudiante,
      'obs': obs,
      'fechaEntrevista': fechaEntrevista,
      'psicologoEncargado': psicologoEncargado,
      'informeBreveEntrevista': informeBreveEntrevista,
      'recomendacionPsicologia': recomendacionPsicologia,
      'respuestaPPFF': respuestaPPFF,
      'fechaEntrevistaCoordinacion': fechaEntrevistaCoordinacion,
      'vistoBuenoCoordinacion': vistoBuenoCoordinacion,
      'respuestaAPpff': respuestaAPpff,
      'administracion': administracion,
      'recepcionDocumentos': recepcionDocumentos,
      'estadoEntrevistaPsicologia': estadoEntrevistaPsicologia,
      'estadoGeneral': estadoGeneral,
      'estadoConfirmacion': estadoConfirmacion,
      'postulation': postulation.toJson(), // Convertir postulation a JSON
    };
  }

}
