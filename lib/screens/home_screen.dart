import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_authentication/screens/add_car_screen.dart';
import 'package:flutter_authentication/service/database.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _ownerNameController = new TextEditingController();
  final TextEditingController _phoneNumberController = new TextEditingController();
  final TextEditingController _licensePlateController = new TextEditingController();
  final TextEditingController _periodOfITPController = new TextEditingController();
  final TextEditingController _dateController = new TextEditingController();

  Stream? CarStream;

  getontheload() async {
    CarStream = await DatabaseMethods().getCarDetails();
    setState(() {
      CarStream = CarStream;
    });
  }

  @override
  void initState() {
    getontheload();
    super.initState();
  }

  Widget allCarDetails() {
    return StreamBuilder(
        stream: CarStream,
        builder: (context, AsyncSnapshot snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot ds = snapshot.data.docs[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 20.0),
                      child: Material(
                        elevation: 5.0,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.all(20.0),
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10)),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "Name : " + ds["ownerName"],
                                      style: const TextStyle(
                                          color: Color(0xFF9546C4),
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Spacer(),
                                    GestureDetector(
                                        onTap: () {
                                          _ownerNameController.text =
                                              ds["ownerName"];
                                          _phoneNumberController.text =
                                              ds["phoneNumber"];
                                          _licensePlateController.text =
                                              ds["licensePlate"];
                                          _periodOfITPController.text =
                                              ds["periodOfITP"];
                                          _dateController.text =
                                              ds["dateOfITP"];
                                          EditCarDetails(ds.id);
                                        },
                                        child: const Icon(
                                          Icons.edit,
                                          color: Color(0xFF5E61F4),
                                        )),
                                    const SizedBox(width: 5.0),
                                    GestureDetector(
                                      onTap: () async {
                                        await DatabaseMethods()
                                            .deleteCarDetails(ds.id);
                                      },
                                      child: const Icon(
                                        Icons.delete,
                                        color: Color(0xFF5E61F4),
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  "License Plate : ${ds["licensePlate"]}",
                                  style: const TextStyle(
                                      color: Color(0xFF9546C4),
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "Date : ${ds["dateOfITP"]}",
                                  style: const TextStyle(
                                      color: Color(0xFF9546C4),
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold),
                                )
                              ]),
                        ),
                      ),
                    );
                  },
                )
              : Container(
                  child: const CircularProgressIndicator(),
                );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              FirebaseAuth.instance.signOut().then((value) {
                Navigator.pushReplacementNamed(context, '/signin');
              });
            },
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFCB2B93),
              Color(0xFF9546C4),
              Color(0xFF5E61F4),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
        child: Column(children: [
          Expanded(child: allCarDetails()),
        ]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return const Car();
          }));
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future EditCarDetails(String id) => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Icon(Icons.cancel)),
                    const SizedBox(
                      width: 60.0,
                    ),
                    const Text(
                      "Edit",
                      style: TextStyle(
                          color: Color(0xFF9546C4),
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      "Car",
                      style: TextStyle(
                          color: Color(0xFFCB2B93),
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20.0,
                ),
                const Text(
                  "Owner Name",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                Container(
                  padding: const EdgeInsets.only(left: 10.0),
                  decoration: BoxDecoration(
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(10)),
                  child: TextField(
                    controller: _ownerNameController,
                    decoration: const InputDecoration(border: InputBorder.none),
                  ),
                ),
                const SizedBox(
                  height: 20.0,
                ),
                const Text(
                  "Phone Number",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                Container(
                  padding: const EdgeInsets.only(left: 10.0),
                  decoration: BoxDecoration(
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(10)),
                  child: TextField(
                    controller: _phoneNumberController,
                    decoration: const InputDecoration(border: InputBorder.none),
                  ),
                ),
                const SizedBox(
                  height: 20.0,
                ),
                const Text(
                  "License Plate Number",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                Container(
                  padding: const EdgeInsets.only(left: 10.0),
                  decoration: BoxDecoration(
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(10)),
                  child: TextField(
                    controller: _licensePlateController,
                    decoration: const InputDecoration(border: InputBorder.none),
                  ),
                ),
                const SizedBox(
                  height: 20.0,
                ),
                const Text(
                  "Period of ITP (months)",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                Container(
                  padding: const EdgeInsets.only(left: 10.0),
                  decoration: BoxDecoration(
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(10)),
                  child: TextField(
                    controller: _periodOfITPController,
                    decoration: const InputDecoration(border: InputBorder.none),
                  ),
                ),
                const SizedBox(
                  height: 20.0,
                ),
                const Text(
                  "Date of ITP",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                Container(
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(10)),
                  child: TextField(
                    controller: _dateController,
                    decoration: const InputDecoration(
                        filled: true,
                        prefixIcon: Icon(Icons.calendar_today),
                        enabledBorder:
                            OutlineInputBorder(borderSide: BorderSide.none),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(0xFF9546C4),
                          ),
                        )),
                    readOnly: true,
                    onTap: () {
                      _selectDate();
                    },
                  ),
                ),
                const SizedBox(
                  height: 30.0,
                ),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      Map<String, dynamic> updateInfo = {
                        "Id": id,
                        "ownerName": _ownerNameController.text,
                        "phoneNumber": _phoneNumberController.text,
                        "licensePlate": _licensePlateController.text,
                        "periodOfITP": _periodOfITPController.text,
                        "dateOfITP": _dateController.text
                      };
                      await DatabaseMethods()
                          .updateCarDetails(updateInfo, id)
                          .then((value) {
                        Navigator.pop(context);
                      });
                    },
                    child: const Text("Update"),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Future<void> _selectDate() async {
    DateTime? _picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (_picked != null) {
      setState(() {
        _dateController.text = _picked.toString().split(" ")[0];
      });
    }
  }
}
