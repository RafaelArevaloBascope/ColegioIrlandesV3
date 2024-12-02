import 'package:flutter/material.dart';
import 'package:pr_h23_irlandes_web/data/model/notice_model.dart';
import 'package:pr_h23_irlandes_web/data/remote/notice_remote_datasource.dart';
import 'package:pr_h23_irlandes_web/ui/widgets/app_bar_custom_prueba.dart';
import 'package:pr_h23_irlandes_web/ui/widgets/custom_drawer.dart';
import 'package:pr_h23_irlandes_web/ui/widgets/custom_text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NoticeMainPage extends StatefulWidget {
  const NoticeMainPage({Key? key}) : super(key: key);

  @override
  _NoticeMainPageState createState() => _NoticeMainPageState();
}

class _NoticeMainPageState extends State<NoticeMainPage> {
  final TextEditingController _controller = TextEditingController();
  final NoticeRemoteDataSource noticeRemoteDataSource =
      NoticeRemoteDataSourceImpl();
  List<NoticeModel> noticeList = [];
  List<NoticeModel> allNotices = [];
  bool isLoading = true;


  @override
  void initState() {
    super.initState();
    _loadNotices();
  }

  Future<void> _loadNotices() async {
    try {
      final notices = await noticeRemoteDataSource.getNotice();
      setState(() {
        allNotices = notices.where((notice) => notice.status == true).toList();;
        noticeList = List.from(allNotices); // Crear una copia para evitar referencia directa
        filterNotices(""); // Inicialmente, muestra todos los avisos
        isLoading = false; // Marcar que la carga ha finalizado
      });
    } catch (error) {
      // Manejar errores de carga de datos si es necesario
      print("Error cargando los anuncios: $error");
    }
  }

  List<NoticeModel> filterByType(List<NoticeModel> notices, String type) {
    return notices.where((notice) => notice.type == type).toList();
  }

  void filterNotices(String searchTerm) {
    if (searchTerm.isEmpty) {
      setState(() {
        noticeList = List.from(allNotices);
      });
    } else {
      setState(() {
        noticeList = allNotices
            .where((notice) =>
                notice.title.toLowerCase().contains(searchTerm.toLowerCase()))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final meetingNotices = filterByType(noticeList, "Reunion");
    final eventNotices = filterByType(noticeList, "Evento");

    return WillPopScope(
      onWillPop: () async {
        final confirmLogout = await _confirmLogout2(context);
        return !confirmLogout;
      },
      child: Scaffold(
        appBar: const AppBarCustomPrueba(
          title: 'Anuncios',
        ),
        drawer: CustomDrawer(),
        backgroundColor: const Color(0XFFE3E9F4),
        body: Padding(
          padding: const EdgeInsets.only(
            top: 0,
            bottom: 90,
            left: 90,
            right: 90,
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 380, right: 350),
                child: Row(
                  children: [
                    const Image(
                      image: AssetImage('assets/ui/lupa.png'),
                      width: 35,
                      height: 35,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomTextField(
                        label: 'Buscar',
                        controller: _controller,
                        onChanged: (p0) {
                          if (p0 != null) {
                            filterNotices(p0);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 40),
                    SizedBox(
                      width: 150,
                      height: 30,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/register_notice');
                        },
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(const Color(0xFF044086)),
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
                          'Crear anuncio',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Expanded(
                child: isLoading
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(
                          children: [
                          if (meetingNotices.isNotEmpty &&
                                meetingNotices.any((notice) {
                                  DateTime now = DateTime.now();
                                  DateTime twoWeeksFromNow = now.add(Duration(days: 14));
                                  return notice.registerCreated.isAfter(now.subtract(Duration(days: 1))) && notice.registerCreated.isBefore(twoWeeksFromNow);
                                }))
                              Padding(
                                padding: const EdgeInsets.all(25),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 20,
                                      color: const Color(0xFF044086),
                                    ),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    const Text(
                                      'Reuniones',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            GridView.builder(
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: 4,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                              itemCount: meetingNotices.length,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                final notice = meetingNotices[index];
                                DateTime now = DateTime.now();
                                DateTime twoWeeksFromNow = now.add(Duration(days: 14));
                                if (notice.registerCreated.isAfter(now.subtract(Duration(days: 1))) && notice.registerCreated.isBefore(twoWeeksFromNow)) {
                                  return buildNoticeCard(notice);
                                } else {
                                  return Container(); // No mostrar el aviso si no está en el rango de 14 días
                                }
                              },
                            ),

                            if (eventNotices.isNotEmpty &&
                                eventNotices.any((notice) {
                                  DateTime now = DateTime.now();
                                  DateTime twoWeeksFromNow = now.add(Duration(days: 14));
                                  return notice.registerCreated.isAfter(now.subtract(Duration(days: 1))) && notice.registerCreated.isBefore(twoWeeksFromNow);
                                }))
                              Padding(
                                padding: const EdgeInsets.all(25),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 20,
                                      color: const Color(0xFF044086),
                                    ),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    const Text(
                                      'Eventos',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            GridView.builder(
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: 4,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                              itemCount: eventNotices.length,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                final notice = eventNotices[index];
                                DateTime now = DateTime.now();
                                DateTime twoWeeksFromNow = now.add(Duration(days: 14));
                                if (notice.registerCreated.isAfter(now.subtract(Duration(days: 1))) && notice.registerCreated.isBefore(twoWeeksFromNow)) {
                                  return buildNoticeCard(notice);
                                } else {
                                  return Container(); // No mostrar el aviso si no está en el rango de 14 días
                                }
                              },
                            )

                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }Widget buildNoticeCard(NoticeModel notice) {
  // Determinar el color basado en el tipo de aviso
  Color cardColor = notice.type == "Evento" ? Color(0xFF720E0F) : const Color(0xFF044086);

  // Formatear la fecha para mostrar solo los primeros 10 caracteres
  String formattedDate = notice.registerCreated.toIso8601String().substring(0, 10);

  return Padding(
    padding: const EdgeInsets.only(bottom: 10, top: 0, left: 10, right: 10),
    child: Container(
      margin: const EdgeInsets.only(bottom: 0, top: 0, left: 10, right: 10),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        color: cardColor, // Establecer el color basado en el tipo de aviso
        elevation: 8,
        shadowColor: Colors.blue,
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: <Widget>[
                ListTile(
                  title: Text(
                    notice.title,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notice.description,
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Fecha: $formattedDate',
                        style: const TextStyle(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}



  Future<bool> _confirmLogout2(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cerrar Sesión'),
          content: const Text('¿Está seguro de que desea cerrar sesión?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/notice_main');
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                _logout2(context);
                Navigator.of(context).pop(true);
              },
              child: const Text('Cerrar Sesión'),
            ),
          ],
        );
      },
    ) ?? false;
  }

  void _logout2(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('personId');
    Navigator.pushReplacementNamed(context, '/');
  }
}
