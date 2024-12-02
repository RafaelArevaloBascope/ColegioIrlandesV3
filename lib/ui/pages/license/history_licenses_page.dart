import 'package:flutter/material.dart';
import 'package:pr_h23_irlandes_web/data/model/License_model.dart';
import 'package:pr_h23_irlandes_web/data/model/person_model.dart';
import 'package:pr_h23_irlandes_web/data/remote/license_remote_datasource.dart';
import 'package:pr_h23_irlandes_web/data/remote/user_remote_datasource.dart';
import 'package:pr_h23_irlandes_web/ui/widgets/custom_card_license.dart';
import 'package:pr_h23_irlandes_web/ui/widgets/custom_text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryLicenses extends StatefulWidget {
  const HistoryLicenses({super.key});

  @override
  State<HistoryLicenses> createState() => _HistoryLicensesState();  

  static Future<List<LicenseModel>> refreshLicenses(String userId) async{
    LicenseRemoteDatasourceImpl licenseRemoteDatasourceImpl = LicenseRemoteDatasourceImpl();
    return await licenseRemoteDatasourceImpl.getLicensesByStudentID(userId);
  }
}

class _HistoryLicensesState extends State<HistoryLicenses> {
  TextEditingController fullnameController = TextEditingController();
  final PersonaDataSourceImpl _personaDataSource  =  PersonaDataSourceImpl();

  bool mostrarSearch = false;
  PersonaModel? selectStudent;
  late List<PersonaModel> filerStudents;
  String personaId = '';  
  bool isLoading  = true;

  List<PersonaModel> students = [];  

  List<PersonaModel> filterStudents(String name, List<PersonaModel> students) {
    return students.where((student) {
      final fullName = '${student.name.toLowerCase()} ${student.lastname.toLowerCase()} ${student.surname.toLowerCase()}';
      return fullName.contains(name.toLowerCase());
    }).toList();
  }

  InputDecoration customDecoration(String label) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      labelText: label,
      labelStyle: const TextStyle(
        color:Color(0xFF044086)
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color:Color(0xFF044086)
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Colors.transparent,
        ),
      ),
    );
  }

  @override
  void initState(){
    super.initState();

    SharedPreferences.getInstance().then((value) => {
      personaId = value.getString('personId')!,
      _personaDataSource.getStudents().then((value) => {      
        isLoading = true,
        students = value,
        selectStudent = students[0],        
        if (mounted)
          {
            setState(() {
              isLoading = false;
            })
          }
      }),
    }); 
    filerStudents = filterStudents('', students);
  }

  @override
  void dispose(){
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final leftPadding = screenWidth * 0.075;
    final rightPadding = screenWidth * 0.075; 

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 75,
        elevation: 0,
        centerTitle: true,
        title: const Text('Historial de licencias', style: TextStyle(color:Color(0xFF3D5269), fontWeight: FontWeight.bold, fontSize: 20)),
      ),
      body: isLoading ? const Center(child: CircularProgressIndicator(),)
      :Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              width: constraints.maxWidth * 0.6,
              constraints: const BoxConstraints(
                minWidth: 700.0,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFE3E9F4),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(50),
                child: Column(
                  children: [
                    const SizedBox(height: 20,),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child:Text('Buscar estudiante', textAlign: TextAlign.left, style: TextStyle(color: Color(0xFF044086), fontSize: 20, fontWeight: FontWeight.bold),),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 5, bottom: 2, left: 8, right: 8),
                      child: CustomTextField(
                        label: 'Nombre Completo',
                        controller: fullnameController,
                        onChanged: (value) => {
                          if(fullnameController.text.trim() != ''){
                            mostrarSearch = true,
                            filerStudents = filterStudents(fullnameController.text.trim(), students),
                          } else{
                            mostrarSearch = false,
                          },
                          setState(() {})
                        },
                      ),
                    ),
                    if (filerStudents.isNotEmpty && mostrarSearch)
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 60.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.0),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              spreadRadius: 1,
                              blurRadius: 3,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        height: 150,
                        child: ListView.builder(
                          itemCount: filerStudents.length,
                          itemBuilder: (context, index) {
                            return Card(
                              elevation: 2.0,
                              margin: const EdgeInsets.symmetric(
                                  vertical: 5.0, horizontal: 8.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(10.0),
                                title: filerStudents[index].grade.trim() != ''? Text('${filerStudents[index].name.toLowerCase()} ${filerStudents[index].lastname.toLowerCase()} ${filerStudents[index].surname.toLowerCase()}, ${filerStudents[index].grade}')
                                      : Text('${filerStudents[index].name.toLowerCase()} ${filerStudents[index].lastname.toLowerCase()} ${filerStudents[index].surname.toLowerCase()}'),
                                onTap: () async {
                                  selectStudent = filerStudents[index];
                                  mostrarSearch = false;
                                  setState(() {});                             
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 10,),
                      if(selectStudent!.name != '')
                       Text('${selectStudent!.name} ${selectStudent!.lastname} ${selectStudent!.surname}  ${selectStudent!.grade.trim() != '' ? ', ${selectStudent!.grade}':''}'),
                    const SizedBox(height: 20,),
                    if(selectStudent !=  null)
                    FutureBuilder<List<LicenseModel>>(
                      future: HistoryLicenses.refreshLicenses(selectStudent!.id),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return const Text('Error al cargar.');
                        } else if (!snapshot.hasData || snapshot.data == null||snapshot.data!.isEmpty) {
                          return const Center(child: Text('No hay licencias.'),) ;
                        } else {
                          List<LicenseModel>? licenses = snapshot.data;
                          return Expanded(
                            child: RefreshIndicator(
                              onRefresh: () async {
                                setState(() {});
                              },
                              child: ListView.builder(
                                padding: EdgeInsets.only(top: 5,bottom: 30, left: leftPadding, right: rightPadding),
                                itemCount: licenses!.length,
                                itemBuilder: (context, index) {
                                  final license = licenses[index];                        
                                  return CustomCardLicense(
                                    date: license.license_date,
                                    departure_time: license.departure_time,
                                    return_time: license.return_time,
                                    reason: license.reason,
                                    id: license.id.toString(),
                                    user_id: license.user!.id,
                                    onPressed: () {
                                      LicenseRemoteDatasourceImpl licenseRemoteDatasourceImpl = LicenseRemoteDatasourceImpl();
                                      licenseRemoteDatasourceImpl.updateLicenseStatus(license.id.toString(), 'ELIMINATE');
                                      HistoryLicenses.refreshLicenses(license.user!.id);
                                      setState(() {});
                                      Navigator.of(context).pop();
                                    },
                                  );
                                },
                              ),
                            )
                          );
                        }
                      },
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}


