import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
// ignore_for_file: avoid_print, use_build_context_synchronously

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<void> uploadFiles(
      BuildContext context, String uid, String userName) async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result == null || result.count == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No file selected'),
        ),
      );
      return;
    }

    List<File> selectedFiles =
        result.files.map((file) => File(file.path!)).toList();

    final storage = FirebaseStorage.instance;
    final storageRef = storage.ref().child('files/$uid/');

    List<String> fileUrls = [];

    for (var i = 0; i < selectedFiles.length; i++) {
      File file = selectedFiles[i];
      final fileName = file.path.split('/').last;
      final fileBytes = await file.readAsBytes();

      if (fileBytes.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File data could not be loaded'),
          ),
        );
        continue;
      }

      final fileRef = storageRef.child(fileName);
      try {
        final uploadTask = fileRef.putData(fileBytes);
        final snapshot = await uploadTask.whenComplete(() {});
        final downloadUrl = await snapshot.ref.getDownloadURL();
        fileUrls.add(downloadUrl);
        print("File URL uploaded successfully: $downloadUrl");
      } catch (e) {
        print("Error uploading file $fileName: $e");
        continue;
      }
    }

    final firestore = FirebaseFirestore.instance;
    final userRef = firestore.collection('users').doc(uid);

    try {
      final userData = await userRef.get();
      final existingFileUrls = List<String>.from(userData.get('files'));
      existingFileUrls.addAll(fileUrls);

      await userRef.set({
        // 'username': userName,
        'files': existingFileUrls,
      }, SetOptions(merge: true));
      print("User data uploaded successfully");
    } catch (e) {
      print("Error uploading user data: $e");
    }
  }

  Future<void> _signOut(BuildContext context, User? user) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: const Text("Do you want to Logout?"),
          title: const Text("Logout?"),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () async {
                    try {
                      await FirebaseAuth.instance.signOut();
                      user = null;
                      print(user);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Signed out successfully.'),
                        ),
                      );
                      Navigator.pop(context);
                      Navigator.pop(context);
                    } on FirebaseAuthException catch (e) {
                      print('Failed to sign out: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to sign out: $e'),
                        ),
                      );
                    }
                  },
                  child: const Text("Yes"),
                ),
                const SizedBox(
                  width: 20,
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("No"),
                ),
              ],
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: () {
              _signOut(context, user);
            },
            child: const Text(
              "Logout",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future:
            FirebaseFirestore.instance.collection('users').doc(user!.uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data?.data() ?? {};
          final name = data['name'];
          print('User ID: ${user.uid}');
          print('Data: $data');
          print('Name: $name');
          if (name == null) {
            return const Center(
              child: Text('Name not found in Firestore'),
            );
          }
          return Center(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: userDetailsColumnData(name, user, context),
                ),
                Expanded(child: gettingPostFromFirebase(user, name)),
              ],
            ),
          );
        },
      ),
    );
  }

  Column userDetailsColumnData(name, User user, BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(
          height: 30,
        ),
        Text(
          'Welcome, $name!',
          style: const TextStyle(fontSize: 23),
        ),
        const SizedBox(height: 16.0),
        Text(
          'Your user ID is: ${user.uid}',
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 16.0),
        ElevatedButton(
          onPressed: () async {
            try {
              await uploadFiles(context, user.uid, name);
              print('Files uploaded successfully');
            } catch (e) {
              print('Error uploading files: $e');
            }
          },
          child: const Text('Upload Files'),
        ),
      ],
    );
  }

  StreamBuilder<DocumentSnapshot<Object?>> gettingPostFromFirebase(
      User user, name) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        final data = snapshot.data?.data() as Map<String, dynamic>?;
        final files =
            (data?['files'] as List?)?.map((file) => file.toString()).toList();
        if (files == null || files.isEmpty) {
          return const Center(
            child: Text('No files uploaded yet.'),
          );
        }
        return ListView.builder(
          itemCount: files.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                    border: Border.all(
                        width: 2, color: Colors.black.withOpacity(0.3))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Name: $name',
                      style: const TextStyle(fontSize: 22),
                    ),
                    Text('User ID: ${user.uid}'),
                    Center(
                      child: Image.network(
                        files[index],
                        width: 250,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
