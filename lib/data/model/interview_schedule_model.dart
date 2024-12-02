import 'package:cloud_firestore/cloud_firestore.dart';

class InterviewScheduleModel{
  String? id;
  List<String> days;
  String start_time;
  String end_time;
  String limit_date;
  String status;
  DateTime register_date;
  DateTime last_update;

  InterviewScheduleModel({this.id, required this.days, required this.start_time, required this.end_time, required this.limit_date, 
                        required this.status, required this.register_date, required this.last_update});

 factory InterviewScheduleModel.fromJson(Map<String, dynamic> json, String id) {
    return InterviewScheduleModel(
      id: id,
      days: List<String>.from(json['days'] ?? []),
      start_time: json['start_time'] ?? '',
      end_time: json['end_time'] ?? '',
      limit_date: json['limit_date'] ?? '',
      status: json['status'] ?? '',
      last_update : (json['last_update'] as Timestamp? ?? Timestamp.fromDate(DateTime.now())).toDate(),
      register_date: (json['register_date'] as Timestamp? ?? Timestamp.fromDate(DateTime.now())).toDate()
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null && id!.isNotEmpty) 'id': id,
      'days': days,
      'start_time': start_time,
      'end_time': end_time,
      'limit_date': limit_date,
      'status': status,
      'last_update': last_update,
      'register_date': register_date,
    };
  }                        
}