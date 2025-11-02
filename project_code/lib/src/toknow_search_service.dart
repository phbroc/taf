import 'package:http/http.dart';
import 'dart:async';
import 'dart:convert';
import '../in_memory_data_service.dart';
import 'toknow/toknow.dart';

class ToknowSearchService {
  final InMemoryDataService _inMemoryDataService;

  ToknowSearchService(this._inMemoryDataService);

  dynamic _extractData(Response resp) => json.decode(resp.body)['data'];

  Future<List<Toknow>> search(String term) async {
    try {
      final response = await _inMemoryDataService.get(Uri.parse('app/toknows/?title=$term'));
      return (_extractData(response) as List)
          .map((json) => Toknow.fromJson(json))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(dynamic e) {
    print(e); // for demo purposes only
    return Exception('Search error; cause: $e');
  }
}