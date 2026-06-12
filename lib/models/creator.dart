class Creator {
  final int id;
  final String nama;

  Creator({required this.id, required this.nama});

  factory Creator.fromJson(Map<String, dynamic> json) {
    return Creator(
      id: json['id'] ?? 0,
      nama: json['nama'] ?? '',
    );
  }
}
