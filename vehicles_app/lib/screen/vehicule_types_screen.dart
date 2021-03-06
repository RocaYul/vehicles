import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:vehicles_app/components/loader_component.dart';
import 'package:vehicles_app/helpers/api_helper.dart';
import 'package:vehicles_app/models/response.dart';
import 'package:vehicles_app/models/token.dart';
import 'package:vehicles_app/models/vehicle_type.dart';
import 'package:vehicles_app/screen/vehicule_type__screen.dart';

class VehiculeTypesScreen extends StatefulWidget {
  final Token token;

  VehiculeTypesScreen({required this.token});

  @override
  _VehiculeTypesScreenState createState() => _VehiculeTypesScreenState();
}

class _VehiculeTypesScreenState extends State<VehiculeTypesScreen> {
  List<VehicleType> _vehicleTypes = [];
  bool _showLoader = false;
  bool _isFiltered = false;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _getVehicleTypes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tipos de vehiculo'),
        actions: <Widget>[
          _isFiltered
              ? IconButton(
                  onPressed: _removeFilter, icon: Icon(Icons.filter_none))
              : IconButton(onPressed: _showFilter, icon: Icon(Icons.filter_alt))
        ],
      ),
      body: Center(
        child: _showLoader
            ? LoaderComponent(text: 'Por favor espere...')
            : _getContent(),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _goAdd(),
      ),
    );
  }

  Future<Null> _getVehicleTypes() async {
    setState(() {
      _showLoader = true;
    });
    Response response = await ApiHelper.getVehiculeTypes(widget.token.token);
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
      _vehicleTypes = response.result;
    });
  }

  Widget _getContent() {
    return _vehicleTypes.length == 0 ? _noContent() : _getListView();
  }

  Widget _noContent() {
    return Center(
      child: Container(
        margin: EdgeInsets.all(20),
        child: Text(
          _isFiltered
              ? 'No hay tipos de vehiculo con ese criterio de b??squeda.'
              : 'No hay tipos de vehiculo registrados.',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _getListView() {
    return RefreshIndicator(
      onRefresh: _getVehicleTypes,
      child: ListView(
        children: _vehicleTypes.map((e) {
          return Card(
            child: InkWell(
              onTap: () => _goEdit(e),
              child: Container(
                margin: EdgeInsets.all(10),
                padding: EdgeInsets.all(5),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          e.description,
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showFilter() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            title: Text('Filtrar Tipos de Vehiculo'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('Escriba las primeras letras del tipo de vehiculo'),
                SizedBox(
                  height: 10,
                ),
                TextField(
                  autofocus: true,
                  decoration: InputDecoration(
                      hintText: 'Criterio de b??squeda...',
                      labelText: 'Buscar',
                      suffixIcon: Icon(Icons.search)),
                  onChanged: (value) {
                    _search = value;
                  },
                )
              ],
            ),
            actions: <Widget>[
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancelar')),
              TextButton(onPressed: () => _filter(), child: Text('Filtrar')),
            ],
          );
        });
  }

  void _removeFilter() {
    setState(() {
      _isFiltered = false;
    });
    _getVehicleTypes();
  }

  void _filter() {
    if (_search.isEmpty) {
      return;
    }

    List<VehicleType> filteredList = [];
    for (var documentType in _vehicleTypes) {
      if (documentType.description
          .toLowerCase()
          .contains(_search.toLowerCase())) {
        filteredList.add(documentType);
      }
    }

    setState(() {
      _vehicleTypes = filteredList;
      _isFiltered = true;
    });

    Navigator.of(context).pop();
  }

  void _goAdd() async {
    String? result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => VehiculeTypeScreen(
                  token: widget.token,
                  vehiculeType: VehicleType(description: '', id: 0),
                )));
    if (result == 'yes') {
      _getVehicleTypes();
    }
  }

  void _goEdit(VehicleType vehicleType) async {
    String? result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => VehiculeTypeScreen(
                  token: widget.token,
                  vehiculeType: vehicleType,
                )));
    if (result == 'yes') {
      _getVehicleTypes();
    }
  }
}
