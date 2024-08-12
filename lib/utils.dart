import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void handleError(BuildContext context, String message, dynamic error) {
  if (kDebugMode) {
    print("Error: $message");
  }
  if (kDebugMode) {
    print("Error type: ${error.runtimeType}");
  }
  if (kDebugMode) {
    print("Error details: $error");
  }
  if (error is Error) {
    if (kDebugMode) {
      print("Stack trace: ${error.stackTrace}");
    }
  }
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 5),
      action: SnackBarAction(
        label: 'Details',
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Error Details'),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[
                      Text('Error: $message'),
                      Text('Type: ${error.runtimeType}'),
                      Text('Details: $error'),
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Close'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
    ),
  );
}
