class Lecture {
  final String id;
  final String chaptername;
  final String lecturename;
  final String description;
  final String date;

  Lecture(
      {required this.id,
      required this.chaptername,
      required this.lecturename,
      required this.description,
      required this.date});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chaptername': chaptername,
      'lecturename': lecturename,
      'descrption': description,
      'date': date
    };
  }

  factory Lecture.fromMap(Map<String, dynamic> map) {
    return Lecture(
        id: map['id'],
        chaptername: map['chaptername'] ?? 'Unknown Chapter',
        lecturename: map['lecturename'] ?? 'Unknownlecture',
        description: map['description'] ?? 'No description',
        date: map['date']);
  }

  @override
  String toString() {
    return 'Lecture{id: $id, chaptername: $chaptername, lecturename: $lecturename,description:$description},date:$date';
  }
}
