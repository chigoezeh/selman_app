class Minister {
  final int id;
  final String name;
  final String? title;

  Minister({required this.id, required this.name, this.title});

  factory Minister.fromJson(Map<String, dynamic> json) {
    return Minister(
      id: json['id'],
      name: json['name'],
      title: json['title'],
    );
  }
}
