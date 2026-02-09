import 'package:flutter/material.dart';
import 'common_functions.dart';
import 'dart:io';
import 'main.dart';
import 'logic/compress_logic.dart';

class compressHome extends StatelessWidget {
  const compressHome({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          leading: BackButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => MyApp())
              );
            },
          ),
          title: Text("PDF Compression", style: TextStyle(color: Colors.white),),
          centerTitle: true,
          backgroundColor: Colors.red,

        ),
        body: compressPage(),
      ),
    );
  }
}


class compressPage extends StatefulWidget {
  const compressPage({super.key});

  @override
  State<compressPage> createState() => _compressPageState();
}

class _compressPageState extends State<compressPage> {
  bool isFileUploaded = false;
  bool isCompressed = false;
  bool isLoading = false;
  bool isDownloaded = false;
  late String fileName;
  List<dynamic>? fileUploadResult;
  late File pdfFile;
  File? result;
  late String processedFileName;
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Center(
        child: isLoading ? CircularProgressIndicator() : Column(
          crossAxisAlignment: .center,
          mainAxisAlignment: .center,
          spacing: screenHeight/30,
          children: [
        Text("Upload a PDF File to compress"),
        GestureDetector(
          onTap: () async {
            fileUploadResult = await uploadFile();
            if(fileUploadResult != null) {
              pdfFile = fileUploadResult?[1];
              setState(() {
                isFileUploaded = true;
                fileName = fileUploadResult?[0];
              });
              processedFileName = '${DateTime.now().millisecondsSinceEpoch}_compressed';
            }
          },
          child: Container(
            width: screenWidth/2,
            height: screenHeight/4,
            decoration: BoxDecoration(
                border: Border.all(color: isFileUploaded ? Colors.green : Colors.blue),
                borderRadius: BorderRadius.all(Radius.circular(screenWidth/20))
            ),
            child: Column(
              mainAxisAlignment: .spaceAround,
              mainAxisSize: MainAxisSize.max,
              children: [
                 Text("Tap here to upload!", style: TextStyle(color: Colors.deepOrange),),
                 SizedBox(
                   height: screenHeight/80,
                 ),
                 Icon(Icons.upload),
                SizedBox(
                  height: screenHeight/80,
                ),
                if(isFileUploaded) (
                ListTile(
                    title: Text(fileName, maxLines: 2, overflow: TextOverflow.fade,),
                    trailing: Icon(Icons.picture_as_pdf),
                  )
                )
              ],
            ),
          ),
        ),

        ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.red,
            ),
            onPressed: isFileUploaded ? () async {
              setState(() {
                isLoading = true;
                isCompressed = false;
                isDownloaded = false;
              });
              result = await compress(pdfFile: pdfFile);
              if(result != null ) {
                setState(() {
                  isCompressed = true;
                  isLoading = false;
                });
              }
            } : null,
            child: Text("Compress")
        ),

        if(isCompressed) (
        Column (
          spacing: screenHeight/35,
          children: [
            Row(
              mainAxisAlignment: .spaceAround,
              spacing: screenWidth/40,
              children: [
                Text("Download your compressed PDF", style: TextStyle(fontSize: screenWidth/25),),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () async {
                      setState(() {
                        isLoading = true;
                        isDownloaded = false;
                      });
                      final downloadResult = await downloadFile(result!, processedFileName);
                      setState(() {
                        isDownloaded = downloadResult;
                        isLoading = false;
                      });
                    },
                    child: Text("Download")
                )
              ],
            ),
            if(isDownloaded) (
            Text("File is downloaded",style: TextStyle(color: Colors.green),)
            )
          ],
        )

        ),
      ],
        ),
    );
  }
}
