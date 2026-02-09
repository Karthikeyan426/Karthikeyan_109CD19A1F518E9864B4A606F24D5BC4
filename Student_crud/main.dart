import 'package:flutter/material.dart';
import 'student_create.dart';
import 'student_display.dart';
import 'student_update.dart';
import 'student_delete.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Student Information Manager',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Student Information Manager'),
      routes: <String, WidgetBuilder> {
        '/register': (BuildContext context) => register_home(),
        '/display': (BuildContext context) => displayHome(),
        '/edit': (BuildContext context) => updateHome(),
        '/delete': (BuildContext context) => deleteHome(),
      }
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text(widget.title, style: TextStyle(color: Colors.white),),
        centerTitle: true,
      ),
      body: Center(
          child: Column(
            mainAxisAlignment: .center,
            children: [
              ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  icon: const Icon(Icons.assignment_ind_outlined) ,
                  label: Text('Student Register')
              ),

              SizedBox(
                height: 20,
              ),

              ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/display');
                  },
                  icon: const Icon(Icons.assignment_outlined),
                  label: const Text('Student Display'),
              ),

              SizedBox(
                height: 20,
              ),

              ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/edit');

                  },
                  icon: const Icon(Icons.edit_note_outlined),
                  label: const Text('Student Details Edit'),
              ),
              
              SizedBox(
                height: 20,
              ),
              
              ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/delete');
                  },
                  icon: const Icon(Icons.person_remove_outlined),
                  label: const Text('Student Unregister'),
              )
            ],
          )
        ),

    );
  }
}
