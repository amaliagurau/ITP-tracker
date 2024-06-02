import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  //CREATE
  Future addCarDetails(Map<String, dynamic> carInfoMap, String id) async {
    return await FirebaseFirestore.instance
        .collection("Car")
        .doc(id)
        .set(carInfoMap);
  }

  //READ
  Future<Stream<QuerySnapshot>> getCarDetails() async {
    return await FirebaseFirestore.instance.collection("Car").snapshots();
  }

//UPDATE
  Future updateCarDetails(Map<String, dynamic> updateInfo, String id) async {
    return await FirebaseFirestore.instance
        .collection("Car")
        .doc(id)
        .update(updateInfo);
  }

//DELETE
  Future deleteCarDetails(String id) async {
    return await FirebaseFirestore.instance.collection("Car").doc(id).delete();
  }
}
