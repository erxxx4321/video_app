import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'Views/MyVideoView.dart';
import 'Models/Video.dart';
import './Views/MyListView.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Evonne's Video",
      theme: ThemeData(
        fontFamily: 'JosefinSans',
        primaryColor: Colors.teal.shade200,
        highlightColor: Colors.black,
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: AppBarTheme(backgroundColor: Colors.teal[200]),
        useMaterial3: true,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Icon customIcon = const Icon(Icons.search);
  Widget customSearchBar = const Text("Evonne's Video");
  Future<List<Video>> myVideos = fetchMyChannel();

  @override
  void initState() {
    super.initState();
  }

  Future<List<Video>> queryVideo(String value) async {
    var data = await myVideos;
    return data
        .where(
            (item) => item.vTitle.toLowerCase().contains(value.toLowerCase()))
        .toList();
  }

  void handleTextChange(String value) async {
    setState(() {
      myVideos = value != "" ? queryVideo(value) : fetchMyChannel();
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: customSearchBar, centerTitle: true, actions: [
          IconButton(
              onPressed: () {
                setState(() {
                  if (customIcon.icon == Icons.search) {
                    customIcon = const Icon(Icons.cancel);
                    customSearchBar = ListTile(
                      leading: Icon(
                        Icons.search,
                        color: Colors.white,
                        size: 28,
                      ),
                      title: TextField(
                        onChanged: handleTextChange,
                        decoration: InputDecoration(
                          hintText: 'type in keyword...',
                          hintStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontStyle: FontStyle.italic,
                          ),
                          border: InputBorder.none,
                        ),
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    );
                  } else {
                    customIcon = const Icon(Icons.search);
                    customSearchBar = const Text('Flutter Video');
                  }
                });
              },
              icon: customIcon)
        ]),
        body: MyListView(items: myVideos));
  }
}

Future<List<Video>> fetchMyChannel() async {
  final response = await http.get(Uri.parse(
      'https://www.googleapis.com/youtube/v3/search?key=AIzaSyCGrcrjzIsjMrALEd_2Ifce9W91wAA4BMg&channelId=UCwARmXLVZHJKROyJ2w85Orw&type=video&part=snippet'));

  if (response.statusCode == 200) {
    // Successful response, parse the JSON
    Map<String, dynamic> jsonData = json.decode(response.body);
    var items = jsonData['items'];
    List<Video> videos = [];
    for (var i in items) {
      Video v = Video();
      v.vId = i['id']['videoId'];
      v.vTitle = i['snippet']['title'];
      v.vDesc = i['snippet']['description'];
      v.chId = i['snippet']['channelId'];
      v.chTitle = i['snippet']['channelTitle'];
      v.imgUrl = i['snippet']['thumbnails']['default']['url'];
      v.pubTime = DateTime.parse(i['snippet']['publishTime']);
      videos.add(v);
    }
    return videos;
  } else {
    throw Exception('Failed to fetch data');
  }
}
