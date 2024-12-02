import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomCardLicense extends StatelessWidget {
  // ignore: non_constant_identifier_names
  const CustomCardLicense({
    super.key, 
    required this.date, 
    required this.departure_time, 
    required this.return_time, 
    required this.reason, 
    required this.id, 
    required this.user_id,
    required this.onPressed});

  final String date;
  final String departure_time;
  final String return_time;
  final String reason;
  final String id;
  final String user_id;
  final void Function() onPressed;


  String formatDate(String date) {
    DateFormat inputFormat = DateFormat("MMM d, yyyy", "en_US");
    DateTime inputDate = inputFormat.parse(date);
  
    // Formateando la fecha al formato deseado
    String formattedDate = DateFormat("dd 'de' MMMM 'de' yyyy", 'es_ES').format(inputDate);
    return formattedDate; 
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(top: 5, bottom: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ), 
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(formatDate(date), style: const TextStyle(color:Color(0xFF044086), fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 5,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('De', style: TextStyle(color: Colors.black87, fontSize: 16)),
              Text(departure_time, style: const TextStyle(color: Colors.black87, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 3,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Hasta', style: TextStyle(color:Colors.black87, fontSize: 16)),
              Text(return_time, style: const TextStyle(color:Colors.black87, fontSize: 16)),
            ],
          ),
          const SizedBox(width: 3,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Motivo', style: TextStyle(color:Colors.black87, fontSize: 16)),
              Text(reason, style: const TextStyle(color:Colors.black87, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 5,),
          Row(
            mainAxisAlignment:MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        alignment: Alignment.center,
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [ 
                            const Text('¿Está seguro que desea eliminar esta licencia?', textAlign: TextAlign.center, style: TextStyle(color:Color(0xFF3D5269), fontWeight: FontWeight.bold, fontSize: 18)),                         
                            const SizedBox(height: 10,),                              
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 5, right: 5),
                                  child: ElevatedButton(
                                    onPressed: onPressed,
                                    style: ButtonStyle(backgroundColor: MaterialStateProperty.all( const Color(0xFF044086))
                                    ),
                                    child: const Text( 'Si', style:TextStyle(color: Colors.white))
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 5, right: 5),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    style: ButtonStyle(backgroundColor: MaterialStateProperty.all( const Color(0xFF044086))),
                                    child: const Text('No', style:TextStyle(color: Colors.white))
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      );
                    }
                  );
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(const Color(0xFF044086)),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // Ajusta el valor del radio como desees
                    ),
                  ),
                ),
                child: const Text(
                  'Eliminar',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 5,),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    '/license_verification',
                    arguments: {'id': id}
                  );
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(const Color(0xFF044086)),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // Ajusta el valor del radio como desees
                    ),
                  ),
                ),
                child: const Text(
                  'Comprobante',
                  style: TextStyle(color: Colors.white),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }  
}
