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
      await userRef.set({
        'username': userName,
        'files': fileUrls,
      }, SetOptions(merge: true));
      print("User data uploaded successfully");
    } catch (e) {
      print("Error uploading user data: $e");
    }
  }

  Future<void> _signOut(BuildContext context, User? user) async {
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
    } on FirebaseAuthException catch (e) {
      print('Failed to sign out: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to sign out: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        automaticallyImplyLeading: false,
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Welcome, $name!'),
                const SizedBox(height: 16.0),
                Text('Your user ID is: ${user.uid}'),
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
                // const UserList(),
                ElevatedButton(
                  onPressed: () {
                    _signOut(context, user);
                  },
                  child: const Text("Logout"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
