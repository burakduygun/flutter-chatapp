import 'package:xml/xml.dart';

import 'package:http/http.dart' as http;

class ChatBot {
  static Future<String> askAi(String message) async {
    var url = Uri.parse(
        'https://www.botlibre.com/rest/api/form-chat?&application=988947380480561660&instance=46950262&message=${message}');

    var response = await http.get(url);

    if (response.statusCode == 200) {
      // Successful request
      var responseBody = response.body;
      if (responseBody.isEmpty) {
        return 'Something went wrong';
      }
      return parseXmlResponse(responseBody);
      // Handle the response data here
    } else {
      // Request failed
      return 'Request failed with status: ${response.statusCode}';
    }
  }

  static String parseXmlResponse(String xmlString) {
    final document = XmlDocument.parse(xmlString);
    final messageNode = document.findAllElements('message').first;
    if (messageNode == null) {
      return 'Something went wrong';
    }
    final message = messageNode.text;
    return message;
  }
}
