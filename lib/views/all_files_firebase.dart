// ignore_for_file: library_private_types_in_public_api

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class UserFilesList extends StatefulWidget {
  const UserFilesList({super.key});

  @override
  _UserFilesListState createState() => _UserFilesListState();
}

class _UserFilesListState extends State<UserFilesList> {
  // late Future<void> _future;
  late Future<void> _future = Future.value(null);

  List<Map<String, dynamic>> filesList = [];

  @override
  void initState() {
    super.initState();
    _future = getFilesList();
  }

  Future<void> getFilesList() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('users').get();

    List<QueryDocumentSnapshot> documents = querySnapshot.docs;

    for (int i = 0; i < documents.length; i++) {
      Map<String, dynamic> data = documents[i].data() as Map<String, dynamic>;
      List<dynamic>? files = data['files'];
      String? name = data['name'];
      if (files != null && name != null) {
        for (int j = 0; j < files.length; j++) {
          filesList.add({'name': name, 'file': files[j]});
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Files List'),
      ),
      body: FutureBuilder(
        future: _future,
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                crossAxisSpacing: 5.0,
                mainAxisSpacing: 5.0,
              ),
              itemCount: filesList.length,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    color: const Color.fromARGB(255, 162, 240, 233),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            filesList[index]['name'],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          child: PhotoView(
                            //user can zoom the image.
                            imageProvider: NetworkImage(
                              filesList[index]['file'],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
