import 'dart:convert';

class PatientModel {
  const PatientModel({
    required this.id,
    required this.fullName,
    this.firstName = '',
    this.middleName = '',
    this.surname = '',
    this.diseaseName,
    this.aadhaarNumber,
    required this.gender,
    required this.dateOfBirth,
    required this.mobile,
    this.abhaNumber,
    required this.address,
    required this.city,
    this.taluka,
    this.district,
    required this.state,
    this.pincode,
    this.country,
    this.bloodGroup,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String fullName; // Kept for legacy support, or constructed.
  final String firstName;
  final String middleName;
  final String surname;
  final String? diseaseName;
  final String? aadhaarNumber;
  final String? abhaNumber;
  final String gender;
  final DateTime dateOfBirth;
  final String mobile;
  final String address;
  final String city;
  final String? taluka;
  final String? district;
  final String state;
  final String? pincode;
  final String? country;
  final String? bloodGroup;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  int get age {
    final today = DateTime.now();
    int age = today.year - dateOfBirth.year;
    if (today.month < dateOfBirth.month ||
        (today.month == dateOfBirth.month && today.day < dateOfBirth.day)) {
      age--;
    }
    return age < 0 ? 0 : age;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'firstName': firstName,
      'middleName': middleName,
      'surname': surname,
      'diseaseName': diseaseName,
      'aadhaarNumber': aadhaarNumber,
      'abhaNumber': abhaNumber,
      'gender': gender,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'mobile': mobile,
      'address': address,
      'city': city,
      'taluka': taluka,
      'district': district,
      'state': state,
      'pincode': pincode,
      'country': country,
      'bloodGroup': bloodGroup,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory PatientModel.fromMap(Map<String, dynamic> map) {
    return PatientModel(
      id: map['id']?.toString() ?? '',
      fullName: map['fullName']?.toString() ?? '',
      firstName: map['firstName']?.toString() ?? '',
      middleName: map['middleName']?.toString() ?? '',
      surname: map['surname']?.toString() ?? '',
      diseaseName: map['diseaseName']?.toString(),
      aadhaarNumber: map['aadhaarNumber']?.toString(),
      abhaNumber: map['abhaNumber']?.toString(),
      gender: map['gender']?.toString() ?? 'Unspecified',
      dateOfBirth:
          DateTime.tryParse(map['dateOfBirth']?.toString() ?? '') ??
          DateTime(1990, 1, 1),
      mobile: map['mobile']?.toString() ?? '',
      address: map['address']?.toString() ?? '',
      city: map['city']?.toString() ?? '',
      taluka: map['taluka']?.toString(),
      district: map['district']?.toString(),
      state: map['state']?.toString() ?? '',
      pincode: map['pincode']?.toString(),
      country: map['country']?.toString(),
      bloodGroup: map['bloodGroup']?.toString(),
      createdBy: map['createdBy']?.toString(),
      createdAt:
          DateTime.tryParse(map['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(map['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  String toJson() => jsonEncode(toMap());

  factory PatientModel.fromJson(String source) {
    return PatientModel.fromMap(
      Map<String, dynamic>.from(jsonDecode(source) as Map),
    );
  }

  PatientModel copyWith({
    String? id,
    String? fullName,
    String? firstName,
    String? middleName,
    String? surname,
    String? diseaseName,
    String? aadhaarNumber,
    String? abhaNumber,
    String? gender,
    DateTime? dateOfBirth,
    String? mobile,
    String? address,
    String? city,
    String? taluka,
    String? district,
    String? state,
    String? pincode,
    String? country,
    String? bloodGroup,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PatientModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      firstName: firstName ?? this.firstName,
      middleName: middleName ?? this.middleName,
      surname: surname ?? this.surname,
      diseaseName: diseaseName ?? this.diseaseName,
      aadhaarNumber: aadhaarNumber ?? this.aadhaarNumber,
      abhaNumber: abhaNumber ?? this.abhaNumber,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      mobile: mobile ?? this.mobile,
      address: address ?? this.address,
      city: city ?? this.city,
      taluka: taluka ?? this.taluka,
      district: district ?? this.district,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      country: country ?? this.country,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
