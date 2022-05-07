import 'package:firebase_database/firebase_database.dart';

class Users {
  final String? id;
  final String? address;
  final String? name;
  final String? email;
  final String? lastName;
  final String? phone;
  final String? photoURL;
  final String? carBrand;
  final String? carModel;
  final String? carNumber;
  final String? carType;

  Users(
      {this.id,
      this.address,
      this.name,
      this.email,
      this.lastName,
      this.phone,
      this.photoURL,
      this.carBrand,
      this.carModel,
      this.carNumber,
      this.carType});

  factory Users.fromSnapshot(DataSnapshot dataSnapshot) {
    return Users(
      id: dataSnapshot.key,
      address: (dataSnapshot.value as dynamic)["address"],
      name: (dataSnapshot.value as dynamic)["name"],
      email: (dataSnapshot.value as dynamic)["email"],
      lastName: (dataSnapshot.value as dynamic)["lastName"],
      phone: (dataSnapshot.value as dynamic)["phone"],
      photoURL: (dataSnapshot.value as dynamic)["photoURL"],
      carBrand: (dataSnapshot.value as dynamic)["carBrand"],
      carModel: (dataSnapshot.value as dynamic)["carModel"],
      carNumber: (dataSnapshot.value as dynamic)["carNumber"],
      carType: (dataSnapshot.value as dynamic)["carType"],
    );
  }

  // factory Users.fromDocument(DatabaseReference doc) {
  //   return Users(
  //     id: doc.id,
  //     address: doc['address'],
  //     name: doc['name'],
  //     email: doc['email'],
  //     lastName: doc['lastName'],
  //     phone: doc['phone'],
  //     photoURL: doc['photoURL'],
  //     carBrand: doc['carBrand'],
  //     carModel: doc['carModel'],
  //     carNumber: doc['carNumber'],
  //     carType: doc['carType'],
  //   );
  // }
}
