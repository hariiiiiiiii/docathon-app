import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
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

    // ------------------------------------------------------------------
    // REPLACE THESE TWO VALUES with your keys from the ZEGOCLOUD Console
    // ------------------------------------------------------------------
    const int yourAppID = 387067517; 
    const String yourAppSign = 'ae714ae1ea0d0a0687e8e093f51916aa8896d350528026834ea0f5e897d103fb'; 

    // --- THEME CONSTANT ---
    const backgroundColor = Color(0xFF001219); // Deep dark teal/blue

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: ZegoUIKitPrebuiltCall(
          appID: yourAppID,
          appSign: yourAppSign,
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
              // Optional: You can customize button styles here if needed by the package
              // style: ZegoMenuBarStyle.dark, 
            ),
        ),
      ),
    );
  }
}