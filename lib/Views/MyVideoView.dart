import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../Models/Video.dart';
import 'package:intl/intl.dart';

class MyVideoView extends StatefulWidget {
  MyVideoView({required this.video});
  final Video video;
  _MyVideoView createState() => _MyVideoView(video: video);
}

class _MyVideoView extends State<MyVideoView> {
  _MyVideoView({required this.video});
  final Video video;
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
      ),
    );
    _controller.cueVideoById(videoId: video.vId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Video'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          )),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          YoutubePlayer(controller: _controller),
          Container(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(video.vTitle,
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.left),
                  Text(video.chTitle +
                      ' ' +
                      DateFormat('yyyy-MM-dd HH:mm:ss').format(video.pubTime))
                ],
              )),
        ],
      ),
    );
  }
}
