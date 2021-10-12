import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:vehicles_app/models/response.dart';

class DisplayPictureScreen extends StatefulWidget {
  final XFile image;

  DisplayPictureScreen({required this.image});
  @override
  _DisplayPictureScreenState createState() => _DisplayPictureScreenState();
}

class _DisplayPictureScreenState extends State<DisplayPictureScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vista previa de la foto'),
      ),
      body: Column(
        children: [
          Image.file(
            File(widget.image.path),
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.cover,
          ),
          Container(
            margin: EdgeInsets.all(10),
            child: Row(
              children: <Widget>[
                Expanded(
                    child: ElevatedButton(
                        style: ButtonStyle(backgroundColor:
                            MaterialStateProperty.resolveWith<Color>(
                                (Set<MaterialState> states) {
                          return Colors.blue;
                        })),
                        onPressed: () {
                          Response response =
                              Response(isSuccess: true, result: widget.image);
                          Navigator.pop(context, response);
                        },
                        child: Text("Usar foto"))),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                    child: ElevatedButton(
                        style: ButtonStyle(backgroundColor:
                            MaterialStateProperty.resolveWith<Color>(
                                (Set<MaterialState> states) {
                          return Colors.red;
                        })),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text("Volver a tomar")))
              ],
            ),
          )
        ],
      ),
    );
  }
}
