// ignore_for_file: prefer_const_constructors
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:vehicles_app/components/loader_component.dart';
import 'package:vehicles_app/helpers/api_helper.dart';
import 'package:vehicles_app/models/document_type.dart';
import 'package:vehicles_app/models/response.dart';
import 'package:vehicles_app/models/token.dart';
import 'package:vehicles_app/models/user.dart';
import 'package:vehicles_app/screen/take_picture_screen.dart';

class UserScreen extends StatefulWidget {
  final Token token;
  final User user;

  UserScreen({required this.token, required this.user});
  @override
  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  bool _showLoader = false;
  bool _photoChange = false;
  late XFile _image;

  String _firsName = "";
  String _firsNameError = "";
  bool _firsNameShowError = false;
  TextEditingController _firsNameController = TextEditingController();

  String _lastName = "";
  String _lastNameError = "";
  bool _lastNameShowError = false;
  TextEditingController _lastNameController = TextEditingController();

  int _documentTypeId = 0;
  String _documentTypeIdError = "";
  bool _documentTypeIdShowError = false;
  List<DocumentType> _documentTypes = [];

  String _document = '';
  String _documentError = '';
  bool _documentShowError = false;
  TextEditingController _documentController = TextEditingController();

  String _address = '';
  String _addressError = '';
  bool _addressShowError = false;
  TextEditingController _addressController = TextEditingController();

  String _email = '';
  String _emailError = '';
  bool _emailShowError = false;
  TextEditingController _emailController = TextEditingController();

  String _phoneNumber = '';
  String _phoneNumberError = '';
  bool _phoneNumberShowError = false;
  TextEditingController _phoneNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getDocumentTypes();
    _firsName = widget.user.firstName;
    _firsNameController.text = _firsName;

    _lastName = widget.user.lastName;
    _lastNameController.text = _lastName;

    _documentTypeId = widget.user.documentType.id;

    _document = widget.user.document;
    _documentController.text = _document;

    _address = widget.user.address;
    _addressController.text = _address;

    _email = widget.user.email;
    _emailController.text = _email;

