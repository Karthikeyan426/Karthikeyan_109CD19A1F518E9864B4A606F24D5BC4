import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as m;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'main.dart';
import 'package:intl/intl.dart';

class Details extends StatefulWidget {
  final String? passedId;
  Details({this.passedId});
  @override
  _detailsState createState() => _detailsState();
}

class _detailsState extends State<Details> {
  final TextEditingController _fullname = TextEditingController();
  final TextEditingController _phoneNo = TextEditingController();
  final TextEditingController _address = TextEditingController();
  final TextEditingController _guardianName = TextEditingController();
  final TextEditingController _gaurdianPhoneNo = TextEditingController();
  final TextEditingController _height = TextEditingController();
  final TextEditingController _weight = TextEditingController();
  final TextEditingController _bGroup = TextEditingController();

  final TextEditingController _pastIll = TextEditingController();
  final TextEditingController _preSurgs = TextEditingController();
  final TextEditingController _ongMeds = TextEditingController();
  final TextEditingController _allgs = TextEditingController();
  final TextEditingController _date = TextEditingController();

  final storage = FlutterSecureStorage();
  String? selectedvalue;
  final List<String> bGroups = ['A', 'B', 'O', 'AB'];
  Future<void> _dateselect(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      firstDate: DateTime(1940),
      lastDate: DateTime(2040),
    );
    if (picked != null) {
      setState(() {
        _date.text = DateFormat('dd-MM-yyyy') as String;
      });
    }
  }

  Future<void> _form1() async {
    await storage.write(
        key: 'constr',
        value:
            'mongodb+srv://karthk2642005:k1234@cluster0.xs2kf.mongodb.net/test?retryWrites=true&w=majority&appName=Cluster0');
    final String fullname = _fullname.text;
    final String phoneNo = _phoneNo.text;
    final String address = _address.text;
    final String gaurdianName = _guardianName.text;
    final String gaurdianPhoneNo = _gaurdianPhoneNo.text;
    final double height = _height.value as double;
    final double weight = _weight.value as double;
    final String bGroup = _bGroup.text;
    final String pastIll = _pastIll.text;
    final String preSurgs = _preSurgs.text;
    final String ongMeds = _ongMeds.text;
    final String allgs = _allgs.text;
    final int age = DateTime.now().difference(_date.text as DateTime) as int;

    final String conStr = storage.read(key: 'constr') as String;
    var db = await m.Db.create(conStr);
    await db.open();
    var coll = db.collection('Contact Details');
    Map<String, dynamic> conData = {
      '_id': widget.passedId,
      'Full Name': fullname,
      'Phone Number': phoneNo,
      'Address': address,
      'Gaurdian Name': gaurdianName,
      'Gaurdian Phone Number': gaurdianPhoneNo,
    };
    await coll.insertOne(conData);

    var coll1 = db.collection('Health Details');
    Map<String, dynamic> healthData = {
      '_id': widget.passedId,
      'Age': age,
      'Height': height,
      'Weight': weight,
      'Blood Group': bGroup,
      'Past Illness': pastIll,
      'Previous Surgeries': preSurgs,
      'Ongoing Medications': ongMeds,
      'Allergies': allgs
    };
    await coll1.insert(healthData);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          appBar: AppBar(
            title: Text('Details'),
            centerTitle: true,
          ),
          body: ListView(children: [
            TextField(
              controller: _fullname,
              decoration: InputDecoration(labelText: 'Full name'),
            ),
            TextField(
              controller: _date,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Select your date of birth',
              ),
              onTap: () => _dateselect(context),
            ),
            TextField(
              controller: _phoneNo,
              decoration: InputDecoration(labelText: 'Phone number'),
            ),
            TextField(
              controller: _address,
              decoration: InputDecoration(labelText: 'Address'),
            ),
            TextField(
              controller: _guardianName,
              decoration: InputDecoration(labelText: 'Gaurdian Name'),
            ),
            TextField(
              controller: _gaurdianPhoneNo,
              decoration: InputDecoration(labelText: 'Gaurdian phone number'),
            ),
            TextField(
              controller: _height,
              decoration: InputDecoration(labelText: 'Height'),
            ),
            TextField(
              controller: _weight,
              decoration: InputDecoration(labelText: 'Weight'),
            ),
            DropdownButton<String>(
                value: selectedvalue,
                hint: Text('Select an bloodgroup'),
                items: bGroups.map((String item) {
                  return DropdownMenuItem(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                onChanged: (String? newvalue) {
                  setState(() {
                    selectedvalue = newvalue;
                  });
                }),
            TextField(
                controller: _pastIll,
                decoration: InputDecoration(labelText: 'Past Illness')),
            TextField(
                controller: _preSurgs,
                decoration: InputDecoration(labelText: 'Previous Surgeries')),
            TextField(
              controller: _ongMeds,
              decoration: InputDecoration(labelText: 'Ongoing medicines'),
            ),
            TextField(
              controller: _allgs,
              decoration: InputDecoration(labelText: 'Allergies'),
            )
          ])),
    );
  }
}
