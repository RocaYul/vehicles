// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:vehicles_app/components/loader_component.dart';
import 'package:vehicles_app/helpers/constanst.dart';
import 'package:http/http.dart' as http;
import 'package:vehicles_app/models/token.dart';
import 'package:vehicles_app/screen/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _email = "luis@yopmail.com";
  String _emailError = "";
  bool _emailShowError = false;
  String _password = "123456";
  String _passwordError = "";
  bool _passwordShowError = false;
  bool _remenber = true;
  bool _showpassword = false;

  bool _showLoader = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _showLogo(),
              _showEmail(),
              _showPassword(),
              _showRemenberme(),
              _showButtons()
            ],
          ),
          _showLoader
              ? LoaderComponent(
                  text: 'Por favor espere ...',
                )
              : Container(),
        ],
      ),
    );
  }

  Widget _showLogo() {
    return Image(
      image: AssetImage('assets/images.jpg'),
      width: 300,
    );
  }

  Widget _showEmail() {
    return Container(
      padding: EdgeInsets.all(20),
      child: TextField(
        autofocus: true,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
            suffixIcon: Icon(Icons.email),
            hintText: 'Ingresa tu email',
            labelText: 'Email',
            errorText: _emailShowError ? _emailError : null,
            prefixIcon: Icon(Icons.alternate_email),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
        onChanged: (value) {
          _email = value;
        },
      ),
    );
  }

  Widget _showPassword() {
    return Container(
      padding: EdgeInsets.all(20),
      child: TextField(
        obscureText: !_showpassword,
        decoration: InputDecoration(
            suffixIcon: IconButton(
                icon: _showpassword
                    ? Icon(Icons.visibility)
                    : Icon(Icons.visibility_off),
                onPressed: () {
                  setState(() {
                    _showpassword = !_showpassword;
                  });
                }),
            hintText: 'Ingresa tu contraseña',
            labelText: 'Contraseña',
            errorText: _passwordShowError ? _passwordError : null,
            prefixIcon: Icon(Icons.lock),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
        onChanged: (value) {
          _password = value;
        },
      ),
    );
  }

  Widget _showRemenberme() {
    return CheckboxListTile(
      title: Text('Recordarme'),
      value: _remenber,
      onChanged: (value) {
        setState(() {
          _remenber = value!;
        });
      },
    );
  }

  Widget _showButtons() {
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
                    return Colors.transparent;
                  })),
                  onPressed: () => _login(),
                  child: Text("Iniciar sesión"))),
          SizedBox(
            width: 20,
          ),
          Expanded(
              child: ElevatedButton(
                  style: ButtonStyle(backgroundColor:
                      MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                    return Colors.purple;
                  })),
                  onPressed: () {},
                  child: Text("Registrarse")))
        ],
      ),
    );
  }

  void _login() async {
    setState(() {
      _showpassword = false;
    });
    if (!_validateFields()) {
      return;
    }

    setState(() {
      _showLoader = true;
    });

    Map<String, dynamic> request = {
      'userName': _email,
      'password': _password,
    };

    var url = Uri.parse('${Constanst.apiUrl}/api/account/CreateToken');
    var response = await http.post(
      url,
      headers: {
        'content-type': 'application/json',
        'accept': 'application/json',
      },
      body: jsonEncode(request),
    );

    setState(() {
      _showLoader = false;
    });

    if (response.statusCode >= 400) {
      setState(() {
        _passwordShowError = true;
        _passwordError = "Email o contraseña incorrectos";
      });
      return;
    }

    var body = response.body;
    var decodedJson = jsonDecode(body);
    var token = Token.fromJson(decodedJson);
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => HomeScreen(token: token)));
  }

  bool _validateFields() {
    bool hasErrors = true;
    if (_email.isEmpty) {
      hasErrors = false;
      _emailShowError = true;
      _emailError = 'Debes ingresar tu email';
    } else if (!EmailValidator.validate(_email)) {
      hasErrors = false;
      _emailShowError = true;
      _emailError = 'Debes ingresar un email valido';
    } else {
      _emailShowError = false;
    }

    if (_password.isEmpty) {
      hasErrors = false;
      _passwordShowError = true;
      _passwordError = 'Debes ingresar tu contraseña';
    } else if (_password.length < 6) {
      hasErrors = false;
      _passwordShowError = true;
      _passwordError = 'Debes ingresar una coontraseña de almenos 6 caracteres';
    } else {
      _passwordShowError = false;
    }

    setState(() {});
    return hasErrors;
  }
}
