import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pr_h23_irlandes_web/data/model/notification_model.dart';
import 'package:pr_h23_irlandes_web/data/remote/notifications_remote_datasource.dart';
import 'package:pr_h23_irlandes_web/data/remote/user_remote_datasource.dart';

class NotificationPage extends StatelessWidget {
  NotificationPage({super.key});

  final NotificationRemoteDataSource notificationRemoteDataSource =
      NotificationRemoteDataSourceImpl();
  final PersonaDataSource userRemoteDataSource = PersonaDataSourceImpl();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 80,
        height: 80,
        child: ElevatedButton(
          onPressed: () async {
            //recuperar id persona
            String userToken = await userRemoteDataSource
                .getToken('0HQ8U0LKpZMug1WJOMXv'); //cambiar por id recuperado
            //Navigator.pushNamed(context, '/register_notice');
            NotificationModel notification = NotificationModel(
                title: 'pepe',
                deviceToken: userToken,
                content: 'Entrevista aceptada',
                userId: '0HQ8U0LKpZMug1WJOMXv',
                registerDate: DateTime.now());
            Map<String, dynamic> notificationBody = {
              'to': userToken,
              'notification': {
                'title': notification.title,
                'body': notification.content,
              }
            };
            String jsonNotificationBody = jsonEncode(notificationBody);
            var response = await http.post(Uri.parse(notification.url),
                headers: {
                  'Content-Type': 'application/json',
                  'Authorization': 'key=${notification.serverkey}'
                },
                body: jsonNotificationBody);
            print(response.statusCode);
            if (response.statusCode == 200) {
              notificationRemoteDataSource.addNotification(notification);
            }
          },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(const Color(0xFF044086)),
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
                side: const BorderSide(
                  color: Color(0xFF044086),
                  width: 2,
                ),
              ),
            ),
          ),
          child: const Text(
            'Enviar Notificación',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
            ),
          ),
        ),
      ),
    );
  }
}
