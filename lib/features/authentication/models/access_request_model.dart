/// AUCTE — Access Request Model.
library;

enum RequestStatus { pending, approved, rejected }

class AccessRequestModel {
  const AccessRequestModel({
    required this.requestId,
    required this.uid,
    required this.email,
    required this.displayName,
    required this.hospital,
    required this.department,
    required this.designation,
    required this.medicalRegistrationNumber,
    required this.phone,
    required this.reason,
    this.status = RequestStatus.pending,
    this.createdAt,
  });

  final String requestId;
  final String uid;
  final String email;
  final String displayName;
  final String hospital;
  final String department;
  final String designation;
  final String medicalRegistrationNumber;
  final String phone;
  final String reason;
  final RequestStatus status;
  final DateTime? createdAt;

  factory AccessRequestModel.fromJson(Map<String, dynamic> json) {
    return AccessRequestModel(
      requestId: json['requestId'] as String? ?? '',
      uid: json['uid'] as String? ?? '',
      email: json['email'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      hospital: json['hospital'] as String? ?? '',
      department: json['department'] as String? ?? '',
      designation: json['designation'] as String? ?? '',
      medicalRegistrationNumber: json['medicalRegistrationNumber'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
      status: RequestStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => RequestStatus.pending,
      ),
      createdAt: json['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'requestId': requestId,
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'hospital': hospital,
      'department': department,
      'designation': designation,
      'medicalRegistrationNumber': medicalRegistrationNumber,
      'phone': phone,
      'reason': reason,
      'status': status.name,
      'createdAt': createdAt?.millisecondsSinceEpoch,
    };
  }
}
