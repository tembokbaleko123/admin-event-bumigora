import 'creator.dart';

class EventModel {
  final int id;
  final String judul;
  final String tanggal;
  final String? tanggalSelesai;
  final String? batasDaftar;
  final String lokasi;
  final String? deskripsi;
  final String? gambar;
  final String? gambarUrl;
  final String? kategori;
  final int? kapasitas;
  final String? status;
  final int? totalPendaftar;
  final int? pendaftarAktif;
  final int? sisaKuota;
  final int createdBy;
  final Creator? creator;
  final String? createdAt;
  final String? updatedAt;

  EventModel({
    required this.id,
    required this.judul,
    required this.tanggal,
    this.tanggalSelesai,
    this.batasDaftar,
    required this.lokasi,
    this.deskripsi,
    this.gambar,
    this.gambarUrl,
    this.kategori,
    this.kapasitas,
    this.status,
    this.totalPendaftar,
    this.pendaftarAktif,
    this.sisaKuota,
    required this.createdBy,
    this.creator,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'judul': judul,
    'tanggal': tanggal,
    'tanggal_selesai': tanggalSelesai,
    'batas_daftar': batasDaftar,
    'lokasi': lokasi,
    'deskripsi': deskripsi,
    'gambar': gambar,
    'gambar_url': gambarUrl,
    'kategori': kategori,
    'kapasitas': kapasitas,
    'status': status,
    'created_by': createdBy,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] ?? 0,
      judul: json['judul'] ?? '',
      tanggal: json['tanggal'] ?? '',
      tanggalSelesai: json['tanggal_selesai'],
      batasDaftar: json['batas_daftar'],
      lokasi: json['lokasi'] ?? '',
      deskripsi: json['deskripsi'],
      gambar: json['gambar'],
      gambarUrl: json['gambar_url'],
      kategori: json['kategori'],
      kapasitas: json['kapasitas'],
      status: json['status'],
      totalPendaftar: json['total_pendaftar'],
      pendaftarAktif: json['pendaftar_aktif'],
      sisaKuota: json['sisa_kuota'],
      createdBy: json['created_by'] ?? 0,
      creator: json['creator'] is Map<String, dynamic>
          ? Creator.fromJson(json['creator'] as Map<String, dynamic>)
          : null,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}


