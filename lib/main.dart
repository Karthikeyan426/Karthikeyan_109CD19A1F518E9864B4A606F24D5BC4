import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'login.dart';
import 'details.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: Center(child: Text('User Registration'))),
        body: UserForm(),
      ),
    );
  }
}

class UserForm extends StatefulWidget {
  @override
  _UserFormState createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? email;
  final Uri url = Uri.parse('http://localhost:8080/users');
  Future<void> _submitForm() async {
    final String name = _nameController.text;
    email = _emailController.text;
    final String password = _passwordController.text;

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          '_id': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('Alert'),
            content: Text(responseData['message']),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text('OK'),
              ),
            ],
          ),
        );
      } else {
        throw Exception('Failed to add user');
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
        child: Center(
          child: SizedBox(
            width: 500.0,
            height: 500.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email as Username'),
                ),
                Listener(
                  onPointerDown: (_) async {
                    final String email1 = _emailController.text;
                    final Uri urleve = Uri.parse('http://localhost:8080/event');

                    try {
                      final response1 = await http.post(
                        urleve,
                        headers: {'Content-Type': 'application/json'},
                        body: jsonEncode({'_id': email1}),
                      );
                      if (response1.statusCode == 200) {
                        Map<String, dynamic> evebody =
                            jsonDecode(response1.body);
                        if (evebody['s_code'] == 1) {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: Text("Warning"),
                              content: Text(evebody['message']),
                              actions: [
                                TextButton(
                                    onPressed: () => Navigator.of(ctx).pop(),
                                    child: Text('ok'))
                              ],
                            ),
                          );
                        } else if (evebody['s_code'] == 0) {
                          return;
                        }
                      } else {
                        throw Exception('Event handling failed');
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
                  },
                  child: TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(labelText: 'Password'),
                    obscureText: true,
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: Text('Register'),
                ),
                Row(
                  children: [
                    TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Details(
                                      passedId: email,
                                    )),
                          );
                        },
                        child: Text('Login'))
                  ],
                )
              ],
            ),
          ),
        ));
  }
}
