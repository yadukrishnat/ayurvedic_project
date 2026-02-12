class PatientInvoice {
  final String name;
  final String executive;
  final String payment;
  final String phone;
  final String address;
  final double totalAmount;
  final double discountAmount;
  final double advanceAmount;
  final double balanceAmount;
  final String dateAndTime;
  final int id;
  final int male;
  final int female;
  final int branch;
  final int treatments;

  PatientInvoice({
    required this.name,
    required this.executive,
    required this.payment,
    required this.phone,
    required this.address,
    required this.totalAmount,
    required this.discountAmount,
    required this.advanceAmount,
    required this.balanceAmount,
    required this.dateAndTime,
    required this.id,
    required this.male,
    required this.female,
    required this.branch,
    required this.treatments,
  });

  factory PatientInvoice.fromJson(Map<String, dynamic> json) {
    return PatientInvoice(
      name: json['name'] ?? '',
      executive: json['excecutive'] ?? '',
      payment: json['payment'] ?? '',
      phone: json['phone']?.toString() ?? '',
      address: json['address'] ?? '',
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      discountAmount: (json['discount_amount'] ?? 0).toDouble(),
      advanceAmount: (json['advance_amount'] ?? 0).toDouble(),
      balanceAmount: (json['balance_amount'] ?? 0).toDouble(),
      dateAndTime: json['date_nd_time'] ?? '',
      id: json['id'] ?? 0,
      male: json['male'] ?? 0,
      female: json['female'] ?? 0,
      branch: json['branch'] ?? 0,
      treatments: json['treatments'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "excecutive": executive,
      "payment": payment,
      "phone": phone,
      "address": address,
      "total_amount": totalAmount,
      "discount_amount": discountAmount,
      "advance_amount": advanceAmount,
      "balance_amount": balanceAmount,
      "date_nd_time": dateAndTime,
      "id": id,
      "male": male,
      "female": female,
      "branch": branch,
      "treatments": treatments,
    };
  }
}