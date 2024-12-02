class NotificationModel {
  String title;
  String serverkey =
      'AAAAUIGIbpE:APA91bHAtPSkpv5oULz13Kz8g4vNv0lQlHGyppopHeq57coDY7ul_0yY-PltghDfG_8YCV7Yt7azwqEFqISBv5BQGJHMRGfa2gRvp1stxATFbewthVmao7X8Ev2ghYMvXWnexidnkF8t';
  String deviceToken;
  String url = 'https://fcm.googleapis.com/fcm/send';
  String content;
  String userId;
  DateTime registerDate;

  NotificationModel(
      {required this.title,
      required this.deviceToken,
      required this.content,
      required this.userId,
      required this.registerDate});

  factory NotificationModel.fromJson(Map<String, dynamic> json, String id) =>
      NotificationModel(
          title: json['title'] ?? "",
          deviceToken: json['deviceToken'] ?? "",
          content: json['content'] ?? "",
          userId: json['userId'] ?? "",
          registerDate: DateTime.parse(json['registerDate']));

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'deviceToken': deviceToken,
      'url': url,
      'content': content,
      'userId': userId,
      'registerDate': registerDate.toIso8601String(),
    };
  }
}
