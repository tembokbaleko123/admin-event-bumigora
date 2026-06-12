import 'creator.dart';

class InformasiModel {
  final int id;
  final String judul;
  final String isi;
  final String tanggal;
  final String? gambar;
  final String? gambarUrl;
  final int dibuatOleh;
  final Creator? creator;
  final String? createdAt;
  final String? updatedAt;

  InformasiModel({
    required this.id,
    required this.judul,
    required this.isi,
    required this.tanggal,
    this.gambar,
    this.gambarUrl,
    required this.dibuatOleh,
    this.creator,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'judul': judul,
    'isi': isi,
    'tanggal': tanggal,
    'gambar': gambar,
    'gambar_url': gambarUrl,
    'dibuat_oleh': dibuatOleh,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };

  factory InformasiModel.fromJson(Map<String, dynamic> json) {
    return InformasiModel(
      id: json['id'] ?? 0,
      judul: json['judul'] ?? '',
      isi: json['isi'] ?? '',
      tanggal: json['tanggal'] ?? '',
      gambar: json['gambar'],
      gambarUrl: json['gambar_url'],
      dibuatOleh: json['dibuat_oleh'] ?? 0,
      creator: json['creator'] is Map<String, dynamic>
          ? Creator.fromJson(json['creator'] as Map<String, dynamic>)
          : null,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}


