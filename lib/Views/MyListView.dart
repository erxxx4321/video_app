import 'package:flutter/material.dart';
import 'MyVideoView.dart';
import '../Models/Video.dart';

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
