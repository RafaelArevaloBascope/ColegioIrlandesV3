import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';  
import 'package:intl/intl.dart';
import 'package:pr_h23_irlandes_web/data/model/notice_model.dart';
import 'package:pr_h23_irlandes_web/data/remote/notice_remote_datasource.dart';
import 'package:pr_h23_irlandes_web/ui/widgets/app_bar_custom_prueba.dart';
import 'package:pr_h23_irlandes_web/ui/pages/Calendar/Calendar_page.dart';
import 'package:pr_h23_irlandes_web/ui/widgets/custom_drawer.dart';
import 'package:pr_h23_irlandes_web/ui/widgets/custom_text_field.dart';


class ManagementNoticePage extends StatefulWidget {
  //para capturar la fecha del calendario
  final DateTime? selectedDate;
  ManagementNoticePage({required this.selectedDate});

  @override
  _ManagementNoticePageState createState() => _ManagementNoticePageState();


}

class _ManagementNoticePageState extends State<ManagementNoticePage> {
  
  String _tipo = 'Reunion';
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  late DateTime _currentDateTime;
  bool isEditable = false;
  NoticeModel? noticeSelect;
  String tituloAux = '';
  String typeAux = '';
  late DateTime registerDateAux;
  String descriptionAux = '';
  bool isHovered = false;
  final formKey = GlobalKey<FormState>();

  final noticeRemoteDataSource = NoticeRemoteDataSourceImpl();
  
  final Set<int> selectedRows = Set<int>();
  List<NoticeModel> notices = [];
  String datePickerText = 'Seleccione la fecha limite';

  @override
  void initState() {
    super.initState();
    _currentDateTime = DateTime.now();
    loadNotices();
  
  }

