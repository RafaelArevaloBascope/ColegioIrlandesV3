class NoticeModel {
  String id;
  String title;
  String type;
  String description;
  bool status;
  DateTime registerCreated;
  DateTime updateDate;

  
  NoticeModel({required this.id, required this.title, required this.type, required this.description, required this.status, required this.registerCreated, required this.updateDate});
  
//casteo del json que llega de firebase a un modelo
  factory NoticeModel.fromJson(Map<String, dynamic> json, String id) => NoticeModel(
        id: id ,
        title: json['title'] ??"",//si el parametro no existe es nulll
        type: json['type'] ??"",
        description: json['description'] ??"",
        status: json['status'] ?? true  ,
        registerCreated: DateTime.parse(json['registerCreated']) ,
        updateDate: DateTime.parse(json['updateDate']),
      );

  //del modelo ya instanciado enviamos un modelo de tipo json para que se registre en firebase
   Map<String, dynamic> toJson() {
    //  final registerCreatedFormatted = DateFormat('yy-MM-dd HH:mm:ss').format(registerCreated);
    // final updateDateFormatted = DateFormat('yy-MM-dd HH:mm:ss').format(updateDate);
    return {
      'title': title,
      'type': type,
      'description': description,
      'status': status,
      // 'registerCreated': registerCreatedFormatted,
      // 'updateDate': updateDateFormatted,
      'registerCreated': registerCreated.toIso8601String(),
      'updateDate': updateDate.toIso8601String(),

    };
  }
  // void setTimestamps({DateTime? registerCreated, DateTime? updateDate}) {
  //   this.registerCreated = registerCreated ?? DateTime.now();
  //   this.updateDate = updateDate ?? DateTime.now();
  // }

  // void updateAttributes({
  //   bool? status,
  //   DateTime? updateDate,
  // }) {
  //   this.status = status ?? this.status;
  //   this.updateDate = updateDate ?? this.updateDate;
  // }

}