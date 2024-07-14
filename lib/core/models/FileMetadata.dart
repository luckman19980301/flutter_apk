class FileMetadata {
  final String url;
  final String type;
  final int size;
  final String name;

  FileMetadata({
    required this.url,
    required this.type,
    required this.size,
    required this.name,
  });

  Map<String, dynamic> toMap() {
    return {
      'url': url,
      'type': type,
      'size': size,
      'name': name,
    };
  }

  factory FileMetadata.fromMap(Map<String, dynamic> map) {
    return FileMetadata(
      url: map['url'] ?? '',
      type: map['type'] ?? 'application/octet-stream',
      size: map['size'] ?? 0,
      name: map['name'] ?? '',
    );
  }
}
