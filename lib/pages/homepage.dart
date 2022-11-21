import 'package:agora_new_way/pages/callpage.dart';
import 'package:agora_new_way/model/apimodel.dart';
import 'package:agora_new_way/pages/loginpage.dart';
import 'package:agora_new_way/utils/auth_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agora_new_way/api/request.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class MyHomePage extends StatefulWidget {
  late AgoraModel responseBody;
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _channelController = TextEditingController();
  late String uID;
  int? uid;
  String? token;
  bool _isSigningOut = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                height: 60,
              ),
              Align(
                alignment: Alignment.topRight,
                child: _isSigningOut
                    ? CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : RawMaterialButton(
                        onPressed: () => AuthService().signOut(),
                        shape: const CircleBorder(),
                        elevation: 2.0,
                        fillColor: Colors.redAccent,
                        padding: const EdgeInsets.all(15.0),
                        child: const Icon(
                          Icons.logout,
                          color: Colors.white,
                          size: 35.0,
                        ),
                      ),
              ),
              FirebaseAuth.instance.currentUser!.photoURL != null
                  ? ClipOval(
                      child: Material(
                        color: Color(0xFFECEFF1).withOpacity(0.3),
                        child: Image.network(
                          FirebaseAuth.instance.currentUser!.photoURL!,
                          fit: BoxFit.fitHeight,
                        ),
                      ),
                    )
                  : ClipOval(
                      child: Material(
                        color: Color(0xFFECEFF1).withOpacity(0.3),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Icon(
                            Icons.person,
                            size: 60,
                            color: Color(0xFFECEFF1),
                          ),
                        ),
                      ),
                    ),
              Text(
                FirebaseAuth.instance.currentUser!.displayName!,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 40,
              ),
              Column(
                children: [
                  Image.asset(
                    'images/cloveImage.jpeg',
                    height: 100,
                    width: 200,
                  ),
                  const Text(
                    'CloveApp for Agora',
                    style: TextStyle(
                      fontSize: 30,
                      fontFamily: 'Open Sans',
                      color: Color(0xffF2704E),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 100,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.7,
                child: TextFormField(
                  controller: _channelController,
                  decoration: const InputDecoration(hintText: 'Channel Name'),
                ),
              ),
              SizedBox(
                height: 35,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                child: MaterialButton(
                  color: Colors.blue,
                  onPressed: () async {
                    widget.responseBody =
                        await ResponseBody(channelName: _channelController.text)
                            .responseData();

                    uID = widget.responseBody.uID!;
                    uid = int.parse(uID);
                    print(uid);
                    token = widget.responseBody.token!;
                    print(token);
                    token = token.toString();
                    await [Permission.camera, Permission.microphone].request();

                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => VideoCallPage(
                        channelName: _channelController.text,
                        uid: uid,
                        token: token,
                      ),
                    ));
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Submit',
                        style: TextStyle(color: Colors.white),
                      ),
                      Icon(
                        Icons.arrow_right,
                        color: Colors.white,
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
