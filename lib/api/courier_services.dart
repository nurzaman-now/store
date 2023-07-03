import 'package:http/http.dart' as http;
import 'package:store/models/courier.dart';

import '../models/list_courier.dart';

class CourierServices {
  Future<List<ListCourier>> fetchListCourier() async {
    final response = await http.get(Uri.parse(
        'https://api.binderbyte.com/v1/list_courier?api_key=e0f7c142c31c023dcf937116f3c345707e00bba313bf15fc98c0d287cba1414c'));

    if (response.statusCode == 200) {
      List<ListCourier> listCourier = listCourierFromJson(response.body);

      return listCourier;
    } else {
      throw Exception('Failed to fetch list courier');
    }
  }

  Future<Courier?> fetchCourier(String courier, String awb) async {
    final response = await http.get(Uri.parse(
        'https://api.binderbyte.com/v1/track?api_key=e0f7c142c31c023dcf937116f3c345707e00bba313bf15fc98c0d287cba1414c&courier=$courier&awb=$awb'));

    if (response.statusCode == 200) {
      Courier couriers = courierFromJson(response.body);

      return couriers;
    }
    return null;
  }
}
