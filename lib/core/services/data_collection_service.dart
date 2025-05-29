import 'package:flutter/services.dart';

class DataCollectionService {
  static const MethodChannel _channel = MethodChannel('com.kinemspa.medtrackr/data_collection');
  static Function(String)? _onDataCollectedCallback;

  DataCollectionService() {
    // Set up the method channel to receive data from Kotlin
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onDataCollected') {
        final data = call.arguments as String;
        _onDataCollectedCallback?.call(data);
      }
      return null;
    });
  }

  // Set a callback to handle data received from Kotlin
  void setOnDataCollectedCallback(Function(String) callback) {
    _onDataCollectedCallback = callback;
  }

  // Retrieve all collected data from the repository
  Future<List<String>> getCollectedData() async {
    final data = await _channel.invokeMethod('getCollectedData');
    return List<String>.from(data);
  }
}