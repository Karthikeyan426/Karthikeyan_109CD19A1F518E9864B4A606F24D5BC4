import 'dart:convert';
import 'package:app1/main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'main.dart';
import 'home.dart';

void main() {
  runApp(login_home());
}

class login_home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: Text('User Login')),
        body: login(),
      ),
    );
  }
}

class login extends StatefulWidget {
  @override
  loginState createState() => loginState();
}

class loginState extends State<login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  Future<void> submitLogin() async {
    final String email_id = _emailController.text;
    final String pass = _passController.text;

    final Uri url1 = Uri.parse('http://localhost:8080/val');

    try {
      final response1 = await http.post(url1,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'_id': email_id, 'password': pass}));
      if (response1.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response1.body);
        if (responseData['s_code'] == 1) {
          showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                    title: Text('Success'),
                    content: Text(responseData['message']),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => homeh(data1: email_id)));
                        },
                        child: Text('Ok'),
                      ),
                    ],
                  ));
        } else if (responseData['s_code'] == 0) {
          showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                    title: Text('Alert'),
                    content: Text(responseData['message']),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: Text('Ok'))
                    ],
                  ));
        } else if (responseData['s_code'] == 2) {
          showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                    title: Text('Alert'),
                    content: Text(responseData['message']),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: Text('Ok'))
                    ],
                  ));
        }
      } else {
        throw Exception('Failed to sign in');
      }
    } catch (error) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Error'),
          content: Text(error.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          TextField(
            controller: _emailController,
            decoration: InputDecoration(labelText: 'Email as User name'),
          ),
          TextField(
            controller: _passController,
            decoration: InputDecoration(labelText: 'Password'),
            obscureText: true,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: submitLogin,
            child: Text('Login'),
          ),
          Row(
            children: [
              TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                Home(data: _emailController.text)));
                  },
                  child: Text('Register'))
            ],
          )
        ]));
  }
}
