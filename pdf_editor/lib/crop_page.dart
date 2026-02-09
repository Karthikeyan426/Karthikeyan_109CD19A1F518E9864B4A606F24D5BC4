import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'logic/crop_logic.dart';
import 'common_functions.dart';
import 'main.dart';
import 'package:android_path_provider/android_path_provider.dart';
class cropPage extends StatefulWidget {
  const cropPage({super.key});

  @override
  State<cropPage> createState() => _cropPageState();
}

class _cropPageState extends State<cropPage> {
  var isFileUploaded = false;
  String fileName = "";
  late File file;
  //key for form.
  List<dynamic>? fileUploadResult;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  int? startPageNumber, endPageNumber;
  File? croppedPDF;
  bool _loading = false;
  bool isDownloaded = false;
  late String processedFileName;
  String? formValidate (String? value) {
  if(value == null || value.isEmpty) {
  return "Enter a number";
  }
  final startN = int.tryParse(value);
  if(startN == null || startN < 1) {
  return "Invalid integer";
  }
  return null;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          leading: BackButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => MyApp()));
            },
          ),
          title: Text("PDF crop", style: TextStyle(color: Colors.white),),
          centerTitle: true,
          backgroundColor: Colors.red,
        ),
        body: Center(
        child: _loading ? CircularProgressIndicator() : Column (
          spacing: screenHeight/30,
          mainAxisAlignment: .center,
          crossAxisAlignment: .center,
          children: [
            GestureDetector(
              onTap: () async {
                fileUploadResult = await uploadFile();
                if(fileUploadResult != null) {

                  file = fileUploadResult?[1];
                  setState(() {
                    isFileUploaded = true;
                    fileName = fileUploadResult?[0];
                  });
                  processedFileName = '${DateTime.now().millisecondsSinceEpoch}_cropped';
                }
                },
              child: Container(
                width: screenWidth/2,
                height: screenHeight/4,
                decoration: BoxDecoration(
                  border: BoxBorder.all(color: isFileUploaded ? Colors.green : Colors.blue, style: BorderStyle.solid),
                  borderRadius:  BorderRadius.all(Radius.circular(screenWidth/20)),
                ),
                child: Column(
                  spacing: screenHeight/35,
                  mainAxisAlignment: .center,
                  crossAxisAlignment: .center,
                  children: [
                    Icon(Icons.upload),
                    if(isFileUploaded)(
                    ListTile(
                      title: Text(fileName, softWrap: true, maxLines: 2, overflow: TextOverflow.fade,),
                      trailing: Icon(Icons.picture_as_pdf),
                    )
                    )
                  ],
                ),

              ),
            ),

            Form (
              key: _formKey,
              child: SizedBox(
                width: screenWidth/1.3,
                child: Column(
                  spacing: screenHeight/25,
                  children: <Widget>[
                    TextFormField(
                      decoration: const InputDecoration(
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.red)
                        ),
                          hintText: 'Enter starting page number'),
                      keyboardType: TextInputType.number,
                      validator: formValidate,
                      onSaved: (value) {
                        startPageNumber = int.tryParse(value!);
                      },
                    ),
                    TextFormField(
                      decoration: const InputDecoration(hintText: 'Enter ending page number', focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.red)
                      ),),
                      keyboardType: TextInputType.number,
                      validator: formValidate,
                      onSaved: (value) {
                        endPageNumber = int.tryParse(value!);
                      },
                    ),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red
                        ),
                        onPressed: isFileUploaded ? () async {
                          if(_formKey.currentState!.validate()) {
                            setState(() {
                              _loading = true;
                            });
                            _formKey.currentState!.save();
                            final result = await crop(startPageNumber!, endPageNumber!, file);
                            setState(() {
                              croppedPDF = result;
                              _loading = false;
                            });
                          }
                        } : null,
                        child: const Text("crop", style: TextStyle(color: Colors.white),)
                    )

                  ],

                ),
              ) ,
            ),
            if(croppedPDF != null) (
              Row(
                mainAxisAlignment: .spaceAround,
                children: [
                  Text("Download your cropped PDF", style: TextStyle(fontSize: screenWidth/25),),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,

                      ),
                      onPressed: () async {
                        setState(() {
                          _loading = true;
                          isDownloaded = false;
                        });
                        bool downloadResult = await downloadFile(croppedPDF!, processedFileName);
                        setState(() {
                          isDownloaded = downloadResult;
                          _loading = false;
                        });
                      },
                      child: Text('Download', style: TextStyle(color: Colors.white),)
                  ),

                ]
              )
            ),
            if(isDownloaded == true) (
                Text("File is downloaded", style: TextStyle(color: Colors.green),)
            )
          ],


        ),
      )
      )
    );
  }
}

