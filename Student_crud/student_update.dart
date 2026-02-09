import 'package:flutter/material.dart';
import 'logic/backend.dart' as b;

class updateHome extends StatelessWidget {
  const updateHome({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('Student Details Update', style: TextStyle(color: Colors.white),),
          centerTitle: true,
          backgroundColor: Colors.deepPurple,
        ),
        body: update(),
      ),
    );
  }
}


class update extends StatefulWidget {
  const update({super.key});

  @override
  State<update> createState() => _updateState();
}

class _updateState extends State<update> {
  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  bool isEditPanelShow = false;
  bool isEditPanelLoading = false;
  bool isLoading = false;
  bool? isUpdateSuccess;
  int? studentId;
  int? result;
  List<Map?>? editPanelInfo;
  String? updatedName;
  String? updatedPhoneNumber;
  @override
  Widget build(BuildContext context) {
    late final screenWidth = MediaQuery.of(context).size.width;
    late final screenHeight = MediaQuery.of(context).size.height;
    return SafeArea(
      child: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            width: screenWidth/1.2,
            child: Column(
              spacing: screenHeight/27,
          mainAxisAlignment: .center,
          children: [
            SizedBox(
              height: screenHeight/7,
            ),
            Form(
        key: _formKey1,
        child: Column(
          spacing: screenHeight/27,
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: "Enter the student id"),
              validator: (value) {
                if(value!.isEmpty) {
                  return 'Enter the id';
                }
                return null;

              },
              onSaved: (value) {
                studentId = int.parse(value!);
              },
            ),
            ElevatedButton(
                onPressed: () async {
                  if(_formKey1.currentState!.validate()) {
                    setState(() {
                      isEditPanelLoading = true;
                    });
                    _formKey1.currentState!.save();
                    editPanelInfo = await b.display("single", id: studentId);
                    if(editPanelInfo != null) {
                      setState(() {
                        isEditPanelLoading = false;
                       isEditPanelShow = true;
                      });
                    }
                  }

                },
                child: Text("Edit"),
            ),
          ]
        )

      ),

            if(isEditPanelShow == true) (
                isEditPanelLoading ? CircularProgressIndicator()
                :Form(
              key: _formKey2,
              child: Column(
                spacing: screenHeight/27,
                children: [
                  SizedBox(
                    height: screenHeight/42,
                  ),
                  Text('Editing Panel', style: TextStyle(fontSize: 30, color: Colors.deepPurple),),
                  TextFormField(
                    decoration: InputDecoration(labelText: "Name"),
                    validator: (value) {
                      if(value == null || value.isEmpty) {
                        return "Name is mandatory";
                      }
                      if(value.contains(RegExp(r'^[^A-Za-z]+$'))) {
                        return "Only letters are allowed";
                      }
                      return null;

                    },
                    onSaved: (value) {
                      updatedName = value;
                    },
                    initialValue: editPanelInfo?[0]?['name'],
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: "Phone Number"),
                    validator: (value) {
                      if(value!.isEmpty) {
                        return 'Phone number is mandatory';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      updatedPhoneNumber = value;
                    },
                    initialValue: editPanelInfo?[0]?['phoneNumber'].toString(),

                  ),
                  ElevatedButton(
                      onPressed: () async {
                        if(_formKey2.currentState!.validate()) {
                          setState(() {
                            isUpdateSuccess = false;
                          });
                          _formKey2.currentState!.save();
                          result = await b.update(studentId!, name: updatedName, phoneNumber: updatedPhoneNumber );
                          if(result != 0) {
                            setState(() {
                              isUpdateSuccess = true;
                              isEditPanelShow = false;
                            });
                          }
                          else {
                            setState(() {
                              isUpdateSuccess = false;
                              isEditPanelShow = false;
                            });
                          }

                        }
                      },
                      child: Text('Update'),
                  ),

                ],
              ),
            )
            ),
            if(isUpdateSuccess == true) (
                Text("Student details of the student with the id $studentId are updated", style: TextStyle(color: Colors.green),)
            )
          ]
      )
      ),
    ),
    )
    );
  }
}
