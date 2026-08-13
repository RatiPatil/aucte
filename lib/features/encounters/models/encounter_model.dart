import 'dart:convert';
import '../../terminology/models/clinical_term_model.dart';

class EncounterModel {
  const EncounterModel({
    required this.id,
    required this.patientId,
    required this.practitionerId,
    required this.encounterDate,
    required this.chiefComplaint,
    required this.clinicalNotes,
    required this.diagnoses,
    this.consentId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String patientId;
  final String practitionerId;
  final DateTime encounterDate;
  final String chiefComplaint;
  final String clinicalNotes;
  final List<ClinicalTermModel> diagnoses;
  final String? consentId;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientId': patientId,
      'practitionerId': practitionerId,
      'encounterDate': encounterDate.toIso8601String(),
      'chiefComplaint': chiefComplaint,
      'clinicalNotes': clinicalNotes,
      'diagnoses': diagnoses.map((d) => d.toMap()).toList(),
      'consentId': consentId,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory EncounterModel.fromMap(Map<String, dynamic> map) {
    final rawDiagnoses = map['diagnoses'] as List<dynamic>? ?? [];
    return EncounterModel(
      id: map['id']?.toString() ?? '',
      patientId: map['patientId']?.toString() ?? '',
      practitionerId: map['practitionerId']?.toString() ?? '',
      encounterDate:
          DateTime.tryParse(map['encounterDate']?.toString() ?? '') ??
          DateTime.now(),
      chiefComplaint: map['chiefComplaint']?.toString() ?? '',
      clinicalNotes: map['clinicalNotes']?.toString() ?? '',
      diagnoses: rawDiagnoses
          .map(
            (d) =>
                ClinicalTermModel.fromMap(Map<String, dynamic>.from(d as Map)),
          )
          .toList(),
      consentId: map['consentId']?.toString(),
      status: map['status']?.toString() ?? 'completed',
      createdAt:
          DateTime.tryParse(map['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(map['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  String toJson() => jsonEncode(toMap());

  factory EncounterModel.fromJson(String source) {
    return EncounterModel.fromMap(
      Map<String, dynamic>.from(jsonDecode(source) as Map),
    );
  }

  EncounterModel copyWith({
    String? id,
    String? patientId,
    String? practitionerId,
    DateTime? encounterDate,
    String? chiefComplaint,
    String? clinicalNotes,
    List<ClinicalTermModel>? diagnoses,
    String? consentId,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EncounterModel(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      practitionerId: practitionerId ?? this.practitionerId,
      encounterDate: encounterDate ?? this.encounterDate,
      chiefComplaint: chiefComplaint ?? this.chiefComplaint,
      clinicalNotes: clinicalNotes ?? this.clinicalNotes,
      diagnoses: diagnoses ?? this.diagnoses,
      consentId: consentId ?? this.consentId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
