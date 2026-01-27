import 'dart:core';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'logic/backend.dart';

class register_home extends StatelessWidget {
  const register_home({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('Student Registration', style: TextStyle(color: Colors.white),),
          centerTitle: true,
          backgroundColor: Colors.deepPurple,

        ),
        body: register(),

      ),

    );
  }
}

class register extends StatefulWidget {
  const register({super.key});
  @override
  State<register> createState() => _registerState();
}

class _registerState extends State<register> {
  final _formKey = GlobalKey<FormState>();
  String? fullName;
  DateTime? dobSelected;
  String? dobSaved;
  String? gender;
  String? phoneNumber;
  List<DropdownMenuItem<dynamic>>? dropDownEntries = [
    DropdownMenuItem(value: 'Female', child: Text('Female')),
    DropdownMenuItem(value: 'Male', child: Text('Male')),
    DropdownMenuItem(value: 'Transgender',child: Text('Transgender'),),
  ];
  String? selectedGender;
  bool isLoading = false;
  bool? result;
  final TextEditingController dobController = TextEditingController();



  String? nameValidate(String? value) {
    if(value == null || value.isEmpty) {
      return "Name is mandatory";
    }
    if(value.contains(RegExp(r'^[^A-Za-z]+$'))) {
      return "Only letters are allowed";
    }
    return null;
  }

  String? phoneNumberValidate(String? value) {

    if(value!.isEmpty) {
      return 'Phone number is mandatory';
    }
    return null;
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? dobPicked = await showDatePicker(
        context: context,
        firstDate: DateTime(1990),
        lastDate: DateTime(2008),
    );

    setState(() {
      dobSelected = dobPicked;
      final DateTime dateOnly = DateTime(
        dobSelected!.year,
        dobSelected!.month,
        dobSelected!.day,
      );
      dobSaved = DateFormat('dd-MM-yyyy').format(dateOnly);
      dobController.text = dobSaved!;
    });

  }


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
            child:  Center(
        child: isLoading == true ? CircularProgressIndicator() :Column(
          mainAxisAlignment: .center,

          spacing: 20,
          children: [
            SizedBox(
              height: screenHeight/11.5,
            ),

        SizedBox(
          width: double.infinity,
          child: Text('Enter the following details to register a student.'
              'Student ID will be created automatically.', style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
        ),

         Form(
          key: _formKey,
          child: SizedBox(
              width: screenWidth/1.2,

              child: Column(
                mainAxisAlignment: .center,
                crossAxisAlignment: .center,
                spacing: screenHeight/27,
                children: [

                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Enter the full name of student'),
                    keyboardType: TextInputType.name,
                    validator: nameValidate,
                    onSaved: (name) {
                      fullName = name;
                    },
                  ),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                            decoration: const InputDecoration(labelText: 'Pick the Date of Birth', ),
                            keyboardType: TextInputType.datetime,
                            controller: dobController,
                            readOnly: true,
                            validator: (value) {
                              if(value!.isEmpty) {
                                return "Mandatory field";

                              }
                              return null;
                            },
                        ),
                      ),
                      TextButton(
                        onPressed: ()async => await selectDate(context),
                        child: Icon(Icons.date_range),
                      )
                    ],
                  ),


                  DropdownButtonFormField(
                    decoration: InputDecoration(labelText: "Choose the gender"),
                    items: dropDownEntries,
                    onSaved: (value) {
                      selectedGender = value;
                    },
                    initialValue: null,
                    onChanged: (value) {
                      selectedGender = value;

                    },
                    validator: (value) {
                      if(value == null) {
                        return "Mandatory field";
                      }
                      return null;
                    },
                  ),

                  TextFormField(
                    decoration: const InputDecoration(labelText: "Enter the student's phone number" ),
                    keyboardType: TextInputType.numberWithOptions(),
                    onSaved: (phoneNo) {
                      phoneNumber = phoneNo;
                    },
                    validator: phoneNumberValidate,
                  ),

                  ElevatedButton(
                      onPressed: () async {
                        if(_formKey.currentState!.validate()) {
                          setState(() {
                            isLoading = true;
                          });
                          _formKey.currentState!.save();
                          result = await create(fullName!, dobSaved!, selectedGender!, phoneNumber!);
                          if(result != null) {
                            setState(() {
                              isLoading = false;
                            });
                          }
                        }

                        setState(() {
                          isLoading = false;
                        });
                        dobController.text ="";
                      },
                      child: const Text('Register')
                  ),
                  if(result == true) (SizedBox(
                    child: Text('Record created for student $fullName', style: TextStyle(color: Colors.green),)
                  ))
            ],
          )
        ),
        ),

      ],
    ),
    ),
        ),
    );
  }
}
