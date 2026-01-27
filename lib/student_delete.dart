import 'package:flutter/material.dart';
import 'logic/backend.dart' as b;

class deleteHome extends StatelessWidget {
  const deleteHome({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('Student unregistration', style: TextStyle(color: Colors.white),),
          centerTitle: true,
          backgroundColor: Colors.deepPurple,
        ),
        body: delete(),
      ),
    );
  }
}


class delete extends StatefulWidget {
  const delete({super.key});

  @override
  State<delete> createState() => _deleteState();
}

class _deleteState extends State<delete> {
  final _formkey = GlobalKey<FormState>();
  int? studentId;
  int? result;
  bool wrongId = false;
  bool isLoading = false;
  bool resultAvailable = false;

  
  String? idValidate(String? value) {
    if(value!.contains(RegExp(r'^(?!\d+$).+'))) {
      return "Only integers are allowed";
    }
    if(value.isEmpty) {
      return "Enter the id";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return isLoading? CircularProgressIndicator() : Center(
      child: Form(
        key: _formkey,
          child: SizedBox(
            width: screenWidth/1.2,
              child: Column(
                mainAxisAlignment: .center,
            spacing: screenHeight/27,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Enter the id'),
                keyboardType: TextInputType.numberWithOptions(),
                validator: idValidate,
                onSaved: (id) {
                  studentId = int.tryParse(id!);
                },
              ),

              ElevatedButton(
                  onPressed: () async {
                    if(_formkey.currentState!.validate()) {
                      setState(() {
                        isLoading = true;
                      });
                      _formkey.currentState!.save();
                      result = await b.delete(studentId!);
                      print('hello');
                      if(result == 0 && result!=null) {
                        setState(() {
                          wrongId = true;
                          resultAvailable = true;
                          isLoading = false;
                        });
                      }
                      else {
                        setState(() {
                          wrongId = false;
                          resultAvailable = true;
                          isLoading = false;
                        });
                      }
                    }
                  },
                  child: const Text('Delete')
              ),
               if(resultAvailable == true) (
               wrongId == true  ? SizedBox(
                child: Text("Student with this id doesn't exist", style: TextStyle(color: Colors.red), ),
              ) : SizedBox(
                child: Text('Student with the id $studentId deleted successfully', style: TextStyle(color: Colors.green),),
              )
    ),
            ],
          )
      ),
    ),
    );
  }
}
