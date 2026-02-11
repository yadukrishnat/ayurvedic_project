class PatientModel {
  final int id;
  final String name;
  final String phone;
  final String address;
  final String payment;
  final double? totalAmount;
  final double? discountAmount;
  final double? advanceAmount;
  final double? balanceAmount;
  final String dateTime;
  final bool? isActive;
  final String user;
  final Branch? branch;
  final List<PatientDetail> patientDetails;

  PatientModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    required this.payment,
    this.totalAmount,
    this.discountAmount,
    this.advanceAmount,
    this.balanceAmount,
    required this.dateTime,
    this.isActive,
    required this.user,
    this.branch,
    required this.patientDetails,
  });

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    var patientDetailsList = <PatientDetail>[];
    if (json['patientdetails_set'] != null) {
      patientDetailsList = List<PatientDetail>.from(
        json['patientdetails_set'].map((x) => PatientDetail.fromJson(x)),
      );
    }

    return PatientModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? "",
      phone: json['phone'] ?? "",
      address: json['address'] ?? "",
      payment: json['payment'] ?? "",
      totalAmount: json['total_amount'] != null
          ? (json['total_amount'] as num).toDouble()
          : null,
      discountAmount: json['discount_amount'] != null
          ? (json['discount_amount'] as num).toDouble()
          : null,
      advanceAmount: json['advance_amount'] != null
          ? (json['advance_amount'] as num).toDouble()
          : null,
      balanceAmount: json['balance_amount'] != null
          ? (json['balance_amount'] as num).toDouble()
          : null,
      dateTime: json['date_nd_time'] ?? "",
      isActive: json['is_active'],
      user: json['user'] ?? "",
      branch: json['branch'] != null ? Branch.fromJson(json['branch']) : null,
      patientDetails: patientDetailsList,
    );
  }
}

class PatientDetail {
  final int? id;
  final String male;
  final String female;
  final int? patient;
  final int? treatment;
  final String treatmentName;

  PatientDetail({
    this.id,
    required this.male,
    required this.female,
    this.patient,
    this.treatment,
    required this.treatmentName,
  });

  factory PatientDetail.fromJson(Map<String, dynamic> json) {
    return PatientDetail(
      id: json['id'],
      male: json['male'] ?? "",
      female: json['female'] ?? "",
      patient: json['patient'],
      treatment: json['treatment'],
      treatmentName: json['treatment_name'] ?? "",
    );
  }
}

class Branch {
  final int? id;
  final String name;
  final int? patientsCount;
  final String location;
  final String phone;
  final String mail;
  final String address;
  final String gst;
  final bool? isActive;

  Branch({
    this.id,
    required this.name,
    this.patientsCount,
    required this.location,
    required this.phone,
    required this.mail,
    required this.address,
    required this.gst,
    this.isActive,
  });

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      id: json['id'],
      name: json['name'] ?? "",
      patientsCount: json['patients_count'],
      location: json['location'] ?? "",
      phone: json['phone'] ?? "",
      mail: json['mail'] ?? "",
      address: json['address'] ?? "",
      gst: json['gst'] ?? "",
      isActive: json['is_active'],
    );
  }
}
