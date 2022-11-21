import 'package:agora_new_way/model/apimodel.dart';
import 'apiBaseEndPoint.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ResponseBody {
  final String channelName;

  final String _baseUri = APIEndPoint.baseUrl;

  final String _agoraToken = APIEndPoint.agoraToken;

  ResponseBody({required this.channelName});

  Future<AgoraModel> responseData() async {
    final String api = '$_baseUri/$_agoraToken?channel_id=$channelName&type=1';
    print(api);

    final response = await http.get(Uri.parse(api));

    print(response.statusCode);
    print(response.body);
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return AgoraModel.fromJson(jsonDecode(response.body));
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load agora token');
    }
  }
}
