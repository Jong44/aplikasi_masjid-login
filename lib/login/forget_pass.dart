import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:page_transition/page_transition.dart';

import 'login.dart';

class Forget extends StatefulWidget{

  @override
  State<Forget> createState() => _ForgetState();
}

class _ForgetState extends State<Forget>{

  final TextEditingController _emailController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff466541),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 400),
        children: [
          Container(
              margin: EdgeInsets.only(bottom: 20),
              child: TextField(
                keyboardType: TextInputType.emailAddress,
                controller: _emailController,
                decoration: InputDecoration(
                    prefixIcon: Icon(Icons.email, color: Color(0xff2E4B0C),),
                    fillColor: Colors.white,
                    filled: true,
                    hintText: "Email",
                    contentPadding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.circular(20)
                    ),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.circular(20)
                    ),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: Colors.red)
                    )
                ),
              ),
            ),
          ElevatedButton(
            onPressed: () async {
              await _auth.sendPasswordResetEmail(
                  email: _emailController.text
              );
              showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: Color(0xff466541),
                    title: const Text("Alert!", style: TextStyle(
                        color: Colors.white
                    ),),
                    content: const Text("Silahkan cek pesan email\nJika tidak ada silahkan cek pada menu spam email", style: TextStyle(
                        color: Colors.white
                    ),),
                    actions: <Widget>[
                      TextButton(
                          onPressed: (){
                            Navigator.of(ctx).pop();
                            Navigator.push(context,PageTransition(
                                child: Login(),
                                type: PageTransitionType.fade
                            )
                            );
                          },
                          child: Container(
                            color: Color(0xff466541),
                            padding: EdgeInsets.all(15),
                            child: const Text("Oke", style: TextStyle(
                              color: Colors.white
                            ),
                            ),
                          )
                      )
                    ],
                  )
              );
            },
            child: isLoading
                ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                    height: 25,
                    width: 25,
                    child: CircularProgressIndicator(color: Colors.white,)
                ),
                const SizedBox(width: 20,),
                Text("Mohon Tunggu...")
              ],
            )
                : Text("Reset Password"),
            style: ElevatedButton.styleFrom(
                textStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold
                ),
                minimumSize: Size(200, 50),
                maximumSize: Size(250, 50),
                shape: StadiumBorder(),
                primary: Color(0xff2E4B0C)
            ),
          )
        ],
      ),
    );
  }

}