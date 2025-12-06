import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:math';

class VideoCallScreen extends StatelessWidget {
  final String roomName;
  final String displayName;
  
  const VideoCallScreen({
    Key? key,
    required this.roomName,
    required this.displayName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Generate a random User ID (For demo purposes).
    // In a real app, use your Firebase Auth UID here.
    final String localUserId = Random().nextInt(10000).toString();
    
    // Get credentials from .env file
    final String? appIdStr = dotenv.env['APP_ID'];
    final String? appSign = dotenv.env['APP_SIGN'];
    
    // Validate that the credentials exist
    if (appIdStr == null || appIdStr.isEmpty || appSign == null || appSign.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF001219),
        appBar: AppBar(
          backgroundColor: const Color(0xFF001219),
          title: const Text('Video Call Error'),
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              'Error: ZEGO credentials not found.\n\n'
              'Please add ZEGO_APP_ID and ZEGO_APP_SIGN to your .env file.',
              style: TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }
    
    // Parse App ID from string to int
    final int appId = int.tryParse(appIdStr) ?? 0;
    
    if (appId == 0) {
      return Scaffold(
        backgroundColor: const Color(0xFF001219),
        appBar: AppBar(
          backgroundColor: const Color(0xFF001219),
          title: const Text('Video Call Error'),
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              'Error: Invalid ZEGO_APP_ID.\n\n'
              'Please check your .env file and ensure ZEGO_APP_ID is a valid number.',
              style: TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    // --- THEME CONSTANT ---
    const backgroundColor = Color(0xFF001219); // Deep dark teal/blue

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: ZegoUIKitPrebuiltCall(
          appID: appId,
          appSign: appSign,
          userID: localUserId,
          userName: displayName,
          callID: roomName,
          
          // Use the pre-built configuration for 1-on-1 video calls.
          config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
            ..bottomMenuBarConfig = ZegoBottomMenuBarConfig(
              buttons: [
                ZegoMenuBarButtonName.toggleCameraButton,
                ZegoMenuBarButtonName.toggleMicrophoneButton,
                ZegoMenuBarButtonName.hangUpButton,
                ZegoMenuBarButtonName.switchAudioOutputButton,
                ZegoMenuBarButtonName.switchCameraButton,
              ],
            ),
        ),
      ),
    );
  }
}