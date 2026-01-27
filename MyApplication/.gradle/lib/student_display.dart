import 'package:flutter/material.dart';
import 'logic/backend.dart' as b;

class displayHome extends StatelessWidget {
  const displayHome({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('Student Details', style: TextStyle(color: Colors.white),),
          centerTitle: true,
          backgroundColor: Colors.deepPurple,
        ),
        body: display(),
      ),
    );
  }
}


class display extends StatefulWidget {
  const display({super.key});

  @override
  State<display> createState() => _displayState();
}

class _displayState extends State<display> {
  final _formKey = GlobalKey<FormState>();
  bool selectedOption = true;
  int? id;

  List<Map<dynamic, dynamic>?>? result ;
  List<Map?>? allResult;
  bool isShowMultiple = false;
  bool isShowSingle = false;
  String selectedOptionString = "all";
  Map<String, String> keyMapping = {
    'id': 'id',
    'name': 'Full Name',
    'dob': 'Date of Birth',
    'gender': 'Gender',
    'phoneNumber': 'Phone Number',
  };
  bool isShowError = false;
  @override
  Widget build(BuildContext context) {
    late final screenWidth = MediaQuery.of(context).size.width;
    late final screenHeight = MediaQuery.of(context).size.height;
    return Center(
      child: Form(
          key: _formKey,
          child: Column(
            spacing: screenHeight/27,
            children: [
              SegmentedButton<String>(
                segments: <ButtonSegment<String>>[
                  ButtonSegment<String>(value: "all", label: Text("View all students") ),
                  ButtonSegment<String>(value: "single", label: Text("View single student")),
                ],
                selected: <String>{selectedOptionString},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    selectedOptionString = newSelection.first;
                  });
                },

              ),

          selectedOptionString == "all" ?
              Container(
                height: screenHeight * 0.7,

              child: Column(
                crossAxisAlignment: .center,
                children: [
                  ElevatedButton(
                      onPressed: () async {
                        allResult = await b.display('all');
                        if(allResult != null) {
                          setState(() {
                            isShowMultiple = true;
                          });
                        }
                        print(allResult);
                      },
                      child: Text('Retrieve details'),
                  ),
                  if(isShowMultiple == true) (
                  SingleChildScrollView(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                      ),
                  child: ListView.builder(
                      itemCount: allResult?.length,
                      itemBuilder: (context, index) {
                        final student = allResult?[index];
                        final formattedStudent = student?.map(
                            (key, value) => MapEntry(keyMapping[key] ?? key, value )
                        );
                        return Card(
                          child: Column(
                            children: formattedStudent!.entries.map((e)  {
                              return Text('${e.key}: ${e.value} ');
                            }).toList()
                          ),
                        );

                      }
                  )
                  )
                  ),
                ],
              ),
              )
          : SizedBox(
            width: screenWidth/1.2,
            child: Column(
              spacing: screenHeight/27,
                children: [
                  TextFormField(
                    decoration: InputDecoration(labelText: "Enter the student's id"),
                    validator: (value) {
                      if(value!.isEmpty) {
                        return "Enter the id";
                      }
                      if(value.contains(RegExp(r'^(?!\d+$).+'))) {
                        return "Only integers are allowed";
                      }
                      return null;
                    },
                    onSaved: (value) {
                      id = int.parse(value!);
                    },
                  ),
                 ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          isShowSingle = false;
                        });
                        if(_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          result = await b.display("single", id: id);
                          if(result![0] != null) {
                            setState(() {
                              isShowSingle = true;
                              isShowError = false;
                            });
                          }
                          else {
                            setState(() {
                              isShowError = true;
                            });
                          }
                        }
                      },
                      child: Text('Retrieve information')
                  ),

                  if(isShowSingle == true) (
                  SafeArea(
                    child: SingleChildScrollView(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom,
                        ),
                   child: Card (
                      child: Column(
                        mainAxisSize: .min,
                        children: [
                          ListTile(
                            title: Text('Full Name: ${result?[0]?['name']}'),
                          ),
                          const Divider(),
                          ListTile(
                            title: Text('Gender: ${result?[0]?['gender']}'),
                          ),
                          const Divider(),
                          ListTile(
                            title: Text('Date of Birth: ${result?[0]?['dob']}'),
                          ),
                          const Divider(),
                          ListTile(
                            title: Text('Phone Number: ${result?[0]?['phoneNumber']}'),
                          )
                        ],
                      ),
                    )
                  ),
                      )
                  ),

                  if(isShowError = true)
                    (
                  Text("The student with the id $id doesn't exist", style: TextStyle(color: Colors.red),)
                  )
                ],
              )
          ),

            ],
          )
      )
      );
  }
}
