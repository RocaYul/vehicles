import 'document_type.dart';

class User {
  String firstName = " ";
  String lastName = " ";
  DocumentType documentType = DocumentType(id: 0, description: '');
  String document = " ";
  String address = " ";
  String imageId = " ";
  String imageFullPath = " ";
  int userType = 0;
  String fullname = " ";
  int vehiclesCount = 0;
  String id = " ";
  String userName = " ";
  String email = " ";
  String phoneNumber = " ";

  User({
    required this.firstName,
    required this.lastName,
    required this.documentType,
    required this.document,
    required this.address,
    required this.imageId,
    required this.imageFullPath,
    required this.userType,
    required this.fullname,
    required this.vehiclesCount,
    required this.id,
    required this.userName,
    required this.email,
    required this.phoneNumber,
  });

  User.fromJson(Map<String, dynamic> json) {
    firstName = json['firstName'];
    lastName = json['lastName'];
    documentType = DocumentType.fromJson(json['documentType']);
    document = json['document'];
    address = json['address'];
    imageId = json['imageId'];
    imageFullPath = json['imageFullPath'];
    userType = json['userType'];
    fullname = json['fullname'];
    id = json['id'];
    userName = json['userName'];
    email = json['email'];
    phoneNumber = json['phoneNumber'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['firstName'] = this.firstName;
    data['lastName'] = this.lastName;
    data['document'] = this.documentType.toJson();
    data['address'] = this.address;
    data['imageId'] = this.imageId;
    data['imageFullPath'] = this.imageFullPath;
    data['userType'] = this.userType;
    data['fullname'] = this.fullname;
    data['vehiclesCount'] = this.vehiclesCount;
    data['id'] = this.id;
    data['userName'] = this.userName;
    data['email'] = this.email;
    data['phoneNumber'] = this.phoneNumber;
    return data;
  }
}
