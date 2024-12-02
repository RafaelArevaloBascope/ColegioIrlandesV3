import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pr_h23_irlandes_web/data/model/notice_model.dart';

abstract class NoticeRemoteDataSource {
  //Son como interfaces
  Future<List<NoticeModel>> getNotice();
  Future<void> addNotice(NoticeModel notice);
  Future<void> updateNotice(NoticeModel notice);
  Future<void> deleteNotice(NoticeModel notice);
  Future<void> softDeleteNotice(NoticeModel notice);

  Future<NoticeModel> getNoticeByTitle(String nombre);
}

class NoticeRemoteDataSourceImpl extends NoticeRemoteDataSource {
  final CollectionReference<NoticeModel> noticeFirestoreRef = FirebaseFirestore
      .instance
      .collection('Notice')
      .withConverter<NoticeModel>(
          fromFirestore: (snapshot, options) =>
              NoticeModel.fromJson(snapshot.data()!, snapshot.id),
          toFirestore: (notice, options) => notice.toJson());

  @override
  Future<List<NoticeModel>> getNotice() async {
    //print('llega datasource: ');
    final noticeDoc = await noticeFirestoreRef.get();
    final notice = noticeDoc.docs.map((e) {
      //print('notice ${e.data()}');
      return e.data();
    });
    final listNotice = notice.toList();
    await Future.delayed(const Duration(seconds: 4));
    return listNotice;
  }

  @override
  Future<void> addNotice(NoticeModel notice) async {
  //   notice.setTimestamps(
  //   registerCreated: DateTime.now(),
  //   updateDate: DateTime.now(),
  // );
    noticeFirestoreRef.add(notice);
  }

  @override
  Future<void> updateNotice(NoticeModel notice) async {
    // Utilizamos el método `set` para actualizar un documento existente en Firestore
    await noticeFirestoreRef.doc(notice.id).update(notice.toJson());
  }

@override
  Future<void> deleteNotice(NoticeModel notice) async {
    // Utilizamos el método `set` para actualizar un documento existente en Firestore
    await noticeFirestoreRef.doc(notice.id).update(notice.toJson());
  }
@override
Future<void> softDeleteNotice(NoticeModel notice) async {
  // Realiza un soft delete actualizando el campo `status`
  notice.status = false;
  await noticeFirestoreRef.doc(notice.id).update(notice.toJson());
}

  @override
  Future<NoticeModel> getNoticeByTitle(String nombre) async {
    final noticeDoc =
        await noticeFirestoreRef.where('title', isEqualTo: nombre).get();
    //Del primer registro entramos a data
    final notice = noticeDoc.docs.first.data();
    return notice;
  }
}
