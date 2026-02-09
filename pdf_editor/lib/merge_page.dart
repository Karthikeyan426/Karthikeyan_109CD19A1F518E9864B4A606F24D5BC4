import 'dart:io';
import 'main.dart';
import 'logic/merge_logic.dart';
import 'package:flutter/material.dart';
import 'common_functions.dart';
class mergeHome extends StatelessWidget {
  const mergeHome({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text("Merge", style: TextStyle(color: Colors.white),),
          centerTitle: true,
          backgroundColor: Colors.red,
          leading: BackButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => MyApp()));
            },
          ),
        ),
        body: mergePage(),
      ),
    );
  }
}


class mergePage extends StatefulWidget {
  const mergePage({super.key});
  @override
  State<mergePage> createState() => _mergePageState();
}

class _mergePageState extends State<mergePage> {
  List<dynamic>? fileUploadResult1;
  List<dynamic>? fileUploadResult2;
  String? firstFileName;
  late File firstFile;
  String? secondFileName;
  late File secondFile;

  bool isFirstFileUploaded = false;
  bool isSecondFileUploaded = false;
  late final File? processedFile;
  bool isLoading = false;
  bool isDownloaded = false;
  bool isMerged = false;
  late String processedFileName;
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return SafeArea(
        child: isLoading ? Center(child: CircularProgressIndicator()) : Column(
          spacing: screenHeight/30,
          crossAxisAlignment: .center,
          mainAxisAlignment: .center,
          children: [
            Text("Select 2 PDF files to merge", style: TextStyle(color: Colors.greenAccent ),),
            Row(
              crossAxisAlignment: .center,
              mainAxisAlignment: .center,
              spacing: screenWidth/18,
              children: [
                GestureDetector(
                  onTap: () async {
                    fileUploadResult1 = await uploadFile();
                    if(fileUploadResult1 != null) {

                      firstFile = fileUploadResult1?[1];
                      setState(() {
                        firstFileName = fileUploadResult1?[0];
                        isFirstFileUploaded = true;
                      });
                    }
                  },
                  child: Container(
                    width: screenWidth/2.3,
                    height: screenHeight/3,
                    decoration: BoxDecoration(
                    border: BoxBorder.all(color: isFirstFileUploaded ? Colors.green : Colors.blue,),
                    borderRadius: BorderRadius.all(Radius.circular(screenWidth/20)),
                  ),
                    child: Column(
                      mainAxisAlignment: .center,
                      children: [
                        Icon(
                            Icons.upload
                        ),
                        if(isFirstFileUploaded) (
                        ListTile(
                          title: Text(softWrap: true,firstFileName!, maxLines: 2, overflow: TextOverflow.fade, style: TextStyle(fontSize: screenHeight/60),),
                          trailing: Icon(Icons.picture_as_pdf),
                        )
                        )
                      ],
                    )
                ),
                ),

                GestureDetector(
                  onTap: () async {
                    fileUploadResult2 = await uploadFile();
                    if(fileUploadResult2 != null) {
                      secondFile = fileUploadResult2?[1];
                      setState(() {
                        secondFileName = fileUploadResult2?[0];
                        isSecondFileUploaded = true;
                      });
                    }
                  },
                  child: Container(
                    width: screenWidth/2.3,
                    height: screenHeight/3,
                    decoration: BoxDecoration(
                      border: BoxBorder.all(color: isSecondFileUploaded ? Colors.green : Colors.blue,),
                      borderRadius: BorderRadius.all(Radius.circular(screenWidth/20)),
                    ),
                    child: Column(
                      mainAxisAlignment: .center,
                      children: [
                        Icon(
                            Icons.upload
                        ),
                        if(isSecondFileUploaded)(
                        ListTile(
                          title: Text(secondFileName!, softWrap: true, maxLines: 2, overflow: TextOverflow.fade, style: TextStyle(fontSize: screenHeight/60,)),
                          trailing: Icon(Icons.picture_as_pdf),
                        )
                        )
                      ],
                    )
                  ),

                )

              ],
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: (isFirstFileUploaded == true  && isSecondFileUploaded == true) ? () async {
                print("entered");
                setState(() {
                  isLoading = true;
                });
                processedFile = await merge(pdfFile1: firstFile, pdfFile2: secondFile);
                if(processedFile != null) {
                  setState(() {
                    isMerged = true;
                    isLoading = false;
                  });
                  setState(() {
                    isLoading = false;
                  });
                }
                } : null,
              child: Text("Merge", style: TextStyle(color: Colors.white),),

            ),
            if(isMerged) ( Row(
              mainAxisAlignment: .spaceAround,
              spacing: screenWidth/35,
              children: [
                Text("Download the merged PDF", style: TextStyle(fontSize: screenWidth/25),),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.red
                    ),
                    onPressed: () async {
                      setState(() {
                        isLoading = true;
                      });
                      processedFileName = "${DateTime.now().millisecondsSinceEpoch}_merged.pdf";
                      bool downloadResult = await downloadFile(processedFile!,processedFileName);
                      setState(() {
                        isLoading = false;
                        isDownloaded = downloadResult;
                      });
                    },
                    child: Text("Download")
                )
              ],
            ) ),
            if(isDownloaded) (
            Text("File is downloaded", style: TextStyle(color: Colors.green),)
            )
          ],
        )
    );
  }
}
