// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:vehicles_app/models/token.dart';
import 'package:vehicles_app/screen/login_screen.dart';

class HomeScreen extends StatefulWidget {
  final Token token;

  HomeScreen({required this.token});
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vehicles'),
      ),
      body: _getBody(),
      drawer: _getMechanicMenu(),
    );
  }

  Widget _getBody() {
    return Container(
      margin: EdgeInsets.all(30),
      child: Center(
        child: Text(
          'Bienvenid@ ${widget.token.user.fullname}',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _getMechanicMenu() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
              child: Image(
            image: AssetImage('assets/images.jpg'),
          )),
          ListTile(
              leading: Icon(Icons.two_wheeler),
              title: const Text("Marcas"),
              onTap: () {}),
          ListTile(
              leading: Icon(Icons.precision_manufacturing),
              title: Text("Procedimientos"),
              onTap: () {}),
          ListTile(
              leading: Icon(Icons.badge),
              title: Text("Tipos de documento"),
              onTap: () {}),
          ListTile(
              leading: Icon(Icons.toys),
              title: Text("Tipos de vehiculos"),
              onTap: () {}),
          ListTile(
              leading: Icon(Icons.people),
              title: Text("Usuario"),
              onTap: () {}),
          Divider(color: Colors.black, height: 3),
          ListTile(
              leading: Icon(Icons.face),
              title: Text("Editar perfil"),
              onTap: () {}),
          ListTile(
              leading: Icon(Icons.logout),
              title: Text("Cerrar Sesión"),
              onTap: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => LoginScreen()));
              }),
        ],
      ),
    );
  }
}
