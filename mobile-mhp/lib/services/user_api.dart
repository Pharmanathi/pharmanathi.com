// import 'dart:convert';
// import 'package:flutter/material.dart';
// import '../helpers/http_helpers.dart' as http_helpers;

// Future<void> fetchUserData(BuildContext context) async {
//   try {
//     final response =
//         await http_helpers.Apihelper.fetchData(context, (context) async {
//       return await http_helpers.Apihelper.httpRequestWithAuthorization(
//         context,
//         '${http_helpers.apiBaseURL}/users/me/',
//         'GET',
//         '',
//       );
//     });

//     print('User API code: ${response.statusCode}');
//     print('User API body: ${response.body}');

//     if (response.statusCode == 200) {
//       // Decode the response body
//       final Map<String, dynamic> userData = json.decode(response.body);

//       // Set the entire user data in the UserProvider
//       // rule https://dart.dev/tools/linter-rules/use_build_context_synchronously
//       if (!context.mounted) return;
//       http_helpers.setUserDataProxy(userData, context);
//     } else {
//       http_helpers.Apihelper.handleError(context, response);
//     }
//   } catch (e) {
//     http_helpers.Apihelper.handleException(context, e);
//   }
// }
