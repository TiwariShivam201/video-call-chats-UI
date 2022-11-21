import 'package:agora_new_way/utils/app_id.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:agora_new_way/pages/chatpage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VideoCallPage extends StatefulWidget {
  String? channelName;
  int? uid;
  String? token;
  VideoCallPage({
    Key? key,
    required this.channelName,
    required this.uid,
    required this.token,
  }) : super(key: key);

  @override
  _VideoCallPageState createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage> {
  int? _remoteUid;
  bool _localUserJoined = false;
  bool muted = false;
  bool localVideoOff = false;
  bool remoteVideoOff = false;
  bool _isScreenShared = false;
  bool textMessageStatus = false;
  late RtcEngine _engine;

  @override
  void dispose() async {
    await _engine.leaveChannel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initAgora();
  }

  Future<void> initAgora() async {
    //create the engine
    _engine = createAgoraRtcEngine();
    await _engine.initialize(const RtcEngineContext(
      appId: appID,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    ));

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint("local user ${widget.uid} joined");
          setState(() {
            _localUserJoined = true;
          });
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint("remote user $remoteUid joined");
          setState(() {
            _remoteUid = remoteUid;
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          debugPrint("remote user $remoteUid left channel");
          setState(() {
            _remoteUid = null;
          });
        },
        onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
          debugPrint(
              '[onTokenPrivilegeWillExpire] connection: ${connection.toJson()}, token: $token');
        },
      ),
    );

    await _engine
        .setChannelProfile(ChannelProfileType.channelProfileCommunication);
    await _engine.enableVideo();
    await _engine.startPreview();

    await _engine.joinChannel(
      token: widget.token!,
      channelId: widget.channelName!,
      options: const ChannelMediaOptions(),
      uid: widget.uid!,
    );
  }

  // Create UI with local view and remote view
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Call'),
      ),
      body: Stack(
        children: [
          Center(child: _remoteVideo()),
          Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 100,
              height: 150,
              child: localVideoOff
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Image.asset(
                            'images/videoOff.png',
                            height: 20,
                            width: 20,
                          ),
                          const Text(
                            'Video off',
                            style: TextStyle(color: Colors.black54),
                          )
                        ],
                      ),
                    )
                  : Center(
                      child: _localVideo(),
                    ),
            ),
          ),
          _toolbar(),
        ],
      ),
    );
  }

  // Display local user's video

  Widget _localVideo() {
    if (_localUserJoined) {
      if (!_isScreenShared) {
        return AgoraVideoView(
          controller: VideoViewController(
            rtcEngine: _engine,
            canvas: const VideoCanvas(uid: 0),
          ),
        );
      } else {
        return AgoraVideoView(
            controller: VideoViewController(
          rtcEngine: _engine,
          canvas: const VideoCanvas(
            uid: 0,
            sourceType: VideoSourceType.videoSourceScreen,
          ),
        ));
      }
    } else {
      return const CircularProgressIndicator();
    }
  }

  // Display remote user's video
  Widget _remoteVideo() {
    return _remoteUid != null
        ? AgoraVideoView(
            controller: VideoViewController.remote(
              rtcEngine: _engine,
              canvas: VideoCanvas(uid: _remoteUid),
              connection: RtcConnection(channelId: widget.channelName),
            ),
          )
        : const Text(
            'Please wait for remote user to join',
            textAlign: TextAlign.center,
          );
  }

  Widget _toolbar() {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RawMaterialButton(
            onPressed: _onToggleMute,
            shape: const CircleBorder(),
            elevation: 2.0,
            fillColor: muted ? Colors.blueAccent : Colors.white,
            padding: const EdgeInsets.all(12.0),
            child: Icon(
              muted ? Icons.mic_off : Icons.mic,
              color: muted ? Colors.white : Colors.blueAccent,
              size: 20.0,
            ),
          ),
          // RawMaterialButton(
          //   onPressed: _onvideoOff,
          //   shape: const CircleBorder(),
          //   elevation: 2.0,
          //   fillColor: localVideoOff ? Colors.blueAccent : Colors.white,
          //   padding: const EdgeInsets.all(12.0),
          //   child: Icon(
          //     localVideoOff ? Icons.videocam_off : Icons.video_call,
          //     color: localVideoOff ? Colors.white : Colors.blueAccent,
          //     size: 20.0,
          //   ),
          // ),
          RawMaterialButton(
            onPressed: () => _onCallEnd(context),
            shape: const CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.redAccent,
            padding: const EdgeInsets.all(20.0),
            child: const Icon(
              Icons.call_end,
              color: Colors.white,
              size: 30.0,
            ),
          ),
          RawMaterialButton(
            onPressed: shareScreen,
            shape: const CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.white,
            padding: const EdgeInsets.all(12.0),
            child: Icon(
              // Icons.switch_camera,
              _isScreenShared ? Icons.stop_screen_share : Icons.screen_share,
              color: Colors.blueAccent,
              size: 20.0,
            ),
          ),
          RawMaterialButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ChatScreen(
                        channelName: widget.channelName,
                      )),
            ),
            shape: const CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.white,
            padding: const EdgeInsets.all(12.0),
            child: const Icon(
              Icons.chat_outlined,
              color: Colors.blueAccent,
              size: 20.0,
            ),
          ),
        ],
      ),
    );
  }

  void _onToggleMute() {
    setState(() {
      muted = !muted;
    });
    _engine.muteLocalAudioStream(muted);
    // _engine.Audio
  }

  void _onCallEnd(BuildContext context) async {
    setState(() {
      _localUserJoined = false;
      _remoteUid = null;
    });
    _engine.leaveChannel();
    Navigator.pop(context);
  }

  // void _onSwitchCamera() {
  //   _engine.switchCamera();
  // }

  Future<void> shareScreen() async {
    setState(() {
      _isScreenShared = !_isScreenShared;
    });

    if (_isScreenShared) {
      _engine.startScreenCapture(const ScreenCaptureParameters2(
          captureAudio: false,
          captureVideo: true,
          videoParams: ScreenVideoParameters(
            dimensions: VideoDimensions(width: 360, height: 640),
            frameRate: 30,
            bitrate: 140,
            contentHint: VideoContentHint.contentHintMotion,
          )));
    } else {
      await _engine.stopScreenCapture();
    }

    // Set and update channel media options
    ChannelMediaOptions options = ChannelMediaOptions(
      publishScreenTrack: _isScreenShared,
      publishScreenCaptureVideo: _isScreenShared,
      publishCameraTrack: !_isScreenShared,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    );

    _engine.updateChannelMediaOptions(options);
  }

  void _onvideoOff() {
    // remoteVideoOff = !remoteVideoOff;
    setState(() {
      // if (remoteVideoOff) {
      //   _engine
      //       .setupRemoteVideo(VideoCanvas(uid: _remoteUid, isScreenView: true));
      // } else {
      //   // _engine.setupRemoteVideo(
      //   //     VideoCanvas(uid: _remoteUid, isScreenView: false));

      //   AgoraVideoView(
      //       controller: VideoViewController(
      //           rtcEngine: _engine, canvas: VideoCanvas(view: _remoteUid)));
      // }
      // if (localVideoOff) {
      //   // _engine.setupLocalVideo(VideoCanvas(uid: 0, isScreenView: false));
      //   _engine.setupRemoteVideo(
      //       VideoCanvas(isScreenView: false, uid: widget.uid));
      // } else {
      //   // _engine.setupLocalVideo(VideoCanvas(uid: 0, isScreenView: true));
      //   _engine
      //       .setupRemoteVideo(VideoCanvas(isScreenView: true, uid: 0));
      // }
      localVideoOff = !localVideoOff;
      if (localVideoOff) {
        _engine.disableVideo();
      } else {
        _engine.enableVideo();
      }
    });
  }
}
