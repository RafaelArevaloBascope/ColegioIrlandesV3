import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pr_h23_irlandes_web/data/model/calls_model.dart';
import 'package:pr_h23_irlandes_web/data/remote/calls_remote_datasource.dart';
import 'package:pr_h23_irlandes_web/data/remote/user_remote_datasource.dart';
import 'package:pr_h23_irlandes_web/ui/widgets/app_bar_custom.dart';

class CallsHistory extends StatefulWidget {
  const CallsHistory({Key? key}) : super(key: key);

  @override
  CallsHistoryState createState() => CallsHistoryState();
}

final AttentionCallsRemoteDataSource _attentionCallsDataSource =
    AttentionCallsRemoteDataSource();
final PersonaDataSourceImpl personaDataSource = PersonaDataSourceImpl();

List<AttentionCallsModel> attentionCalls = [];

Future<List<AttentionCallsModel>> refreshAttentionCalls() async {
  attentionCalls = await _attentionCallsDataSource.getAttentionCalls();
  attentionCalls = attentionCalls
    ..sort((item1, item2) => item2.registrationDate.compareTo(item1.registrationDate));
  return attentionCalls;
}

class CallsHistoryState extends State<CallsHistory> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 227, 233, 244),
      appBar: const AppBarCustom(
        title: 'Historial de Notificaciones Estudiantiles',
      ),
      body: Center(
        child: FutureBuilder<List<AttentionCallsModel>>(
          future: refreshAttentionCalls(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Column(
                children: [
                  Expanded(
                    flex: 2,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, int index) {
                        final call = snapshot.data![index];
                        return Card(
                          elevation: 5,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _infoRow("Docente:", call.teacher),
                                _infoRow("Estudiante:", call.student),
                                _infoRow("Motivo:", call.motive),
                                _infoRow("Nivel:", call.level),
                                _infoRow("Curso:", call.course),
                                _infoRow(
                                  "Fecha de creación:",
                                  DateFormat('dd-MM-yyyy').format(
                                    DateTime.parse(call.registrationDate),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[900],
                        padding:
                            const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, '/notice_main');
                      },
                      child: const Text(
                        "Volver al menú principal",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              );
            } else {
              return const CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 51, 51, 51),
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Color.fromARGB(255, 51, 51, 51)),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
