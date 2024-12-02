class PersonaModel {
  String username;
  String password;
  String rol;
  String token;
  String cellphone;
  String ci;
  String direction;
  String id;
  String fatherId;
  String motherId;
  String lastname;
  String mail;
  String name;
  DateTime resgisterdate;
  int status;
  String surname;
  String telephone;
  String grade;
  double latitude;
  double longitude;
  String motherReference;
  String fatherReference;
  DateTime updatedate;

  PersonaModel({
    required this.username,
    required this.password,
    required this.rol,
    this.token = '',
    required this.cellphone,
    required this.ci,
    required this.direction,
    required this.id,
    required this.fatherId,
    required this.motherId,
    required this.lastname,
    required this.grade,
    required this.mail,
    required this.name,
    required this.resgisterdate,
    required this.status,
    required this.surname,
    required this.telephone,
    required this.latitude,
    required this.longitude,
    required this.motherReference,
    required this.fatherReference,
    required this.updatedate,
  });

  factory PersonaModel.fromJson(Map<String, dynamic> json) => PersonaModel(
        username: json['username'] ?? "",
        password: json['password'] ?? "",
        rol: json['rol'] ?? "",
        token: json['token'] ?? "",
        cellphone: json['cellphone'] ?? "",
        ci: json['ci'] ?? "",
        direction: json['direction'] ?? "",
        id: json['id'] ?? "",
        fatherId: json['fatherId'] ?? "",
        motherId: json['motherId'] ?? "",
        lastname: json['lastname'] ?? "",
        mail: json['mail'] ?? "",
        name: json['name'] ?? "",
        grade: json['grade'] ?? "",
        resgisterdate: DateTime.parse(json['registerdate']),
        //status: int.tryParse(['status'].toString()) ?? 0, anterior
        status: int.tryParse(json['status']?.toString() ?? '') ?? 0,
        surname: json['surname'] ?? "",
        telephone: json['telephone'] ?? "",
        latitude: json['latitude'] ?? -17.3833,
        longitude: json['longitude'] ?? -66.1667,
        motherReference: json['motherReference'] ?? "",
        fatherReference: json['fatherReference'] ?? "",
        updatedate: DateTime.parse(json['updatedate']),
      );
  static PersonaModel AdminHarcoded = PersonaModel(
    username: "Robert-A",
    //password: "5994471abb01112afcc18159f6cc74b4f511b99806da59b3caf5a9c173cacfc5",
    password: "12345",
    rol: "HardcodedAdmin", // Puedes ajustar esto según sea necesario
    token:
        "d_FabKUdS9mLw8b9wybAgL:APA91bGxp4EsF35spi09R2uvxdns4Lhrdo3BKJAykMrcyxatAiRXwsviAOtnSiI0XgZsTCcg7SUCfY9Aha7fYc-DzSlT0oy0DK6zNQQEiq7AxNNmSIwTD0zmc_T-zBQ7wuyws-CowViE",
    cellphone: "0000000000",
    ci: "12345678",
    direction: "Calle Ficticia 123",
    id: "WUUT2Rgy8cSXIpRmbRdW3",
    fatherId: "",
    motherId: "",
    lastname: "Sanchez",
    grade: "10",
    mail: "hardcodeduser@example.com",
    name: "James",
    resgisterdate: DateTime.now(),
    status: 1,
    surname: "Cordano",
    latitude: -17.3833,
    longitude: -66.1667,
    motherReference: "",
    fatherReference: "",
    telephone: "76457898",

    updatedate: DateTime.now(),
  );
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'rol': rol,
      'token': token,
      'cellphone': cellphone,
      'ci': ci,
      'direction': direction,
      'id': id,
      'fatherId': fatherId,
      'motherId': motherId,
      'lastname': lastname,
      'mail': mail,
      'grade': grade,
      'name': name,
      'registerdate': resgisterdate.toIso8601String(),
      'status': status,
      'surname': surname,
      'telephone': telephone,
      'latitude': latitude,
      'longitude': longitude,
      'motherReference': motherReference,
      'fatherReference': fatherReference,
      'updatedate': updatedate.toIso8601String(),
      //falta
    };
  }
}
