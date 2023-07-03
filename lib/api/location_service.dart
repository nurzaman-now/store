import 'package:http/http.dart' as http;
import 'package:store/models/address/kabupaten.dart';
import 'package:store/models/address/kecamatan.dart';
import 'package:store/models/address/kelurahan.dart';
import 'package:store/models/address/provinsi.dart';

class LocationService {
  Future<List<Provinsi>> fetchProvinces() async {
    final response = await http.get(Uri.parse(
        'https://emsifa.github.io/api-wilayah-indonesia/api/provinces.json'));

    if (response.statusCode == 200) {
      List<Provinsi> provinces = parseProvinsi(response.body);

      return provinces;
    } else {
      throw Exception('Failed to fetch provinces');
    }
  }

  Future<List<Kabupaten>> fetchCities(String provinceId) async {
    final response = await http.get(Uri.parse(
        'https://emsifa.github.io/api-wilayah-indonesia/api/regencies/$provinceId.json'));

    if (response.statusCode == 200) {
      List<Kabupaten> cities = kabupatenFromJson(response.body);

      return cities;
    } else {
      throw Exception('Failed to fetch cities');
    }
  }

  Future<List<Kecamatan>> fetchDistricts(String cityId) async {
    final response = await http.get(Uri.parse(
        'https://emsifa.github.io/api-wilayah-indonesia/api/districts/$cityId.json'));
    if (response.statusCode == 200) {
      List<Kecamatan> districts = kecamatanFromJson(response.body);

      return districts;
    } else {
      throw Exception('Failed to fetch districts');
    }
  }

  Future<List<Kelurahan>> fetchVillages(String districtId) async {
    final response = await http.get(Uri.parse(
        'https://emsifa.github.io/api-wilayah-indonesia/api/villages/$districtId.json'));

    if (response.statusCode == 200) {
      List<Kelurahan> villages = kelurahanFromJson(response.body);

      return villages;
    } else {
      throw Exception('Failed to fetch villages');
    }
  }
}
