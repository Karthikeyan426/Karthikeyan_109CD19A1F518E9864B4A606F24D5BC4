import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'login.dart';
import 'details.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:telephony/telephony.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'emerg.dart';
import 'details.dart';
import 'package:permission_handler/permission_handler.dart';

final storage = FlutterSecureStorage();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.photos.request();
  await storage.write(
      key: 'constr',
      value:
          'mongodb+srv://karthk2642005:k1234@cluster0.xs2kf.mongodb.net/test?retryWrites=true&w=majority&appName=Cluster0');

  LocationPermission locPermission = await Geolocator.checkPermission();
  if (locPermission == LocationPermission.denied) {
    locPermission = await Geolocator.requestPermission();
  }
  if (locPermission == LocationPermission.deniedForever) {
    print('Permanently denied');
  }
  if (locPermission == LocationPermission.whileInUse) {
    print('already enabled');
  }
  final Telephony tel = Telephony.instance;
  bool? smsperm = await tel.requestSmsPermissions;
  await Hive.initFlutter();
  await Hive.openBox('db');
  runApp(app());
}

class app extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
            title: Text(
              'User Registration',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Color(0xFFD32F2F)),
        body: UserForm(),
        backgroundColor: Color(0xFFE0E0E0),
      ),
    );
  }
}

class UserForm extends StatefulWidget {
  @override
  UserFormState createState() => UserFormState();
}

class UserFormState extends State<UserForm> {
  static final storage = FlutterSecureStorage();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void loading(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Center(
            child: CircularProgressIndicator(),
          );
        });
  }

  Future<void> submitForm() async {
    loading(context);
    print('Entered');
    final String name = _nameController.text;
    final String email = _emailController.text;
    final String password = _passwordController.text;
    final Map<String, dynamic> data = {
      'name': name,
      '_id': email,
      'password': password
    };
    final String urlstr = await storage.read(key: 'constr') as String;
    print(urlstr);

    final db = await mongo.Db.create(urlstr);
    await db.open();
    final col = await db.collection('users');
    Map<String, dynamic>? ifExists =
        await col.findOne(mongo.where.eq('_id', data['_id']));

    if (email.isEmpty || password.isEmpty || name.isEmpty) {
      Navigator.of(context).pop();
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Alert'),
          content: Text('Please enter credentials'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
    } else if (ifExists == null &&
        (email.isNotEmpty && password.isNotEmpty && name.isNotEmpty)) {
      col.insertOne(data);
      Navigator.of(context).pop();
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Alert'),
          content: Text('User added'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => d(id: _emailController.text)));
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    } else {
      Navigator.of(context).pop();
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
                    print('enetered');
                    final String url =
                        await storage.read(key: 'constr') as String;
                    print(url);
                    final db0 = await mongo.Db.create(url);
                    await db0.open();
                    final col0 = db0.collection('users');
                    final String email = _emailController.text;
                    final Map<String, dynamic>? ifExists =
                        await col0.findOne(mongo.where.eq('_id', email));
                    print('event method called');

                    try {
                      if (ifExists != null) {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text("Warning"),
                            content: Text("Username already exists"),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(),
                                  child: Text('ok'))
                            ],
                          ),
                        );
                      } else {
                        return;
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
                  onPressed: () {
                    submitForm();
                  },
                  child: Text('Register'),
                ),
                Row(
                  children: [
                    TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => login_home()),
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