  Future<void> loadNotices() async {
    final loadedNotices = await noticeRemoteDataSource.getNotice();
    setState(() {
      notices = loadedNotices.where((notice) => notice.status).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Administración de anuncios',
            style: GoogleFonts.barlow(
                textStyle: const TextStyle(
                    color: Color(0xFF3D5269),
                    fontSize: 24,
                    fontWeight: FontWeight.bold))),
        backgroundColor: Colors.white,
        toolbarHeight: 75,
        elevation: 0,
        leading: Center(
          child: Builder(
            builder: (context) => IconButton(
              iconSize: 50,
              icon: const Image(
                  image: AssetImage('assets/ui/barra-de-menus.png')),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            ),
          ),
        ),
        actions: [
          IconButton(
              iconSize: 2,
              icon: Image.asset(
                'assets/ui/home.png',
                width: 50,
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/notice_main');
              })
        ],
      ),
      drawer: CustomDrawer(),
      body: Row(
        children: [
          Expanded(
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              margin: const EdgeInsets.all(20),
              color: Colors.white,
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.all(16.0),
                        child: CustomTextField(
                          label: 'Titulo',
                          controller: _titleController,
                          onChanged: (p0) {},
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Por favor, ingresa un título.';
                            }
                            return null; // Validación pasó con éxito
                          },
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(16.0),
                        child: DropdownButtonFormField<String>(
                          value: _tipo,
                          onChanged: (value) {
                            setState(() {
                              _tipo = value!;
                            });
                          },
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                  10.0), // Ajusta el radio según tus preferencias
                              borderSide: const BorderSide(
                                color:
                                    Colors.white, // Cambia el color del borde
                                width:
                                    0, // Cambia el ancho del borde si lo deseas
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(
                                color: Colors
                                    .white, // Cambia el color del borde cuando está enfocado
                                //width: 2.0,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: Colors.transparent,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.white, // Color de fondo
                          ),
                          items: const [
                            DropdownMenuItem<String>(
                              value: 'Reunion',
                              child: Text(
                                'Reunion',
                                style: TextStyle(
                                  color: Color(0xFF044086),
                                ),
                              ),
                            ),
                            DropdownMenuItem<String>(
                              value: 'Evento',
                              child: Text(
                                'Evento',
                                style: TextStyle(
                                  color: Color(0xff044086),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Container(
                        margin: const EdgeInsets.all(16.0),
                        child: CustomTextField(
                          label: 'Descripción',
                          maxLines: 6,
                          controller: _descriptionController,
                          onChanged: (p0) {},
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Por favor, ingresa una descripción.';
                            }
                            return null; // Validación pasó con éxito
                          },
                        ),
                      ),

                      Row(
                        children: [
                          Container(
                            margin: const EdgeInsets.all(16.0),
                            child: InkWell(
                              onTap: isEditable
                                  ? null
                                  : () async {
                                      if (formKey.currentState!.validate()) {
                                        // Aquí puedes guardar o registrar la información si la validación pasa
                                        if (_titleController.text.isNotEmpty &&
                                            _descriptionController
                                                .text.isNotEmpty) {
                                          final newNotice = NoticeModel(
                                            id: '',
                                            title: _titleController.text,
                                            type: _tipo,
                                            description:
                                                _descriptionController.text,
                                            status: true,
                                            registerCreated: widget.selectedDate ?? DateTime.now(), // Utiliza la fecha seleccionada del calendario
                                            updateDate: _currentDateTime,
                                          );

                                          await noticeRemoteDataSource
                                              .addNotice(newNotice);
                                          loadNotices(); // Cargar la lista de anuncios nuevamente
                                          setState(() {
                                            _titleController.text = '';
                                            _tipo = 'Reunion';
                                            _descriptionController.text = '';
                                          });
                                        }
                                      }
                                    },
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Icon(
                                  //   Icons.add,
                                  //   size: 20, // Tamaño del icono
                                  //   color: Color(0xFF044086), // Color del icono
                                  // ),
                                  Image.asset(
                                    'assets/ui/insertar.png', // Reemplaza con la ubicación de tu ícono personalizado
                                    width: 40, // Ancho del ícono
                                    height: 40, // Alto del ícono
                                    color: const Color(0xFF044086),
                                  ),
                                  const Text(
                                    'Registrar',
                                    style: TextStyle(
                                      color: Color(0xFF044086),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.all(16.0),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  isEditable = false;
                                  noticeSelect = null;
                                  _titleController.text = '';
                                  _tipo = 'Reunion';
                                  _descriptionController.text = '';
                                });
                              },
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(
                                    'assets/ui/limpiar.png', // Reemplaza con la ubicación de tu ícono personalizado
                                    width: 40, // Ancho del ícono
                                    height: 40, // Alto del ícono
                                    color: const Color(0xFF044086),
                                  ),
                                  const Text(
                                    'Limpiar',
                                    style: TextStyle(
                                      color: Color(0xFF044086),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          //Editar Nuevo
                           Container(
                            margin: const EdgeInsets.all(16.0),
                            child: InkWell(
                              onTap: () {
                                 AwesomeDialog(
                                            context: context,
                                            dialogType: DialogType.warning,
                                            animType: AnimType.scale,
                                            title: 'Editar Anuncio',
                                            desc:
                                                '¿Seguro que quieres editar este anuncio?',
                                            btnCancelOnPress: () {},
                                            btnOkOnPress: isEditable
                                                ? () async {
                                                    if (formKey.currentState!
                                                        .validate()) {
                                                      // Aquí puedes guardar o registrar la información si la validación pasa
                                                      if (_titleController.text
                                                              .isNotEmpty &&
                                                          _descriptionController
                                                              .text
                                                              .isNotEmpty &&
                                                          noticeSelect !=
                                                              null) {
                                                        noticeSelect!.title =
                                                            _titleController
                                                                .text;
                                                        noticeSelect!.type =
                                                            _tipo;
                                                        noticeSelect!
                                                                .description =
                                                            _descriptionController
                                                                .text;
                                                        noticeSelect!
                                                                .updateDate =
                                                            _currentDateTime;
                                                        noticeSelect!.status =
                                                            true; // Soft delete

                                                        await noticeRemoteDataSource
                                                            .updateNotice(
                                                                noticeSelect!);
                                                                
                                                        loadNotices(); // Cargar la lista de anuncios nuevamente

                                                        setState(() {
                                                          isEditable = false;
                                                          noticeSelect = null;
                                                          _titleController
                                                              .text = '';
                                                          _tipo = 'Reunion';
                                                          _descriptionController
                                                              .text = '';
                                                        });
                                                      }
                                                    }
                                                  }
                                                : null,
                                            width: 400,
                                          ).show();
                              },
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(
                                    'assets/ui/editar.png', // Reemplaza con la ubicación de tu ícono personalizado
                                    width: 40, // Ancho del ícono
                                    height: 40, // Alto del ícono
                                    color: const Color(0xFF044086),
                                  ),
                                  const Text(
                                    'Editar Anuncio',
                                    style: TextStyle(
                                      color: Color(0xFF044086),
                                    ),
                                  ),

                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
                alignment: Alignment.topCenter,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: FutureBuilder(
                      future: loadNotices(),
                      builder: (context, snapshot) {
                        if (notices.isEmpty) {
                          return const CircularProgressIndicator();
                        } else {
                          return Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            margin: const EdgeInsets.all(20),
                            color: Colors.white,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: DataTable(
                                dataRowMinHeight: 25,
                                dataRowMaxHeight: 150,
                                showCheckboxColumn: false,
                                columns: const [
                                  DataColumn(label: Text('Título')),
                                  DataColumn(label: Text('Tipo')),
                                  DataColumn(label: Text('Descripción')),
                              
                                  DataColumn(label: Text('Eliminar')),
                                ],
                                rows: notices.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final anuncio = entry.value;

                                  return DataRow(
                                    selected: selectedRows.contains(index),
                                    onSelectChanged: (isSelected) {
                                      setState(() {
                                        if (isSelected!) {
                                          selectedRows.add(index);
                                          noticeSelect = anuncio;
                                          isEditable = true;
                                          _titleController.text = anuncio.title;
                                          _tipo = anuncio.type;
                                          _descriptionController.text =
                                              anuncio.description;
                                        } else {
                                          selectedRows.remove(index);
                                        }
                                      });
                                    },
                                    cells: [
                                      DataCell(Text(anuncio.title)),
                                      DataCell(Text(anuncio.type)),
                                      DataCell(
                                        Container(
                                          width:
                                              150, // Ajusta este valor según tus preferencias
                                          child: Text(
                                            anuncio.description,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      DataCell(Center(
                                          child: InkWell(
                                        onTap: () {
                                          noticeSelect = notices[index];
                                          AwesomeDialog(
                                            context: context,
                                            dialogType: DialogType.warning,
                                            animType: AnimType.scale,
                                            title: 'Eliminar Anuncio',
                                            desc:
                                                '¿Seguro que quieres eliminar este anuncio?',
                                            btnCancelOnPress: () {},
                                            btnOkOnPress: () async {
                                              noticeSelect!.status = false;
                                              await noticeRemoteDataSource
                                                  .softDeleteNotice(
                                                      noticeSelect!);
                                              loadNotices();
                                              setState(() {
                                                selectedRows.remove(index);
                                                noticeSelect = null;
                                              });
                                            },
                                            width: 400,
                                          ).show();
                                        },
                                        child: const Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.delete,
                                              size: 25, // Tamaño del icono
                                              color: Color(
                                                  0xFF044086), // Color del icono
                                            ),
                                          ],
                                        ),
                                      ))),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          );
                        }
                      }),
                )),
          ),
        ],
      ),
    );
  }
}
