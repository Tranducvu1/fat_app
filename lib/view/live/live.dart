import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:zego_uikit_prebuilt_live_streaming/zego_uikit_prebuilt_live_streaming.dart';

class LivePage extends StatelessWidget {
  // final String liveID;
  final bool isHost;

  const LivePage({Key? key, this.isHost = false}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    var random = Random();
    // Sinh số nguyên ngẫu nhiên trong khoảng từ 0 đến 100
    final userID = random.nextInt(100).toString();
    return SafeArea(
      child: ZegoUIKitPrebuiltLiveStreaming(
        appID:
            601226444, // Fill in the appID that you get from ZEGOCLOUD Admin Console.
        appSign:
            'd5774dd4b7ace53128f4326bec32df2eb67e67acd0bec7fd41edfcc8af8c74cf', // Fill in the appSign that you get from ZEGOCLOUD Admin Console.
        userID: userID,
        userName: 'user_name',
        liveID: 'TestLiveID',
        config: isHost
            ? ZegoUIKitPrebuiltLiveStreamingConfig.host()
            : ZegoUIKitPrebuiltLiveStreamingConfig.audience(),
      ),
    );
  }
}
