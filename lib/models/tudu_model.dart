class TuduModel {
  final String id;
  final String text;
  final DateTime creationDate;
  bool done;

  TuduModel(this.id, this.text, this.creationDate, [ this.done = false ]);

   Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'creationDate': creationDate.millisecondsSinceEpoch,
      'done': done
    };
  }
}
