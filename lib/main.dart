import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'Views/MyVideoView.dart';
import 'Models/Video.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Video',
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 43, 255, 244)),
        useMaterial3: true,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Icon customIcon = const Icon(Icons.search);
  Widget customSearchBar = const Text('Flutter Video');
  final Future<List<Video>> myVideos = fetchMyChannel();

  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: customSearchBar,
            centerTitle: true,
            actions: [
              IconButton(
                  onPressed: () {
                    setState(() {
                      if (customIcon.icon == Icons.search) {
                        customIcon = const Icon(Icons.cancel);
                        customSearchBar = const ListTile(
                          leading: Icon(
                            Icons.search,
                            color: Colors.white,
                            size: 28,
                          ),
                          title: TextField(
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

class MyListView extends StatelessWidget {
  MyListView({required this.items});
  final Future<List<Video>> items;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Video>>(
        future: items,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Image.network(snapshot.data![index].imgUrl),
                  title: Text(snapshot.data![index].vTitle),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                MyVideoView(video: snapshot.data![index])));
                  },
                );
              },
            );
          }
        });
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
