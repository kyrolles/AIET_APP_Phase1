enum PeriodNumber { p1, p2, p3, p4 }

class AttendanceModel {
  final String profEmail;
  final String profName;
  final String subjectName;
  final String period;
  // final Timestamp startTime;
  // final Timestamp endTime;
  final List<Student> studentsList;

  AttendanceModel({
    required this.profEmail,
    required this.profName,
    required this.subjectName,
    required this.studentsList,
    // required this.endTime,
    required this.period,
    // required this.startTime,
  });

  factory AttendanceModel.fromJson(jsonData) {
    return AttendanceModel(
      profEmail: jsonData['email'],
      profName: jsonData['profName'],
      subjectName: jsonData['subjectName'],
      // startTime: jsonData['startTime'],
      // endTime: jsonData['endTime'],
      period: jsonData['period'],
      studentsList: getAllStudents(jsonData['studentList']),
    );
  }
}

class Student {
  final String name;
  final String id;
  final String year;

  Student({
    required this.name,
    required this.id,
    required this.year,
  });

  factory Student.fromJson(jsonData) {
    return Student(
      name: jsonData["name"],
      id: jsonData['id'],
      year: jsonData['academicYear'],
    );
  }
}

List<Student> getAllStudents(List<dynamic> jsonData) {
  List<Student> students = [];
  for (var i = 0; i < jsonData.length; i++) {
    students.add(Student(
        name: jsonData[i]["name"],
        id: jsonData[i]['id'],
        year: jsonData[i]['academicYear']));
  }
  return students;
}
