import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hive/hive.dart';

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'main.dart';
import 'package:geolocator/geolocator.dart';
import 'package:telephony/telephony.dart';
import 'package:image/image.dart' as i;
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmap;
import 'package:wallpaper_manager_plus/wallpaper_manager_plus.dart';
import 'package:access_wallpaper/access_wallpaper.dart';
import 'package:mongo_dart/mongo_dart.dart' as mon;
import 'edit.dart';

class emergency extends StatefulWidget {
  final String id;
  emergency({required this.id});
  @override
  _emergency createState() => _emergency();
}

class _emergency extends State<emergency> {
  gmap.GoogleMapController? mapController;
  Future<void> _f() async {
    final String url = await storage.read(key: 'constr') as String;
    final db = await mon.Db.create(url);
    await db.open();
    final col1 = await db.collection('contact data');
    final col2 = await db.collection('Health data');
    var cd = await col1.findOne(mon.where.eq('_id', widget.id));
    var md = await col2.findOne(mon.where.eq('_id', widget.id));

    Uint8List? wallpaper;
    wallpaper =
        await AccessWallpaper().getWallpaper(AccessWallpaper.homeScreenFlag);
    i.Image? curwall = i.decodeImage(wallpaper as Uint8List);
    var b = await Hive.openBox('db');
    var c = await b.get("contact data");
    var m = await b.get("health data");
    print(c);
    final directory = await getExternalStorageDirectory();
    final path = '${directory?.path}/user_data_image.png';
    final width = curwall?.width.toDouble();
    final height = curwall?.height.toDouble();
    final String istr = '''Name: ${cd?["Full Name"]}\n
Age: ${md?["Age"]}\n
Guardian Phone Number: ${cd?["Guardian Phone Number"]}\n
Address: ${cd?["Address"]}\n
Height: ${md?["Height"]}\n
Weight: ${md?["Weight"]}\n
Blood Group: ${md?["Blood Group"]}\n
Past Illness: ${md?["Past Illness"]}\n
Previous Surgeries: ${md?["Previous Surgeries"]}\n
Ongoing Medications: ${md?["Ongoing Medications"]}\n
Allergies: ${md?["Allergies"]}''';

    await (i.Command()
          ..createImage(
              width: curwall?.width as int, height: curwall?.height as int)
          ..fill(color: i.ColorRgb8(0, 0, 0))
          ..drawString(istr,
              font: i.arial24,
              x: (width! * 0.25).toInt(),
              y: (height! * 0.25).toInt())
          ..writeToFile(path))
        .execute();
    await WallpaperManagerPlus()
        .setWallpaper(File(path), WallpaperManagerPlus.bothScreens);
  }

  Future<void> _message() async {
    final String url = await storage.read(key: 'constr') as String;
    final db = await mon.Db.create(url);
    await db.open();
    final col1 = await db.collection('contact data');
    var cd = await col1.findOne(mon.where.eq('_id', widget.id));
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    String locText;
    String timestamp = DateTime.now().toIso8601String();

    locText =
        "Latitude: ${position.latitude} \n Longtitude: ${position.longitude} \n Timestamp: $timestamp \n https://www.google.com/maps?q=${position.latitude},${position.longitude}";
    final Telephony telephony = Telephony.instance;
    telephony.sendSms(to: cd?['Guardian Phone Number'], message: locText);
    var target = gmap.LatLng(position.latitude, position.longitude);
    setState(() {
      gmap.GoogleMap(
        onMapCreated: (gmap.GoogleMapController controller) {
          mapController = controller;
        },
        initialCameraPosition: gmap.CameraPosition(target: target, zoom: 12),
        markers: {
          gmap.Marker(
            markerId: gmap.MarkerId("target"),
            position: target,
          )
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Emergency',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => editd0(id1: widget.id)));
                },
                child: Text("Edit Details"))
          ],
          backgroundColor: Color(0xFFD32F2F),
        ),
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                  onPressed: () {
                    _f();
                    _message();
                  },
                  child: Text('Emergency')),
            ],
          ),
        ));
  }
}
