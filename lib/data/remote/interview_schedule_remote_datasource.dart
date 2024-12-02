import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pr_h23_irlandes_web/data/model/interview_schedule_model.dart';

abstract class InterviewScheduleRemoteDatasource{
  Future <String> addInterviewSchedule(List<String> days, String start_time, String end_time, String limit_date, String status, DateTime last_update, DateTime register_date);
  Future <InterviewScheduleModel?> getActiveInterviewSchedule();
  Future <void> updateInterviewSchedule(InterviewScheduleModel interviewScheduleModel);
}


class InterviewScheduleRemoteDatasourceImpl extends InterviewScheduleRemoteDatasource {
  final CollectionReference<InterviewScheduleModel> interviewScheduleFirestoreRef =FirebaseFirestore.instance.collection('Interview_Schedule').withConverter<InterviewScheduleModel>(fromFirestore: (snapshot, options) =>InterviewScheduleModel.fromJson(snapshot.data()!,snapshot.id),toFirestore: (interviewSchedule, options) => interviewSchedule.toJson());

  @override
  Future<String> addInterviewSchedule(List<String> days, String start_time, String end_time, String limit_date, String status, 
                                      DateTime last_update, DateTime register_date) async {

    final interviewShedule= InterviewScheduleModel(days:days, start_time: start_time, end_time: end_time, limit_date:limit_date, status:status, 
                                                  last_update: last_update, register_date:register_date);

    //Creando un nuevo documento
    DocumentReference docRef = await interviewScheduleFirestoreRef.add(interviewShedule);

    // Retornando el ID del documento creado
    return docRef.id;
  }  

  @override
  Future<InterviewScheduleModel?> getActiveInterviewSchedule() async {
    final interviewScheduleDocs = await interviewScheduleFirestoreRef.where('status', isEqualTo: 'ACTIVE').get();

    await Future.delayed(const Duration(seconds: 4));

    if (interviewScheduleDocs.docs.isEmpty) {
      return null;
    }

    return interviewScheduleDocs.docs.first.data();
  }
  
  @override
  Future <void> updateInterviewSchedule(InterviewScheduleModel interviewScheduleModel) async {
    final docRef = await interviewScheduleFirestoreRef.doc(interviewScheduleModel.id);
    
    // Actualizando el documento
    await docRef.update({'days': interviewScheduleModel.days,
                        'start_time': interviewScheduleModel.start_time,
                        'end_time': interviewScheduleModel.end_time,
                        'limit_date': interviewScheduleModel.limit_date,
                        'status': interviewScheduleModel.status,
                        'last_update': interviewScheduleModel.last_update,
                        'register_date': interviewScheduleModel.register_date});
  }
}