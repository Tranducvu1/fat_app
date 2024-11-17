import 'dart:math';
import 'package:fat_app/constants/app_constants.dart';
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
        appID: AppConstants
            .appId, // Fill in the appID that you get from ZEGOCLOUD Admin Console.
        appSign: AppConstants
            .appSign, // Fill in the appSign that you get from ZEGOCLOUD Admin Console.
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
