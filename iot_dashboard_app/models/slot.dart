class Slot {
  final int id;
  final String name;

  Slot({required this.id, required this.name});

  factory Slot.fromJson(Map<String, dynamic> json) {
    return Slot(
      id: json['id'],
      name: json['name'],
    );
  }
}
