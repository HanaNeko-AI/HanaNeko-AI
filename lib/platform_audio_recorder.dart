import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class PlatformAudioRecorder {
  final Record _mobileRecorder = Record();
  dynamic _webRecorder;
  String _mobileAudioFilePath = "";
  bool _isRecording = false;

  PlatformAudioRecorder() {
    if (kIsWeb) {
      _initWebRecorder();
    }
  }

  void _initWebRecorder() {
    // This will be implemented only for web builds
  }

  Future<void> startRecording() async {
    if (_isRecording) return;

    if (kIsWeb) {
      await _webRecorder?.startRecording();
    } else {
      if (await _mobileRecorder.hasPermission()) {
        final directory = await getTemporaryDirectory();
        _mobileAudioFilePath = '${directory.path}/audio_recording.m4a';
        await _mobileRecorder.start(path: _mobileAudioFilePath);
      } else {
        throw Exception('Audio recording permission not granted');
      }
    }
    _isRecording = true;
  }

  Future<void> stopRecording() async {
    if (!_isRecording) return;

    if (kIsWeb) {
      await _webRecorder?.stopRecording();
    } else {
      await _mobileRecorder.stop();
    }
    _isRecording = false;
  }

  Future<Uint8List> getAudioData() async {
    if (kIsWeb) {
      return await _webRecorder?.getAudioData() ?? Uint8List(0);
    } else {
      File audioFile = File(_mobileAudioFilePath);
      return await audioFile.readAsBytes();
    }
  }

  bool get isRecording => _isRecording;

  void dispose() {
    if (!kIsWeb) {
      _mobileRecorder.dispose();
    }
  }
}