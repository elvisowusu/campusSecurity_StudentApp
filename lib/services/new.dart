import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;

class NotificationServices {
  static Future<String> getAccessToken() async {
    final serviceAccountJson = {
      "type": "service_account",
      "project_id": "campus-security-app-eee20",
      "private_key_id": "039991b75b7375d8c0c0ab085071a526c40c5050",
      "private_key":
          "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDk0ioG9kOFx/SH\nzCOvxTbYf+CRgFQWs6S6/ICT+wadF9/+di54LOmm+7twClN0M3wkKhhn3qfxTHuj\nDh1RYa5KgRm9f3WYXliU97zfV7B7CtQ/8VOjr3y/zw55YUTTvFGbILj42qTNRwOK\nY4eiX6n6Ywth3TT3qobuZKdTp39+5ii13MuNN7JHOXuIKHox2E/1Zkkv2qCwKJV7\ndK5EAnJxZeeQdie9ZNZM8/yPeFv33BeBtCa+MRdo5qhLaISfCw4XeTC8nOJDGzRY\nW7/kUTHbOijrc0eLKa7K5CMI17dY4ttUAwSoAlO7M5/nWZkln+ghm6zf23eJhFJ+\nYnGULCo3AgMBAAECggEABtMd3cdKjEWXzX+722o5EIv/2VcdKvArYZ2rrWjh8Z2H\nWMI9mz1RBWH3XTLG+m2ZWPAdz5CcgbM+R3FhqSO4sbrYAbGOLaqNXyQPG2Tfe/ap\nY0mCAnJ2zgxm6h00kvwdkvrkNB07/Ri5H6TdpBd7rQl3NXFbkGd4TslBvwT9Oyj5\nGIvDHzS/otiQ3jRWX2TNYQSUXNLcKyWLdmCwMplB3+jKvYTz5sFMBaZSc2CYLl5l\nPuciX75uHvucjouXNu7OC3e5zMC86ugA0dA+JjEpd/UjIZyHoWUi+QjwjrpNDghS\n82IZ6aVmurAKgm4oOhDfcJL6X/9Z5o+oDSYO3d0IAQKBgQDyDh/O766jRk5Dpv/V\n9o4ACLrzvXl3Pr1PekaXPoCCA1DKjlHAu6a0Ot/P9gU+09Li0ujD+TE9xPFtH+wk\nToFGGTcf00YNqO+rqBdksbKE89YZVq2KKW4k6Hw65ozewXbWL3/FkSmoCFyabREI\nZmfPTaB+Q/ff0qggcbqDc60GgQKBgQDyANvwWiWskXtSO/r9Jp40noe0QkjvB7ij\nyc3iNB3RMamL8RG0wMzJf8kSiElvsxDD4TYWx7Am0G9aq0q6FyvhMNeNtJ6On8/k\nTaO0z4XsUhg36KMAXDf/eMTyp648buctK4jW3w5n7rkA9odufcPy62nbcnOViwAA\nLQjYTyKEtwKBgQDKX4a2k+vVtK0woMobEIVOf/4WVN7eFMVgUqH8R5RXnwAIKg8t\n7XYGD4caLt3Z1m3lmGJlns1NkIAtNVhQTpaEjgZphFF4kDq5sNLGLE9OGzNwgeib\nr+HX18wtzp4Oi3+YuaPBAYnrY/pQXkm0VTILvyIlDxyJtG0+mvdOegM6gQKBgE2L\niO5TdI7/bwzCu4Iyxa8GvWU9eDFfwAJ7v8Uj/gnyZ+m3rXzF6tkGYV/W2/E258Bc\nggB6rC9Dyuq6yI8orZ7TD78QiV4aR3tYhYSCmt9GzwvbN5/97NOn1zQKFwK2Zs1K\njeaMQwl6rT1pwaveENPeK2VuHytkBvQHejYV5XGxAoGAPWoptBZnyApFpl2Sf+oy\n7deCNuQvyYwAFFloSiuQ+SCEYaNcngc2Qz4u+GiMohFir1mM1v4Gkps/4cB6MRKO\n4x3sBUrHTMUvXfZcJxl5QE9yfjg8NJ+Uj1yJZE0m8+EAXQayboF4rSejNJpatBBb\nCJFhaakZHnOarn+jbhtTmCs=\n-----END PRIVATE KEY-----\n",
      "client_email":
          "firebase-adminsdk-jtrl5@campus-security-app-eee20.iam.gserviceaccount.com",
      "client_id": "103919696083697678101",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url":
          "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url":
          "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-jtrl5%40campus-security-app-eee20.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    };
    List<String> scopes = [
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/firebase.database",
      "https://www.googleapis.com/auth/firebase.messaging"
    ];

    http.Client client = await auth.clientViaServiceAccount(
        auth.ServiceAccountCredentials.fromJson(serviceAccountJson), scopes);

    //get access token
    auth.AccessCredentials credentials =
        await auth.obtainAccessCredentialsViaServiceAccount(
            auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
            scopes,
            client);

    client.close();
    return credentials.accessToken.data;
  }

  static sendNotificationToSelectedPolice(
      String deviceToken, String trackingId) async {
    final String serverAcessToken = await getAccessToken();
    String endpointFirebaseCloudMessaging =
        'https://fcm.googleapis.com/v1/projects/campus-security-app-eee20/messages:send';

    final Map<String, dynamic> message = {
      'message': {
        'token': deviceToken,
        'notification': {
          'title': 'Emergency!!',
          'body': 'A Student is in Danger'
        },
        'data': {'tracking Id': ''}
      }
    };

    final http.Response response = await http.post(
      Uri.parse(endpointFirebaseCloudMessaging),
      headers: <String, String>
      {
        'Content-Type':'application/json',
        'Authorization':'Bearer $serverAcessToken'
      },
      body: jsonEncode(message),
    );

    if(response.statusCode == 200){
      Fluttertoast.showToast(msg: "swiftSOS sent");
    } else{
      Fluttertoast.showToast(msg: "Failed to send FCM message: ${response.statusCode}");
    }
  }
}
