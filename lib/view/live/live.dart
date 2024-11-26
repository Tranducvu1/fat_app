import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_live_streaming/zego_uikit_prebuilt_live_streaming.dart';
import '../../Model/UserModel.dart';
import '../../constants/app_constants.dart';
import '../../service/user_service.dart';

class LivePage extends StatefulWidget {
  final bool isHost;

  const LivePage({Key? key, this.isHost = false}) : super(key: key);

  @override
  _LivePageState createState() => _LivePageState();
}

class _LivePageState extends State<LivePage> {
  late String userID;
  String userName = "Unknown User"; // Giá trị mặc định cho username
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    userID = Random().nextInt(100).toString(); // Tạo userID ngẫu nhiên
    _loadUserData(); // Tải dữ liệu người dùng
  }

  Future<void> _loadUserData() async {
    try {
      UserModel? currentUser = await UserService().getCurrentUser();
      if (currentUser != null) {
        setState(() {
          userName = currentUser.userName;
          isLoading = false; // Dừng loading
        });
      } else {
        setState(() {
          isLoading = false;
        });
        debugPrint("Không tìm thấy thông tin người dùng");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint("Lỗi khi tải thông tin người dùng: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      // Hiển thị vòng tròn loading khi đang tải dữ liệu
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return SafeArea(
      child: ZegoUIKitPrebuiltLiveStreaming(
        appID: AppConstants
            .appId, // Điền appID mà bạn nhận được từ ZEGOCLOUD Admin Console.
        appSign: AppConstants
            .appSign, // Điền appSign mà bạn nhận được từ ZEGOCLOUD Admin Console.
        userID: userID,
        userName: userName,
        liveID: 'TestLiveID',
        config: widget.isHost
            ? ZegoUIKitPrebuiltLiveStreamingConfig.host()
            : ZegoUIKitPrebuiltLiveStreamingConfig.audience(),
      ),
    );
  }
}
