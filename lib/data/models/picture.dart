class Picture {
  final int id;
  final String hash;
  final String fileName;
  final String mimeType;
  final int size;
  final DateTime createdAt;
  final String? url;

  Picture({
    required this.id,
    required this.hash,
    required this.fileName,
    required this.mimeType,
    required this.size,
    required this.createdAt,
    this.url,
  });

  factory Picture.fromJson(Map<String, dynamic> json) {
    final id = (json['id'] as num).toInt();
    final hash = (json['hash'] as String?) ?? '';
    final url = (json['url'] as String?) ?? (json['file_url'] as String?);

    return Picture(
      id: id,
      hash: hash,
      fileName:
          (json['file_name'] as String?) ??
          (json['original_filename'] as String?) ??
          '',
      mimeType: (json['mime_type'] as String?) ?? '',
      size: (json['size'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      url: url,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hash': hash,
      'file_name': fileName,
      'mime_type': mimeType,
      'size': size,
      'created_at': createdAt.toUtc().toIso8601String(),
      'url': url,
    };
  }
}
