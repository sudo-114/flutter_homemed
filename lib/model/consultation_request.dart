import 'package:homemed/main.dart';

class ConsultationRequest {
  final String id;
  final String symptoms;
  final String? status;
  final List<String>? fileUrls;
  final String? doctorName;
  final DateTime createdAt;

  const ConsultationRequest({
    required this.id,
    required this.symptoms,
    this.status,
    this.fileUrls,
    this.doctorName,
    required this.createdAt,
  });

  factory ConsultationRequest.fromMap(Map<String, dynamic> map) {
    String status = '';

    switch (map['status']) {
      case 'pending':
        status = 'Pending';
        break;
      case 'accepted':
        status = 'Accepted';
        break;
      case 'completed':
        status = 'Completed';
        break;
      case 'cancelled':
        status = 'Cancelled';
        break;
      default:
        status = map['status'] ?? 'Pending';
    }

    return ConsultationRequest(
      id: map['id'],
      symptoms: map['symptoms'],
      status: status,
      fileUrls: (map['file_urls'] != null)
          ? List<String>.from(map['file_urls'])
          : null,
      doctorName: map['doctor_name'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  static List<Map<String, dynamic>> getCachedRawRequests() {
    final raw = storage.read('consultation_requests');
    if (raw is List) {
      return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    return [];
  }
}
