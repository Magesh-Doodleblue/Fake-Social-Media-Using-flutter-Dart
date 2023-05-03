// // ignore_for_file: avoid_print, use_build_context_synchronously

// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
