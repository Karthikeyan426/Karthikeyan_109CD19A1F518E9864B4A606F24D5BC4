import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as m;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'main.dart';
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';
import 'emerg.dart';

class d extends StatelessWidget {
  final String id;
  d({required this.id});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: AppBar(
            title: Text('Details', style: TextStyle(color: Colors.white),),
            centerTitle: true,
            backgroundColor: Color(0xFFD32F2F),
          ),
          backgroundColor: Colors.white,
          body: Details(id1: id),
        ));
  }
}

class Details extends StatefulWidget {
  final String id1;
  Details({required this.id1});
  @override
  _detailsState createState() => _detailsState();
}

class _detailsState extends State<Details> {
  final TextEditingController _fullname = TextEditingController();
  final TextEditingController _phoneNo = TextEditingController();
  final TextEditingController _address = TextEditingController();
  final TextEditingController _guardianName = TextEditingController();
  final TextEditingController _guardianPhoneNo = TextEditingController();
  final TextEditingController _height = TextEditingController();
  final TextEditingController _weight = TextEditingController();
  final TextEditingController _bGroup = TextEditingController();

  final TextEditingController _pastIll = TextEditingController();
  final TextEditingController _preSurgs = TextEditingController();
  final TextEditingController _ongMeds = TextEditingController();
  final TextEditingController _allgs = TextEditingController();
  final TextEditingController _date = TextEditingController();

  String? selectedvalue;
  final List<String> bGroups = ['A+',
      'A- ', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];

  Future<void> _form1() async {

    final String fullname = _fullname.text;
    final String phoneNo = _phoneNo.text;
    final String address = _address.text;
    final String guardianName = _guardianName.text;
    final String guardianPhoneNo = _guardianPhoneNo.text;
    final double? height = double.tryParse(_height.text);
    final double? weight = double.tryParse(_weight.text);
    final String? bGroup = selectedvalue;
    final String pastIll = _pastIll.text;
    final String preSurgs = _preSurgs.text;
    final String ongMeds = _ongMeds.text;
    final String allgs = _allgs.text;
    final String dob = _date.text;
    final DateTime bod = DateFormat('dd-MM-yyyy').parseStrict(_date.text);
    print(bod);
    print(DateTime.now());
    final int age = DateTime.now().difference(bod).inDays ~/ 365;
    print(age);

    var box = Hive.box('db');
    final String url1 = await storage.read(key: 'constr') as String;
    final db2 = await m.Db.create(url1);
    await db2.open();
    final colcon = await db2.collection('contact data');
    final colmed = await db2.collection('Health data');

    Map<String, dynamic> conData = {
      '_id': widget.id1,
      'Full Name': fullname,
      'Phone Number': phoneNo,
      'Address': address,
      'Guardian Name': guardianName,
      'Guardian Phone Number': guardianPhoneNo,
    };
    box.put('contact data', conData);
    await colcon.insertOne(conData);

    Map<String, dynamic> healthData = {
      '_id': widget.id1,
      'dob': dob,
      'Age': age,
      'Height': height,
      'Weight': weight,
      'Blood Group': bGroup,
      'Past Illness': pastIll,
      'Previous Surgeries': preSurgs,
      'Ongoing Medications': ongMeds,
      'Allergies': allgs
    };
    box.put('health data', healthData);
    colmed.insertOne(healthData);
    var c = box.get('health data');
    var h = box.get('contact data');
    print('gh');
    print(h);

  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width-1.0,
      child: ListView(children: [
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
          onTap: () async {
            DateTime? picked = await showDatePicker(
              context: context,
              firstDate: DateTime(1940),
              lastDate: DateTime(2040),
            );
            if (picked != null) {
              setState(() {
                _date.text = DateFormat('dd-MM-yyyy').format(picked);
              });
            }
          },
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
          decoration: InputDecoration(labelText: 'Guardian Name'),
        ),
        TextField(
          controller: _guardianPhoneNo,
          decoration: InputDecoration(labelText: 'Guardian phone number'),
        ),
        TextField(
          controller: _height,
          decoration: InputDecoration(labelText: 'Height (in centimeters)'),
        ),
        TextField(
          controller: _weight,
          decoration: InputDecoration(labelText: 'Weight (in kilograms)'),
        ),
        DropdownButton<String>(
            value: selectedvalue,
            hint: Text('Select an blood group'),
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
        ),
        ElevatedButton(
            onPressed: () async {
              UserFormState ins = UserFormState();
              ins.loading(context);
              await _form1();
              Navigator.of(context,rootNavigator: true).pop();
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => emergency(id: widget.id1)));
            },
            child: Text('Save'))
      ]),
    );
  }
}
