import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class homeh extends StatelessWidget {
  final String data1;
  homeh({required this.data1});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            'Home',
            style: TextStyle(
              fontSize: 70.0,
              color: Colors.black,
            ),
          ),
          centerTitle: true,
          backgroundColor: const Color.fromRGBO(139, 195, 74, 1),
          actions: [
            IconButton(
              onPressed: () {
                print('iconbutton');
              },
              icon: Icon(Icons.account_circle),
              color: Colors.white,
            ),
          ],
        ),
        body: Home(data: data1),
      ),
      theme: ThemeData(
        scaffoldBackgroundColor: const Color.fromRGBO(91, 110, 121, 1),
        primarySwatch: Colors.cyan,
      ),
    );
  }
}

class Home extends StatefulWidget {
  final String data;
  Home({required this.data});
  @override
  Home_state createState() => Home_state();
}

class Home_state extends State<Home> {
  String? name1;
  Future<void> getname() async {
    final Uri url2 = Uri.parse("http://localhost:8080/getname");
    final response3 = await http.post(
      url2,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'_id': widget.data}),
    );
    if (response3.statusCode == 200) {
      Map<String, dynamic>? body4 = jsonDecode(response3.body);
      setState(() {
        name1 = body4?['name'];
      });

      print(name1);
      Text('efe');
    } else {
      throw Exception('get_name failed');
    }
    Text('efe');
  }

  @override
  void initState() {
    super.initState();
    // Call the function as soon as the page is created
    getname();
  }

  Widget build(BuildContext context) {
    if (name1 != null) {
      return Center(
        child: Text(
          'Welcome back $name1',
          style: TextStyle(
            fontSize: 50.0,
            color: Colors.lime,
          ),
        ),
      );
    } else {
      return Text('some');
    }
  }
}
