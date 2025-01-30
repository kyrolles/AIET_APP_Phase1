class Request {
  final String addressedTo;
  final String comment;
  final String fileName;
  final String pdfBase64;
  final String stamp;
  final String status;
  final String studentId;
  final String studentName;
  final int trainingScore;
  final String type;
  final String year;

  Request({
    required this.addressedTo,
    required this.comment,
    required this.fileName,
    required this.pdfBase64,
    required this.stamp,
    required this.status,
    required this.studentId,
    required this.studentName,
    required this.trainingScore,
    required this.type,
    required this.year,
  });

  factory Request.fromJson(json) {
    return Request(
      addressedTo: json['addressedTo'],
      comment: json['comment'],
      fileName: json['fileName'],
      pdfBase64: json['pdfBase64'],
      stamp: json['stamp'],
      status: json['status'],
      studentId: json['studentId'],
      studentName: json['studentName'],
      trainingScore: json['trainingScore'],
      type: json['type'],
      year: json['year'],
    );
  }
}
