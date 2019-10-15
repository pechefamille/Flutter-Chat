import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter × firebase Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter × firebase Demor'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  FirebaseUser _user;

  void _setUser(FirebaseUser user) {
    setState(() {
      _user = user;
    });
  }

  final GoogleSignIn _googleSignIn = new GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String username = 'Your Name';

  Future<FirebaseUser> _handleSignIn() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final FirebaseUser user = (await _auth.signInWithCredential(credential)).user;
    print("signed in " + user.displayName);
    return user;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: _user == null ? googleAuthBtn() : chat()
    );
  }

  Widget googleAuthBtn() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          FlatButton(
            padding: EdgeInsets.all(20.0),
            color: Colors.blue,
            onPressed: () {
              _handleSignIn()
                  .then((FirebaseUser user) => _setUser(user))
                  .catchError((e) => print(e));
            },
            child: Text('google認証'),
          ),
        ],
      ),
    );
  }

  Widget chat() {
    final textController = new TextEditingController();

    Future<void> addMessage(String text) {
      return Firestore.instance.collection("chat").add({
        "message": text
      });
    }

    return Stack(
        children: <Widget>[
          StreamBuilder<QuerySnapshot>(
            stream: Firestore.instance.collection('chat').snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError)
                return Text('Error: ${snapshot.error}');
              switch (snapshot.connectionState) {
                case ConnectionState.waiting: return new Text('Loading...');
                default:
                  return new ListView(
                    padding: EdgeInsets.only(bottom: 80.0),
                    children: snapshot.data.documents.map((DocumentSnapshot document) {
                      return Text(document["message"]);
                    }).toList(),
                  );
              }
            },
          ),
          Positioned(
            height: 80.0,
            left: 0.0,
            right: 0.0,
            bottom: .0,
            child: Container(
                decoration: BoxDecoration(
                    color: Colors.white
                ),
                padding: EdgeInsets.only(top: 10.0, bottom: 20.0, left: 20.0, right: 20.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextFormField(
                        controller: textController,
                      ),
                    ),
                    Expanded(
                      child: FlatButton(
                        padding: EdgeInsets.all(10.0),
                        color: Colors.blue,
                        onPressed: () {
                          addMessage(textController.text);
                          textController.text = '';
                        },
                        child: Text('送信'),
                      ),
                    ),
                  ],
                )
            ),
          ),
        ]
    );
  }
}