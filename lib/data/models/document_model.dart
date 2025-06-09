class DocumentModel {
  int id;
  List<String> files;
  DateTime createdAt;
  String name;

  DocumentModel({
    required this.id,
    required this.files,
    required this.createdAt,
    required this.name,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'files': files,
        'createdAt': createdAt.toIso8601String(),
        'name': name,
      };

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json['id'],
      files: List<String>.from(json['files']),
      createdAt: DateTime.parse(json['createdAt']),
      name: json['name'],
    );
  }
}
