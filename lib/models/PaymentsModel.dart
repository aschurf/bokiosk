class PaymentsModel {
  String guid;
  int sessionNumber;
  int checkNumber;
  int status;
  num paySum;
  String errorMsg;
  String univId;
  String created_at;

  PaymentsModel({
    required this.guid,
    required this.sessionNumber,
    required this.checkNumber,
    required this.status,
    required this.paySum,
    required this.errorMsg,
    required this.univId,
    required this.created_at,
  });


  factory PaymentsModel.fromJson(Map<String, dynamic> json) {
    return PaymentsModel(
      guid: json['guid'],
      sessionNumber: json['sessionNumber'],
      checkNumber: json['checkNumber'],
      status: json['status'],
      paySum: json['paySum'],
      errorMsg: json['errorMsg'],
      univId: json['univId'],
      created_at: json['created_at'],
    );
  }
}