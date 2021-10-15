import 'package:client/routes/sign_in.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(VoterClientApp());
}

class VoterClientApp extends StatefulWidget {
  const VoterClientApp({Key? key}) : super(key: key);

  @override
  State<VoterClientApp> createState() => _VoterClientAppState();
}

class _VoterClientAppState extends State<VoterClientApp> {
  final Future<FirebaseApp> _init = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _init,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            throw FirebaseException(
                plugin: "firebase_core", message: "Error in initialization");
          }
          if (snapshot.connectionState == ConnectionState.done) {
            final _auth = FirebaseAuth.instance.signInAnonymously();
            _auth.then((value) {
              print(value);
            });
            return FutureBuilder(
                future: _auth,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    throw FirebaseException(
                        plugin: "firebase_core",
                        message: "Error in initialization");
                  }
                  if (snapshot.connectionState == ConnectionState.done) {
                    return const MaterialApp(
                      home: SignInPage(),
                    );
                  }
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                });
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        });
  }
}
