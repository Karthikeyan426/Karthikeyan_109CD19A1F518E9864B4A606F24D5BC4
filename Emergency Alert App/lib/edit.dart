import 'package:mongo_dart/mongo_dart.dart' as m;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'main.dart';
import 'emerg.dart';

class editd0 extends StatelessWidget {
  final String id1;
  editd0({required this.id1});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            'Details',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: Color(0xFFD32F2F),
        ),
        backgroundColor: Colors.white,
        body: editd(id1: id1),
      ),
    );
  }
}

class editd extends StatefulWidget {
  String id1;
  editd({required this.id1});
  @override
  _editd createState() => _editd();
}

class _editd extends State<editd> {
  var cd, md;
  String? selectedvalue;
  final List<String> bGroups = [
    'A+',
    'A- ',
    'B+',
    'B-',
    'O+',
    'O-',
    'AB+',
    'AB-'
  ];
  TextEditingController? _fullname;
  TextEditingController? _date;
  TextEditingController? _phoneNo;
  TextEditingController? _address;
  TextEditingController? _guardianName;
  TextEditingController? _guardianPhoneNo;
  TextEditingController? _height;
  TextEditingController? _weight;
  TextEditingController? _pastIll;
  TextEditingController? _preSurgs;
  TextEditingController? _ongMeds;
  TextEditingController? _allgs;
  bool isedit = false;
  @override
  void initState() {
    super.initState();
    ret();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<void> ret() async {
    print("Entered in ret");

    final String url = await storage.read(key: 'constr') as String;
    final db = await m.Db.create(url);
    await db.open();
    final c1 = await db.collection('contact data');
    final c2 = await db.collection('Health data');
    cd = await c1.findOne(m.where.eq('_id', widget.id1));
    md = await c2.findOne(m.where.eq('_id', widget.id1));
    _fullname = TextEditingController(text: cd['Full Name']);
    _date = TextEditingController(text: md['dob']);
    _phoneNo = TextEditingController(text: cd['Phone Number']);
    _address = TextEditingController(text: cd['Address']);
    _guardianName = TextEditingController(text: cd['Guardian Name']);
    _guardianPhoneNo = TextEditingController(text: cd['Guardian Phone Number']);
    _height = TextEditingController(text: md['Height'].toString());
    _weight = TextEditingController(text: md['Weight'].toString());
    selectedvalue = md['Blood Group'];
    _pastIll = TextEditingController(text: md['Past Illness']);
    _preSurgs = TextEditingController(text: md['Previous Surgeries']);
    _ongMeds = TextEditingController(text: md['Ongoing Medications']);
    _allgs = TextEditingController(text: md['Allergies']);
  }

  Future<void> save() async {
    final String url = await storage.read(key: 'constr') as String;
    final db1 = await m.Db.create(url);
    await db1.open();
    final col1 = await db1.collection("contact data");
    final col2 = await db1.collection("Health data");
    final List<String?> cdValLi = [
      _fullname?.text,
      _phoneNo?.text,
      _address?.text,
      _guardianName?.text,
      _guardianPhoneNo?.text
    ];
    final List<String> cdKeyLi = [
      "Full Name",
      "Phone Number",
      "Address",
      "Guardian Name",
      "Guardian Phone Number"
    ];
    for (int i = 0; i < cdKeyLi.length; i++) {
      await col1.updateOne(
          m.where.eq('_id', widget.id1), m.modify.set(cdKeyLi[i], cdValLi[i]));
    }
    final DateTime dob = DateFormat('dd-MM-yyyy').parseStrict(_date!.text);
    final int age = DateTime.now().difference(dob).inDays ~/ 365;
    final List<String?> mdValLi1 = [
      _date?.text,
      selectedvalue as String,
      _pastIll?.text,
      _preSurgs?.text,
      _ongMeds?.text,
      _allgs?.text
    ];
    final List<String> mdKeyLi1 = [
      "dob",
      "Blood Group",
      "Past Illness",
      "Previous Surgeries",
      "Ongoing Medications",
      "Allergies"
    ];
    final List<double?> mdValLi2 = [
      double.tryParse(_height?.text as String),
      double.tryParse(_weight?.text as String)
    ];
    final List<String> mdKeyLi2 = ['Height', 'Weight'];
    for (int i = 0; i < mdValLi1.length; i++) {
      await col2.updateOne(m.where.eq('_id', widget.id1),
          m.modify.set(mdKeyLi1[i], mdValLi1[i]));
    }
    for (int i = 0; i < mdValLi2.length; i++) {
      await col2.updateOne(m.where.eq('_id', widget.id1),
          m.modify.set(mdKeyLi2[i], mdValLi2[i]));
    }
    await col2.updateOne(
        m.where.eq('_id', widget.id1), m.modify.set('Age', age));
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Alert'),
        content: Text('Saved sucessfully'),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();

                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (ctx) => emergency(
                              id: widget.id1,
                            )));
              },
              child: Text('ok')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: ListView(children: [
        TextField(
          controller: _fullname,
          decoration: InputDecoration(labelText: 'Full name'),
          enabled: isedit,
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
                _date?.text = DateFormat('dd-MM-yyyy').format(picked);
              });
            }
          },
          enabled: isedit,
        ),
        TextField(
          controller: _phoneNo,
          decoration: InputDecoration(labelText: 'Phone number'),
          enabled: isedit,
        ),
        TextField(
          controller: _address,
          decoration: InputDecoration(labelText: 'Address'),
          enabled: isedit,
        ),
        TextField(
          controller: _guardianName,
          decoration: InputDecoration(labelText: 'Guardian Name'),
          enabled: isedit,
        ),
        TextField(
          controller: _guardianPhoneNo,
          decoration: InputDecoration(labelText: 'Guardian phone number'),
          enabled: isedit,
        ),
        TextField(
          controller: _height,
          decoration: InputDecoration(labelText: 'Height (in centimeters)'),
          enabled: isedit,
        ),
        TextField(
          controller: _weight,
          decoration: InputDecoration(labelText: 'Weight (in kilograms)'),
          enabled: isedit,
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
          onChanged: isedit == false
              ? null
              : (String? newvalue) {
                  setState(() {
                    selectedvalue = newvalue;
                  });
                },
        ),
        TextField(
            controller: _pastIll,
            decoration: InputDecoration(labelText: 'Past Illness'),
            enabled: isedit),
        TextField(
          controller: _preSurgs,
          decoration: InputDecoration(labelText: 'Previous Surgeries'),
          enabled: isedit,
        ),
        TextField(
          controller: _ongMeds,
          decoration: InputDecoration(labelText: 'Ongoing medicines'),
          enabled: isedit,
        ),
        TextField(
          controller: _allgs,
          decoration: InputDecoration(labelText: 'Allergies'),
          enabled: isedit,
        ),
        ElevatedButton(
          onPressed: isedit == false ? null : () => save(),
          child: Text("Save"),
        ),
        ElevatedButton(
            onPressed: () {
              setState(() {
                isedit = true;
              });
            },
            child: Text('Edit'))
      ]),
    );
  }
}
