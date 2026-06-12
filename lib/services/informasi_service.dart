import 'package:aplikasi_kampus/core/network/api_client.dart';
import 'package:aplikasi_kampus/models/informasi_model.dart';

class InformasiService {
  final ApiClient _api;

  InformasiService(this._api);

  Future<List<InformasiModel>> getInformasi({
    String? search,
    int page = 1,
    int perPage = 10,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'per_page': perPage.toString(),
    };
    if (search != null) queryParams['search'] = search;

    final response = await _api.get('/informasis', queryParams: queryParams);
    final rawData = response['data'];
    final dataList = (rawData is List) ? rawData.cast<Map<String, dynamic>>() : <Map<String, dynamic>>[];
    return dataList.map((json) => InformasiModel.fromJson(json)).toList();
  }

  Future<InformasiModel> getInformasiDetail(int id) async {
    final response = await _api.get('/informasis/$id');
    final data = response['data'];
    if (data == null) throw ApiException('Detail informasi tidak ditemukan');
    return InformasiModel.fromJson(data);
  }

  Future<InformasiModel> createInformasi({
    required String judul,
    required String isi,
    required String tanggal,
    String? gambar,
  }) async {
    final body = <String, dynamic>{
      'judul': judul,
      'isi': isi,
      'tanggal': tanggal,
    };
    if (gambar != null) body['gambar'] = gambar;

    final response = await _api.post('/informasis', body: body);
    final data = response['data'];
    if (data == null) throw ApiException('Gagal membuat informasi');
    return InformasiModel.fromJson(data);
  }

  Future<InformasiModel> updateInformasi({
    required int id,
    String? judul,
    String? isi,
    String? tanggal,
    String? gambar,
  }) async {
    final body = <String, dynamic>{};
    if (judul != null) body['judul'] = judul;
    if (isi != null) body['isi'] = isi;
    if (tanggal != null) body['tanggal'] = tanggal;
    if (gambar != null) body['gambar'] = gambar;

    final response = await _api.put('/informasis/$id', body: body);
    final data = response['data'];
    if (data == null) throw ApiException('Gagal memperbarui informasi');
    return InformasiModel.fromJson(data);
  }

  Future<bool> deleteInformasi(int id) async {
    await _api.delete('/informasis/$id');
    return true;
  }
}
