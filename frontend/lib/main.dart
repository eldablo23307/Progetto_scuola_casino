import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

void main() {
    runApp(const MyApp());
}

class MyApp extends StatelessWidget{
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Brawls Bets",
      initialRoute: "/",
      routes: {
        "/": (context) => const Login(),
        "/MainApp": (context) => MainApp(),
        "/Register": (context) => Register(),
      },
    );
  }
}
//Login Page
class Login extends StatelessWidget {
    const Login({super.key});
    @override
    Widget build(BuildContext context ) {
        return Scaffold(
				backgroundColor: Color(0xFF593F62),	
				body: const Center(
						child: SingleChildScrollView( 
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
                            hintText: "Password",
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
                                if (response.statusCode == 200) {
                                  Navigator.of(context).pushNamed('/MainApp');
                                }
                                },
                            child: Text("Login",
                                style: TextStyle(color: Color(0XFFA5C4D4)),
                            ),
                        ),
                    ),
                ),
                Center( 
                    child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 30.0, vertical: 30.0),
                        padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 5.0),
                        decoration: BoxDecoration(
                            border: Border.all(color: Color(0xFFA5C4D4))
                        ),
                        child: TextButton(
                            onPressed: () {
                                Navigator.of(context).pushNamed("/Register");
                            }, 
                            child: Text(
                                "Register",
                                style: TextStyle(
                                    color: Color(0xFFA5C4D4),
                                ),
                            ),
                        ),
                    ),
                ),
            ],
        );
    }
}

class Register extends StatelessWidget {
    const Register({super.key});

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            backgroundColor: Color(0xFF593F62),
            body: const Center(
               child: SingleChildScrollView( 
                    child: Column(
					    children: [
						    const Text("Brawls Bets", 
                                style: TextStyle(fontSize: 40, height: 10, color: Color(0xFFA5C4D4), fontFamily: "Roboto")),
                            const RegisterForm()
					    ],
		    	    ), 
                ),
            ),
        );
    }
}
class RegisterForm extends StatefulWidget {
    const RegisterForm({super.key});
    
    @override
    State<RegisterForm> createState() => _RegisterFormState(); 
}
class _RegisterFormState extends State<RegisterForm> {
    //TextField Controller
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController nameController = TextEditingController();
    final TextEditingController surnameController = TextEditingController(); 
    final TextEditingController addressController = TextEditingController();
    bool _isChecked = false;
    @override
    void dispose() {
        emailController.dispose();
        passwordController.dispose();
        nameController.dispose();
        surnameController.dispose();
        addressController.dispose();
        super.dispose();
    }
    //Send data to server
    Future<http.Response> sendData(String email, String password, String name, String surname, String address){
        return http.post(
            Uri.parse('http://127.0.0.1:5000/register'),
            headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, Object>{"email": email, "password": password, "name": name, "surname": surname, "account_type": _isChecked, "address": address})
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
                            hintText: "Password",
                            hintStyle: TextStyle(color: Color(0XFFA5C4D4))
                        ),
                    ),
                ),
                Container(
                        margin: EdgeInsets.symmetric(horizontal: 30.0, vertical: 5.0),
                        padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 5.0),
                        child: TextField(
                            controller: nameController,
                            style: TextStyle(color: Color(0XFFA5C4D4)),
                            decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: "Name",
                                hintStyle: TextStyle(color: Color(0xFFA5C4D4)) 
                            ),
                        ),
                    ),
                Container(
                        margin: EdgeInsets.symmetric(horizontal: 30.0, vertical: 5.0),
                        padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 5.0),
                        child: TextField(
                            controller: surnameController,
                            style: TextStyle(color: Color(0XFFA5C4D4)),
                            decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: "Surname",
                                hintStyle: TextStyle(color: Color(0xFFA5C4D4)) 
                            ),
                        ),
                    ),
                Container(
                    margin: EdgeInsets.symmetric(horizontal: 30.0, vertical: 5.0),
                    padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 5.0),
                    child: CheckboxListTile(
                        title: const Text("Simulated Account", style: TextStyle(color: Color(0xFFA5C4D4)),),
                        value: _isChecked, 
                        onChanged: (bool? newValue) {
                            setState(() {
                                _isChecked = newValue!;                              
                            });    
                        },
                        side: BorderSide(color: Color(0xFFA5C4D4)),
                    ),
                ), 
                    Visibility(
                        visible: !_isChecked,
                        child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 30.0, vertical: 5.0),
                            padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 5.0),
                            child: TextField(
                                controller: addressController,
                                style: TextStyle(color: Color(0XFFA5C4D4)),
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    hintText: "Wallet Address",
                                    hintStyle: TextStyle(color: Color(0xFFA5C4D4)) 
                                ),
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
                                    passwordController.text,
                                    nameController.text,
                                    surnameController.text,
                                    addressController.text,
                                    );
                                if (response.statusCode == 200) {
                                    Navigator.of(context).pushNamed('/MainApp');
                                }
                            },
                            child: Text("Register",
                                style: TextStyle(color: Color(0XFFA5C4D4)),
                            ),
                        ),
                    ),
                ),
            ],
        );
    }
}


class MainApp extends StatelessWidget {
    const MainApp({super.key});

    @override
    Widget build(BuildContext context){
      return Scaffold(
        backgroundColor: Color(0xFF593F62),
        
        body: Center(
            child: Column(
                children: [
                    Text(
                        "Brawls Bets",
                        style: TextStyle(color: Color(0xFFA5C4D4), fontSize: 40, fontFamily: "Roboto"),
                    ),
                    Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Color(0xFFA5C4D4))
                        ),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                                
                            ],
                        ),
                    )
                ],
            ),
        ),
      );
    }
}
