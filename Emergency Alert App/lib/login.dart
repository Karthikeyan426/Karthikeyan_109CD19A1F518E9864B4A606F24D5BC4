import 'dart:convert';
import 'emerg.dart';

import 'main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'home.dart';
import 'package:mongo_dart/mongo_dart.dart' as m;

void main() {
  runApp(login_home());
}

class login_home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: Text('User Login', style: TextStyle(color: Colors.white),),
        backgroundColor: Color(0xFFD32F2F)),
        backgroundColor: Colors.white,
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
    print('entered');
    final String email_id = _emailController.text;
    final String pass = _passController.text;
    try {
      print('in try block');
      final String url1 = await storage.read(key: 'constr') as String;
      final db3 = await m.Db.create(url1);
      print('db');
      await db3.open();
      final col3 = db3.collection('users');
      final Map<String, dynamic> logdata = {'_id': email_id, 'password': pass};
      final Map<String, dynamic>? val =
          await col3.findOne(m.where.eq('_id', email_id).eq('password', pass));
      if (email_id.isEmpty || pass.isEmpty) {
        showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: Text('Alert'),
                  content: Text('Please enter credentials'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                      },
                      child: Text('Ok'),
                    ),
                  ],
                ));
      } else if (val != null) {
        showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: Text('Alert'),
                  content: Text('Login successful'),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => emergency(id: val['_id'])));
                        },
                        child: Text('Ok'))
                  ],
                ));
      } else if (val == null) {
        showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: Text('Alert'),
                  content: Text('Username or password is incorrect'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: Text('Ok'))
                  ],
                ));
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
                                app()));
                  },
                  child: Text('Register'))
            ],
          )
        ]));
  }
}
