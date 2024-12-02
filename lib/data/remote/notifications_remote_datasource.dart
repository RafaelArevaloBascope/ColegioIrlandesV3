import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pr_h23_irlandes_web/data/model/notification_model.dart';

abstract class NotificationRemoteDataSource {
  //Son como interfaces
  Future<List<NotificationModel>> getNotification();
  Future<void> addNotification(NotificationModel notice);
  Future<NotificationModel> getNotificationByToken(String token);
}

class NotificationRemoteDataSourceImpl extends NotificationRemoteDataSource {
  final CollectionReference<NotificationModel> notificationFirestoreRef = FirebaseFirestore
      .instance
      .collection('Notifications')
      .withConverter<NotificationModel>(
          fromFirestore: (snapshot, options) =>
              NotificationModel.fromJson(snapshot.data()!, snapshot.id),
          toFirestore: (notification, options) => notification.toJson());

  @override
  Future<List<NotificationModel>> getNotification() async {
    //print('llega datasource: ');
    final NotificationDoc = await notificationFirestoreRef.get();
    final notification = NotificationDoc.docs.map((e) {
      //print('notice ${e.data()}');
      return e.data();
    });
    final listNotification = notification.toList();
    await Future.delayed(const Duration(seconds: 4));
    return listNotification;
  }

  @override
  Future<void> addNotification(NotificationModel notification) async {
    notificationFirestoreRef.add(notification);
  }


  @override
  Future<NotificationModel> getNotificationByToken(String token) async {
    final notificationDoc =
        await notificationFirestoreRef.where('deviceToken', isEqualTo: token).get();
    //Del primer registro entramos a data
    final notification = notificationDoc.docs.first.data();
    return notification;
  }
}
