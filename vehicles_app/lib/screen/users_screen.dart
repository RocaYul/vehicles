import 'package:flutter/material.dart';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:vehicles_app/components/loader_component.dart';
import 'package:vehicles_app/helpers/api_helper.dart';
import 'package:vehicles_app/models/document_type.dart';
import 'package:vehicles_app/models/response.dart';
import 'package:vehicles_app/models/token.dart';
import 'package:vehicles_app/models/user.dart';
import 'package:vehicles_app/screen/user_screen.dart';

class UsersScreen extends StatefulWidget {
  final Token token;

  UsersScreen({required this.token});
  @override
  _UsersScreenState createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  List<User> _users = [];
  bool _showLoader = false;
  String _search = '';
  bool _isFilter = false;

  @override
  void initState() {
    super.initState();
    _getUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Usuarios"),
        actions: <Widget>[
          _isFilter
              ? IconButton(
                  onPressed: _removeFilter, icon: Icon(Icons.filter_none))
              : IconButton(onPressed: _showFilter, icon: Icon(Icons.filter_alt))
        ],
      ),
      body: Center(
        child: _showLoader
            ? LoaderComponent(
                text: 'Por favor espere ...',
              )
            : _getContent(),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _goAdd(),
      ),
    );
  }

  Future<Null> _getUsers() async {
    setState(() {
      _showLoader = true;
    });
    Response response = await ApiHelper.getUsers(widget.token.token);
    setState(() {
      _showLoader = false;
    });

    if (!response.isSuccess) {
      await showAlertDialog(
          context: context,
          title: 'Error',
          message: response.message,
          actions: <AlertDialogAction>[
            AlertDialogAction(key: null, label: 'Aceptar')
          ]);
      return;
    }

    setState(() {
      _users = response.result;
    });
  }

  Widget _getContent() {
    return _users.length == 0 ? _noContent() : _getListView();
  }

  Widget _getListView() {
    return RefreshIndicator(
      onRefresh: _getUsers,
      child: ListView(
        children: _users.map((e) {
          return Card(
            child: InkWell(
                onTap: () => _goEdit(e),
                child: Container(
                  margin: EdgeInsets.all(10),
                  padding: EdgeInsets.all(10),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(40),
                        child: FadeInImage(
                          placeholder: AssetImage('assets/images.jpg'),
                          image: NetworkImage(e.imageFullPath),
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    e.fullName,
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    e.email,
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    e.phoneNumber,
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios)
                    ],
                  ),
                )),
          );
        }).toList(),
      ),
    );
  }

  Widget _noContent() {
    return Container(
      margin: EdgeInsets.all(20),
      child: Center(
        child: Text(
          _isFilter
              ? 'NO hay usuarios con ese criterio de busqueda'
              : "No hay usuarios almacenados.",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _showFilter() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            title: Text('Filtrar usuarios'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('Escriba el usuario con las primeras letras'),
                SizedBox(
                  height: 10,
                ),
                TextField(
                  autofocus: true,
                  decoration: InputDecoration(
                      hintText: 'Criterio de busqueda',
                      labelText: 'Buscar',
                      suffixIcon: Icon(Icons.search)),
                  onChanged: (value) {
                    setState(() {
                      _search = value;
                    });
                  },
                )
              ],
            ),
            actions: <Widget>[
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancelar')),
              TextButton(onPressed: () => _filter(), child: Text('Filtrar'))
            ],
          );
        });
  }

  void _removeFilter() {
    setState(() {
      _isFilter = false;
    });
    _getUsers();
  }

  void _filter() {
    if (_search.isEmpty) {
      return;
    }

    List<User> filteredList = [];
    for (var user in _users) {
      if (user.fullName.toLowerCase().contains(_search)) {
        filteredList.add(user);
      }
    }

    setState(() {
      _users = filteredList;
      _isFilter = true;
    });

    Navigator.of(context).pop();
  }

  void _goAdd() async {
    String? result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => UserScreen(
              token: widget.token,
              user: User(
                  firstName: '',
                  lastName: '',
                  documentType: DocumentType(id: 0, description: ''),
                  document: '',
                  address: '',
                  imageId: '',
                  imageFullPath: '',
                  userType: 1,
                  fullName: '',
                  vehicles: [],
                  vehiclesCount: 0,
                  id: '',
                  userName: '',
                  email: '',
                  phoneNumber: ''))),
    );
    if (result == 'yes') {
      _getUsers();
    }
  }

  void _goEdit(User user) async {
    String? result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => UserScreen(token: widget.token, user: user)));
    if (result == 'yes') {
      _getUsers();
    }
  }
}