    _phoneNumber = widget.user.phoneNumber;
    _phoneNumberController.text = _phoneNumber;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.user.id.isEmpty ? 'Nuevo usuario' : widget.user.fullName),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(children: <Widget>[
              _showPhoto(),
              _showFirstName(),
              _showLastName(),
              _showDocumentType(),
              _showDocument(),
              _showEmail(),
              _showAddress(),
              _showPhoneNumber(),
              _showButton()
            ]),
          ),
          _showLoader
              ? LoaderComponent(
                  text: 'Por favor espere ... ',
                )
              : Container()
        ],
      ),
    );
  }

  Widget _showFirstName() {
    return Container(
      padding: EdgeInsets.all(20),
      child: TextField(
        autofocus: true,
        controller: _firsNameController,
        decoration: InputDecoration(
            hintText: 'Ingresa nombre',
            labelText: 'Nombre',
            errorText: _firsNameShowError ? _firsNameError : null,
            suffixIcon: Icon(Icons.person),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
        onChanged: (value) {
          _firsName = value;
        },
      ),
    );
  }

  Widget _showButton() {
    return Container(
      margin: EdgeInsets.only(left: 10, right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Expanded(
              child: ElevatedButton(
                  style: ButtonStyle(backgroundColor:
                      MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                    return Color(0xFF00AC61);
                  })),
                  onPressed: () => _save(),
                  child: Text("Guardar"))),
          widget.user.id.isEmpty ? Container() : SizedBox(width: 20),
          widget.user.id.isEmpty
              ? Container()
              : Expanded(
                  child: ElevatedButton(
                      style: ButtonStyle(backgroundColor:
                          MaterialStateProperty.resolveWith<Color>(
                              (Set<MaterialState> states) {
                        return Color(0xFFB4161B);
                      })),
                      onPressed: () => _confirmDelete(),
                      child: Text("Borrar")))
        ],
      ),
    );
  }

  void _save() {
    if (!_validateFields()) {
      return;
    }
    widget.user.id.isEmpty ? _addRecord() : _saveRecord();
  }

  bool _validateFields() {
    bool isValid = true;

    if (_firsName.isEmpty) {
      isValid = false;
      _firsNameShowError = true;
      _firsNameError = 'Debes ingresar almenos un nombre';
    } else {
      _firsNameShowError = false;
    }

    if (_lastName.isEmpty) {
      isValid = false;
      _lastNameShowError = true;
      _lastNameError = 'Debes ingresar almenos un apellido';
    } else {
      _lastNameShowError = false;
    }

    if (_documentTypeId == 0) {
      isValid = false;
      _documentTypeIdShowError = true;
      _documentTypeIdError = 'Debes seleccionar el tipo de documento';
    } else {
      _documentTypeIdShowError = false;
    }

    if (_document.isEmpty) {
      isValid = false;
      _documentShowError = true;
      _documentError = 'Debes ingresar almenos un documento';
    } else {
      _documentShowError = false;
    }

    if (_email.isEmpty) {
      isValid = false;
      _emailShowError = true;
      _emailError = 'Debes ingresar un email';
    } else if (!EmailValidator.validate(_email)) {
      isValid = false;
      _emailShowError = true;
      _emailError = 'Debes ingresar un email valido';
    } else {
      _emailShowError = false;
    }

    if (_address.isEmpty) {
      isValid = false;
      _addressShowError = true;
      _addressError = 'Debes ingresar almenos una direccion';
    } else {
      _addressShowError = false;
    }

    if (_phoneNumber.isEmpty) {
      isValid = false;
      _phoneNumberShowError = true;
      _phoneNumberError = 'Debes ingresar almenos un numero de celular';
    } else {
      _phoneNumberShowError = false;
    }
    setState(() {});
    return isValid;
  }

  _addRecord() async {
    setState(() {
      _showLoader = true;
    });

    Map<String, dynamic> request = {
      'firsName': _firsName,
      'lastname': _lastName,
      'documentType': _documentTypeId,
      'document': _document,
      'email': _email,
      'username': _email,
      'address': _address,
      'phoneNumber': _phoneNumber
    };

    Response response =
        await ApiHelper.post('/api/Users/', request, widget.token.token);

    setState(() {
      _showLoader = false;
    });

    if (!response.isSuccess) {
      await showAlertDialog(
          context: context as BuildContext,
          title: 'Error',
          message: response.message,
          actions: <AlertDialogAction>[
            AlertDialogAction(key: null, label: 'Aceptar')
          ]);
      return;
    }

    Navigator.pop(context as BuildContext, 'yes');
  }

  _saveRecord() async {
    setState(() {
      _showLoader = true;
    });

    Map<String, dynamic> request = {
      'id': widget.user.id,
      'firsName': _firsName,
      'lastname': _lastName,
      'documentType': _documentTypeId,
      'document': _document,
      'email': _email,
      'username': _email,
      'address': _address,
      'phoneNumber': _phoneNumber
    };

    Response response = await ApiHelper.put(
        '/api/Users/', widget.user.id, request, widget.token.token);

    setState(() {
      _showLoader = false;
    });

    if (!response.isSuccess) {
      await showAlertDialog(
          context: context as BuildContext,
          title: 'Error',
          message: response.message,
          actions: <AlertDialogAction>[
            AlertDialogAction(key: null, label: 'Aceptar')
          ]);
      return;
    }

    Navigator.pop(context as BuildContext, 'yes');
  }

  void _confirmDelete() async {
    var response = await showAlertDialog(
        context: context as BuildContext,
        title: 'Confirmación',
        message: 'Estas seguro que quieres eliminar el registro',
        actions: <AlertDialogAction>[
          AlertDialogAction(key: 'no', label: 'No'),
          AlertDialogAction(key: 'yes', label: 'Si')
        ]);
    if (response == 'yes') {
      _deleteRecord();
    }
  }

  void _deleteRecord() async {
    setState(() {
      _showLoader = true;
    });

    Response response = await ApiHelper.delete(
        '/api/Users/', widget.user.id, widget.token.token);

    setState(() {
      _showLoader = false;
    });

    if (!response.isSuccess) {
      await showAlertDialog(
          context: context as BuildContext,
          title: 'Error',
          message: response.message,
          actions: <AlertDialogAction>[
            AlertDialogAction(key: null, label: 'Aceptar')
          ]);
      return;
    }
    Navigator.pop(context as BuildContext, 'yes');
  }

  Widget _showPhoto() {
    return InkWell(
      onTap: () => _takePicture(),
      child: Stack(children: <Widget>[
        Container(
          margin: EdgeInsets.only(top: 10),
          child: widget.user.id.isEmpty && !_photoChange
              ? Image(
                  image: AssetImage('assets/imagen.png'),
                  height: 160,
                  width: 160,
                  fit: BoxFit.cover,
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(80),
                  child: _photoChange
                      ? Image.file(File(_image.path),
                          height: 160, width: 160, fit: BoxFit.cover)
                      : FadeInImage(
                          placeholder: AssetImage('assets/images.jpg'),
                          image: NetworkImage(widget.user.imageFullPath),
                          width: 160,
                          height: 160,
                          fit: BoxFit.cover,
                        ),
                ),
        ),
        Positioned(
          bottom: 0,
          left: 100,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: Container(
              color: Colors.green[50],
              height: 60,
              width: 60,
              child: Icon(
                Icons.photo_camera,
                size: 50,
                color: Colors.blue,
              ),
            ),
          ),
        )
      ]),
    );
  }

  Widget _showLastName() {
    return Container(
      padding: EdgeInsets.all(20),
      child: TextField(
        autofocus: true,
        controller: _lastNameController,
        decoration: InputDecoration(
            hintText: 'Ingresa apellidos',
            labelText: 'Apellido',
            errorText: _lastNameShowError ? _lastNameError : null,
            suffixIcon: Icon(Icons.person),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
        onChanged: (value) {
          _firsName = value;
        },
      ),
    );
  }

  Widget _showDocument() {
    return Container(
      padding: EdgeInsets.all(20),
      child: TextField(
        autofocus: true,
        controller: _documentController,
        decoration: InputDecoration(
            hintText: 'Ingresa docuemnto',
            labelText: 'Documento',
            errorText: _documentShowError ? _documentError : null,
            suffixIcon: Icon(Icons.assignment_ind),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
        onChanged: (value) {
          _firsName = value;
        },
      ),
    );
  }

  Widget _showEmail() {
    return Container(
      padding: EdgeInsets.all(20),
      child: TextField(
        autofocus: true,
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
            hintText: 'Ingresa email',
            labelText: 'Email',
            errorText: _emailShowError ? _emailError : null,
            suffixIcon: Icon(Icons.email),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
        onChanged: (value) {
          _firsName = value;
        },
      ),
    );
  }

  Widget _showAddress() {
    return Container(
      padding: EdgeInsets.all(20),
      child: TextField(
        autofocus: true,
        controller: _addressController,
        keyboardType: TextInputType.streetAddress,
        decoration: InputDecoration(
            hintText: 'Ingresa direccion',
            labelText: 'Direccion',
            errorText: _addressShowError ? _addressError : null,
            suffixIcon: Icon(Icons.home),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
        onChanged: (value) {
          _firsName = value;
        },
      ),
    );
  }

  Widget _showPhoneNumber() {
    return Container(
      padding: EdgeInsets.all(20),
      child: TextField(
        autofocus: true,
        controller: _phoneNumberController,
        keyboardType: TextInputType.phone,
        decoration: InputDecoration(
            hintText: 'Ingresa telefono',
            labelText: 'Telefono',
            errorText: _phoneNumberShowError ? _phoneNumberError : null,
            suffixIcon: Icon(Icons.home),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
        onChanged: (value) {
          _firsName = value;
        },
      ),
    );
  }

  Future<Null> _getDocumentTypes() async {
    setState(() {
      _showLoader = true;
    });
    Response response = await ApiHelper.getDocumentTypes(widget.token.token);
    setState(() {
      _showLoader = false;
    });

    if (!response.isSuccess) {
      await showAlertDialog(
          context: context as BuildContext,
          title: 'Error',
          message: response.message,
          actions: <AlertDialogAction>[
            AlertDialogAction(key: null, label: 'Aceptar')
          ]);
      return;
    }
    setState(() {
      _documentTypes = response.result;
    });
  }

  Widget _showDocumentType() {
    return Container(
      padding: EdgeInsets.all(20),
      child: _documentTypes.length == 0
          ? Text('Cargando tipos de documentos...')
          : DropdownButtonFormField(
              items: _getComboDocumentTypes(),
              value: _documentTypeId,
              onChanged: (option) {
                setState(() {
                  _documentTypeId = option as int;
                });
              },
              decoration: InputDecoration(
                  hintText: 'Seleccione un tipo de documento',
                  labelText: 'Tipo de documento',
                  errorText:
                      _documentTypeIdShowError ? _documentTypeIdError : null,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)))),
    );
  }

  List<DropdownMenuItem<int>> _getComboDocumentTypes() {
    List<DropdownMenuItem<int>> list = [];
    list.add(DropdownMenuItem(
      child: Text('Seleccione un tipo de documento...'),
      value: 0,
    ));
    _documentTypes.forEach((documentType) {
      list.add(DropdownMenuItem(
          child: Text(documentType.description), value: documentType.id));
    });
    return list;
  }

  void _takePicture() async {
    WidgetsFlutterBinding.ensureInitialized();
    final cameras = await availableCameras();
    final fisrtCamera = cameras.first;
    Response? response = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TakePictureScreen(camera: fisrtCamera)));
    if (response != null) {
      setState(() {
        _photoChange = true;
        _image = response.result;
      });
    }
  }
}
