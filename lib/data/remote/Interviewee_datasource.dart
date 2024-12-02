
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pr_h23_irlandes_web/data/model/Interviewee_model.dart';
abstract class InterviewRemoteDatasource {
  Future<List<IntervieweeModel>> getInterviews();
  Future<String> createInterview(IntervieweeModel interview);
  Future<IntervieweeModel> getInterviewByID(String interviewID);
  Future<List<IntervieweeModel>> getInterviewsAfterDate(DateTime date);
  Future<void> updateInterview(IntervieweeModel interview);
  Future<void> deleteInterview(String interviewID);
  Future<void> updateInterviewStatus(String interviewID, String status);
}
class InterviewRemoteDatasourceImpl extends InterviewRemoteDatasource {
  final CollectionReference<IntervieweeModel> interviewFirestoreRef =
  FirebaseFirestore.instance.collection('Interviews').withConverter<IntervieweeModel>(
    fromFirestore: (snapshot, options) => IntervieweeModel.fromJson(snapshot.data()!),
    toFirestore: (interview, options) => interview.toJson(),
  );

  @override
  Future<String> createInterview(IntervieweeModel interview) async {
    DocumentReference docRef = await interviewFirestoreRef.add(interview);
    return docRef.id;
  }

  @override
  Future<void> updateInterview(IntervieweeModel interview) async {
    await interviewFirestoreRef.doc(interview.id).update(interview.toJson());
  }

  @override
  Future<void> deleteInterview(String interviewID) async {
    final interviewDoc = interviewFirestoreRef.doc(interviewID);
    await interviewDoc.delete();
  }

  @override
  Future<List<IntervieweeModel>> getInterviews() async {
    final interviewDocs = await interviewFirestoreRef.get();
    final interviews = interviewDocs.docs.map((e) => e.data()).toList();

    interviews.sort((a, b) {
      DateTime dateA = DateTime.parse(a.fechaEntrevista);
      DateTime dateB = DateTime.parse(b.fechaEntrevista);
      return dateA.compareTo(dateB);
    });

    return interviews;
  }

  @override
  Future<List<IntervieweeModel>> getInterviewsAfterDate(DateTime date) async {
    final interviewDocs = await interviewFirestoreRef.get();
    final interviews = interviewDocs.docs.map((e) => e.data()).toList();

    final filteredInterviews = interviews.where((interview) {
      DateTime interviewDate = DateTime.parse(interview.fechaEntrevista);
      return interviewDate.isAfter(date);
    }).toList();

    return filteredInterviews;
  }

  @override
  Future<IntervieweeModel> getInterviewByID(String interviewID) async {
    final interviewDoc = await interviewFirestoreRef.doc(interviewID).get();
    final interview = interviewDoc.data();
    return interview!;
  }

  @override
  Future<void> updateInterviewStatus(String interviewID, String status) async {
    await interviewFirestoreRef.doc(interviewID).update({'estadoEntrevistaPsicologia': status});
  }
}