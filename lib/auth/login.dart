
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'service_auth.dart';



class Login extends StatefulWidget{
  @override
  State<Login> createState() => _LoginState();

}

class _LoginState extends State<Login>{


  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  late String email;
  late String password;
  bool showSpinner = false;
  bool showPass = true;
  bool isLoading = false;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff466541),
      body: Stack(
        children: [
          Row(
            children: [
              Image.asset('assets/1.png'),
              SizedBox(width: 70,),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Hello Again',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                        Text(
                          'Welcome Back You`ve Been Missed',
                          style: TextStyle(
                            fontSize: 20,
                              color: Colors.white
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    width: 300,
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      children: [
                       Container(
                         margin: EdgeInsets.symmetric(vertical: 10),
                         child:  TextField(
                           keyboardType: TextInputType.emailAddress,
                           controller: _emailController,
                           style: TextStyle(
                             fontSize: 15
                           ),
                           decoration: InputDecoration(
                             icon: Icon(Icons.email),
                               fillColor: Colors.white,
                               filled: true,
                               hintText: "Email",
                               contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                               border: OutlineInputBorder(
                                   borderSide: BorderSide(color: Colors.black),
                                   borderRadius: BorderRadius.circular(10)
                               ),
                               enabledBorder: OutlineInputBorder(
                                   borderSide: BorderSide(color: Colors.black),
                                   borderRadius: BorderRadius.circular(10)
                               ),
                               focusedBorder: OutlineInputBorder(
                                   borderRadius: BorderRadius.circular(10),
                                   borderSide: BorderSide(color: Colors.red)
                               )

                           ),
                         ),
                       ),
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 10),
                          child: TextField(
                            controller: _passwordController,
                            style: TextStyle(
                              fontSize: 15,
                            ),
                            decoration: InputDecoration(
                                fillColor: Colors.white,
                                filled: true,
                                hintText: "Password",
                                icon: Icon(Icons.key),
                                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.black),
                                    borderRadius: BorderRadius.circular(10)
                                ),
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.black),
                                    borderRadius: BorderRadius.circular(10)
                                ),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: Colors.red)
                                )

                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 40),
                    child: ElevatedButton(
                      onPressed: () async {
                        if (isLoading) return;

                        setState(() {
                          isLoading = true;
                        });
                        final message = await AuthService().login(
                          email: _emailController.text,
                          password: _passwordController.text,
                        );
                        if (message!.contains('Success')){
                          await Future.delayed(Duration(seconds: 5));
                          setState(() {
                            isLoading = false;
                          });
                          Navigator.pushNamed(context, 'home');
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
                          : Text("Masuk"),
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
                    ),
                  )
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}