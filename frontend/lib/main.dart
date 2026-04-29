import 'package:flutter/material.dart';

void main() {
    runApp(const Login());
}

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

class LoginForm extends StatelessWidget {
    const LoginForm({super.key});
    @override
    Widget build(BuildContext context){
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
                    const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical:  10),
                        child: const TextField(
                            decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: "Email",
                                hintStyle: TextStyle(color: Color(0xFFA5C4D4)) 
                            ),
                        ),
                    ),
                const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: const TextField(
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: "password",
                            hintStyle: TextStyle(color: Color(0XFFA5C4D4))
                        ),
                    ),
                )
            ],
        );
    }
}:w
