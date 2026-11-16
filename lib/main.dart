import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Album {
  final int id;
  final String title;

  Album({required this.id, required this.title});

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      id: json['id'],
      title: json['title'],
    );
  }
}

void main() {
  runApp(const AlbumApp());
}

class AlbumApp extends StatelessWidget {
  const AlbumApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Album Explorer',
      home: AlbumPage(),
    );
  }
}

class AlbumPage extends StatefulWidget {
  const AlbumPage({super.key});

  @override
  State<AlbumPage> createState() => _AlbumPageState();
}

class _AlbumPageState extends State<AlbumPage> {
  late Future<List<Album>> albumsFuture;
  Album? selectedAlbum;
  bool isDeleting = false;

  @override
  void initState() {
    super.initState();
    albumsFuture = fetchAlbums();
  }

  Future<List<Album>> fetchAlbums() async {
    final response = await http.get(
      Uri.parse('https://jsonplaceholder.typicode.com/albums'),
    );

    if (response.statusCode != 200) {
      throw Exception('Could not load albums.');
    }

    final List<dynamic> albumList = jsonDecode(response.body);

    return albumList.map((item) {
      return Album.fromJson(item);
    }).toList();
  }

  Future<void> deleteAlbum() async {
    if (selectedAlbum == null) return;

    final album = selectedAlbum!;

    setState(() {
      isDeleting = true;
    });

    try {
      final response = await http.delete(
        Uri.parse('https://jsonplaceholder.typicode.com/albums/${album.id}'),
      );

      if (response.statusCode == 200) {
        setState(() {
          selectedAlbum = null;
          isDeleting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Album deleted successfully.')),
        );
      } else {
        throw Exception('Could not delete album.');
      }
    } catch (error) {
      setState(() {
        isDeleting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }

  Widget buildSelectedAlbum() {
    if (selectedAlbum == null) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('No Album Selected'),
      );
    }

    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Album ID: ${selectedAlbum!.id}'),
            const SizedBox(height: 8),
            Text('Title: ${selectedAlbum!.title}'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: isDeleting ? null : deleteAlbum,
              child: Text(isDeleting ? 'Deleting...' : 'Delete Album'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Album Explorer')),
      body: Column(
        children: [
          buildSelectedAlbum(),
          Expanded(
            child: FutureBuilder<List<Album>>(
              future: albumsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Could not load albums. Check your connection.'),
                  );
                }

                final albums = snapshot.data!;

                return ListView.builder(
                  itemCount: albums.length,
                  itemBuilder: (context, index) {
                    final album = albums[index];

                    return ListTile(
                      title: Text(album.title),
                      subtitle: Text('Album ${album.id}'),
                      onTap: () {
                        setState(() {
                          selectedAlbum = album;
                        });
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
