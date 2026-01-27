import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'logic/crop_logic.dart';
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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  int? startPageNumber, endPageNumber;
  File? croppedPDF;
  bool _loading = false;

  void uploadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if(result != null) {
      setState(() {
        fileName = path.absolute(result.files.single.path!);
        isFileUploaded = true;
      });
      file = File(result.files.single.path!);
    }
    else {

    }
  }

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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text("PDF crop"),
          backgroundColor: Colors.deepPurple,

        ),
        body: Center(

        child: _loading ? CircularProgressIndicator() : Column (
          mainAxisAlignment: .center,
          children: [
            FloatingActionButton(
                onPressed: () => uploadFile(),
                tooltip: "Upload a PDF file",
                child: Icon(Icons.upload_file),
            ),
            if(isFileUploaded) (

            ListTile(
              title: Text(fileName),
              trailing: Icon(Icons.picture_as_pdf),
            )
            ),

            Form (
              key: _formKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    decoration: const InputDecoration(hintText: 'Enter starting page number'),
                    keyboardType: TextInputType.number,
                    validator: formValidate,
                    onSaved: (value) {
                      startPageNumber = int.tryParse(value!);
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(hintText: 'Enter ending page number'),
                    keyboardType: TextInputType.number,
                    validator: formValidate,
                    onSaved: (value) {
                      endPageNumber = int.tryParse(value!);
                    },
                  ),
                  ElevatedButton(
                      onPressed: () async {
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
                      },
                      child: const Text("crop")
                  )

                ],

              ),
            ),
            if(croppedPDF != null) (
              ListTile(
                title: Text("Download your cropped PDF"),
                trailing: ElevatedButton(
                    onPressed: () async {
                      final directory = await getDownloadsDirectory();
                      await croppedPDF?.copy('${directory?.path}/$fileName');
                    },
                    child: Text('Download')),
              )
            )
          ],


        ),
      )
      )
    );
  }
}

