import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
void main() {
    runApp(const Login());
}
//Login Page
class Login extends StatelessWidget {
    const Login({super.key});
    @override
    Widget build(BuildContext context ) {
        return MaterialApp(	
			home: Scaffold(
				backgroundColor: Color(0xFF593F62),	
				body: const Center(
						child: Column(
							children: [
								const Text("Brawls Bets", 
								    style: TextStyle(fontSize: 40, height: 10, color: Color(0xFFA5C4D4), fontFamily: "Roboto")),
                                const LoginForm()
							],
						),
					),
				),
			
		);
    }
}
//Login Form Widget
class LoginForm extends StatefulWidget {
    const LoginForm({super.key});
    
    @override
    State<LoginForm> createState() => _LoginFormState(); 
}

class _LoginFormState extends State<LoginForm> {
    //TextField Controller
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController(); 
    @override
    void dispose() {
        emailController.dispose();
        passwordController.dispose();
        super.dispose();
    }
    //Send data to server
    Future<http.Response> sendData(String email, String password){
        return http.post(
            Uri.parse('http://127.0.0.1:5000/login'),
            headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, String>{"email": email, "password": password})
        );
    }
    @override
    Widget build(BuildContext context){
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
                    Container(
                        margin: EdgeInsets.symmetric(horizontal: 30.0, vertical: 5.0),
                        padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 5.0),
                        child: TextField(
                            controller: emailController,
                            style: TextStyle(color: Color(0XFFA5C4D4)),
                            decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: "Email",
                                hintStyle: TextStyle(color: Color(0xFFA5C4D4)) 
                            ),
                        ),
                    ),
                Container(
                    margin: EdgeInsets.symmetric(horizontal: 30.0, vertical: 5.0),
                    padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 5.0 ),
                    child: TextField(
                        //Make the psw hidden
                        obscureText: true,
                        controller: passwordController,
                        style: TextStyle(color: Color(0XFFA5C4D4)),
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: "password",
                            hintStyle: TextStyle(color: Color(0XFFA5C4D4))
                        ),
                    ),
                ),
                //Button to send the data
                Center(
                    child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 30.0, vertical: 5.0),
                        padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 5.0 ),
                        decoration: BoxDecoration(
                            border: Border.all(color: Color(0xFFA5C4D4))
                        ),
                        child: TextButton(
                            onPressed: () async {
                                final response = await sendData(
                                    emailController.text,
                                    passwordController.text);
                                },
                            child: Text("Login",
                                style: TextStyle(color: Color(0XFFA5C4D4)),
                            ),
                        ),
                    ),
                ),
            ],
        );
    }
}
