
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:master_masjid/login/service_auth.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:page_transition/page_transition.dart';
import 'login.dart';

class Register extends StatefulWidget{

  @override
  State<Register> createState() => _RegisterState();

}

class _RegisterState extends State<Register>{
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  late String email;
  late String password;
  bool showSpinner = false;
  bool showPass = true;
  bool isStretched = false;
  bool isDone = true;
  bool isLoading = false;

  Widget buildButton() => OutlinedButton(
      onPressed: (){},
      style: OutlinedButton.styleFrom(
          shape: StadiumBorder(),
          side: BorderSide(
              width: 2, color: Colors.black
          )
      ),
      child: Text(
        "Masuk",
        style: TextStyle(
            fontSize: 18,
            color: Colors.black,
            letterSpacing: 1.5,
            fontWeight: FontWeight.bold
        ),
      )
  );


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xff466541),
        body: ModalProgressHUD(
          inAsyncCall: showSpinner,
          child: ListView(
            children: [
              Container(
                margin: EdgeInsets.only(top: 100),
                child: Column(
                  children: [
                    Text("Hello Again!",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 50,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                    Text("Welcome Back You've been missed",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w300,
                          fontSize: 20
                      ),
                    )
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 100),
                child: Column(
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
                    Container(
                      margin: EdgeInsets.only(bottom: 20),
                      child: TextField(
                        controller: _passwordController,
                        obscureText: showPass,
                        decoration: InputDecoration(
                            prefixIcon: Icon(Icons.vpn_key, color: Color(0xff2E4B0C),),
                            suffix: IconButton(
                              onPressed: (){
                                setState(() {
                                  if (showPass){
                                    showPass = false;
                                  }
                                  else {
                                    showPass = true;
                                  }
                                });
                              },
                              icon: Icon(showPass == true?CupertinoIcons.eye_fill:CupertinoIcons.eye_slash_fill),
                            ),
                            fillColor: Colors.white,
                            filled: true,
                            hintText: "Password",
                            contentPadding: EdgeInsets.only(right: 30, left: 30, bottom: 20),
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
                        if (isLoading) return;

                        setState(() {
                          isLoading = true;
                        });
                        final message = await AuthService().registration(
                            email: _emailController.text,
                            password: _passwordController.text,
                        );
                        if (message!.contains('Success')){
                          await Future.delayed(Duration(seconds: 5));
                          setState(() {
                            isLoading = false;
                          });
                          Navigator.pushNamed(context, 'login');
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(message)),
                        );
                        setState(() {
                          isLoading = false;
                        });
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
                          : Text("Daftar"),
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
              ),
              SizedBox(height: 50,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Sudah punya akun?", style: TextStyle(color: Colors.white),),
                  TextButton(
                      onPressed: (){
                        Navigator.push(context,PageTransition(
                            child: Login(),
                            type: PageTransitionType.fade
                        )
                        );

                      },
                      child: Text(
                          "Masuk"
                      )
                  ),
                ],
              )
            ],
          ),
        )
    );
  }
}