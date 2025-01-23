class Participant {
  final int? id;
  final String bibNumber;
  final String firstName;
  final String lastName;
  final String gender;
  final DateTime dateOfBirth;
  final String? address;
  final String city;
  final String province;
  final String country;
  final String email;
  final String cellphone;
  final String category;
  final String? startTime;
  final String? finishTime;
  final String? averagePace;
  final String? splits;

  Participant({
    this.id,
    required this.bibNumber,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.dateOfBirth,
    this.address,
    required this.city,
    required this.province,
    required this.country,
    required this.email,
    required this.cellphone,
    required this.category,
    this.startTime,
    this.finishTime,
    this.averagePace,
    this.splits,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bib_number': bibNumber,
      'first_name': firstName,
      'last_name': lastName,
      'gender': gender,
      'date_of_birth': dateOfBirth.toIso8601String(),
      'address': address,
      'city': city,
      'province': province,
      'country': country,
      'email': email,
      'cellphone': cellphone,
      'category': category,
      'start_time': startTime,
      'finish_time': finishTime,
      'average_pace': averagePace,
      'splits': splits,
    };
  }

  factory Participant.fromMap(Map<String, dynamic> map) {
    return Participant(
      id: map['id'],
      bibNumber: map['bib_number'],
      firstName: map['first_name'],
      lastName: map['last_name'],
      gender: map['gender'],
      dateOfBirth: DateTime.parse(map['date_of_birth']),
      address: map['address'],
      city: map['city'],
      province: map['province'],
      country: map['country'],
      email: map['email'],
      cellphone: map['cellphone'],
      category: map['category'],
      startTime: map['start_time'],
      finishTime: map['finish_time'],
      averagePace: map['average_pace'],
      splits: map['splits'],
    );
  }
}
