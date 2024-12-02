import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pr_h23_irlandes_web/ui/pages/notice/notice_management_page.dart';
import 'package:pr_h23_irlandes_web/data/model/notice_model.dart';
import 'package:pr_h23_irlandes_web/data/remote/notice_remote_datasource.dart';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late DateTime _selectedDate = DateTime.now();
  late Map<DateTime, List<NoticeModel>> _events;
  bool isEditable = false;
  final noticeRemoteDataSource = NoticeRemoteDataSourceImpl();
  List<NoticeModel> notices = [];
  final Set<int> selectedRows = Set<int>();
  NoticeModel? noticeSelect;
  String datePickerText = 'Seleccione la fecha límite';

  @override
  void initState() {
    super.initState();
    _events = {};
    loadNotices(); // Carga las notificaciones al inicializar la página
  }

  Future<void> loadNotices() async {
    final loadedNotices = await noticeRemoteDataSource.getNotice();
    setState(() {
      notices = loadedNotices.where((notice) => notice.status).toList();
      _events = _loadEvents(); // Actualiza los eventos con los datos cargados
    });
  }

Map<DateTime, List<NoticeModel>> _loadEvents() {
  Map<DateTime, List<NoticeModel>> events = {};

  for (var notice in notices) {
    DateTime noticeDate = DateTime.parse(notice.registerCreated.toString());
    DateTime dateWithoutTime =
        DateTime(noticeDate.year, noticeDate.month, noticeDate.day); // Eliminamos la hora

    if (!events.containsKey(dateWithoutTime)) {
      events[dateWithoutTime] = [];
    }

    events[dateWithoutTime]?.add(notice);
  }

  // Imprimir los eventos para asegurarse de que están bien cargados
  print("Eventos cargados: $events");

  return events;
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendario de Notificaciones'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          TableCalendar(
            locale: 'es_ES',
            focusedDay: _selectedDate,
            firstDay: DateTime.utc(2023, 04, 15),
            lastDay: DateTime.utc(2050, 04, 15),
            eventLoader: _getEventsForDay,  // Cargar los eventos
            calendarFormat: CalendarFormat.month,
            selectedDayPredicate: (DateTime date) {
              return isSameDay(_selectedDate, date);
            },
            onDaySelected: (selectedDate, focusedDate) {
              setState(() {
                _selectedDate = selectedDate;
              });
            },
            calendarStyle: CalendarStyle(
              weekendTextStyle: TextStyle(color: Colors.red),
              defaultTextStyle: TextStyle(color: Colors.black),
              todayDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
            ),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (events.isNotEmpty) {
                  return Positioned(
                    right: 1,
                    bottom: 1,
                    child: Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${events.length}',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  );
                }
                return null;
              },
            ),
          ),
          SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ManagementNoticePage(
                      selectedDate: _selectedDate,
                    ),
                  ),
                );
              },
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(Color(0xFF064187)),
              ),
              child: Text(
                'Registrar Notificación para esta Fecha',
                style: TextStyle(color: Colors.white),
              ),
            ),
            _buildEventList(),
          ],
        ),
      ),
    );
  }

    List<NoticeModel> _getEventsForDay(DateTime day) {
      // Comparar solo el año, mes y día para no afectar con la hora
      return _events[DateTime(day.year, day.month, day.day)] ?? [];
    }


  Widget _buildEventList() {
    final notificationsForSelectedDate = notices.where((notice) {
      final noticeDate = notice.registerCreated; // Usamos directamente registerCreated
      return noticeDate.year == _selectedDate.year &&
          noticeDate.month == _selectedDate.month &&
          noticeDate.day == _selectedDate.day;
    }).toList();

    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'La fecha seleccionada es ${DateFormat('yyyy-MM-dd').format(_selectedDate)}:',
            style: TextStyle(color: Color(0xFF044086), fontSize: 20),
          ),
          SizedBox(height: 10),
          if (notificationsForSelectedDate.isNotEmpty) ...[
            for (var notice in notificationsForSelectedDate)
              _buildNoticeCard(notice),
          ] else
            Text(
              'No hay eventos para esta fecha.',
              style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
            ),
        ],
      ),
    );
  }


  Widget _buildNoticeCard(NoticeModel notice) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: notice.type == "Evento"
            ? Color(0xFF720E0F)
            : Color(0xFF064187),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Título: ${notice.title}',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          Text(
            'Tipo: ${notice.type}',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          Text(
            'Descripción: ${notice.description}',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              AwesomeDialog(
                context: context,
                dialogType: DialogType.warning,
                animType: AnimType.scale,
                title: 'Eliminar Anuncio',
                desc: '¿Seguro que quieres eliminar este anuncio?',
                btnCancelOnPress: () {},
                btnOkOnPress: () async {
                  await noticeRemoteDataSource.softDeleteNotice(notice);
                  loadNotices();
                },
                width: 400,
              ).show();
            },
            style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all<Color>(Color.fromARGB(255, 187, 204, 35)),
            ),
            child: Text(
              'Eliminar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
