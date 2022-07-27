import 'package:flutter/material.dart';
import 'dart:core';
import 'package:html/parser.dart';

class ItemObjekPopuler extends StatefulWidget {
  final dynamic data;
  final ValueSetter<dynamic> onTap;
  const ItemObjekPopuler({Key key, this.data, this.onTap}) : super(key: key);

  @override
  _ItemObjekPopulerState createState() => _ItemObjekPopulerState();
}

class _ItemObjekPopulerState extends State<ItemObjekPopuler> {
  String _parseHtmlString(String htmlString) {
    final document = parse(htmlString);
    final String parsedString = parse(document.body.text).documentElement.text;

    return parsedString;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        widget.onTap(widget.data);
      },
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            (widget.data['url_gambar']!=null) ?
            Image.network(widget.data['url_gambar'])
            : Container(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(widget.data['nama'],
                  softWrap: true,
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  )),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: (_parseHtmlString(widget.data['deskripsi']).length >= 100)
                  ? Text(_parseHtmlString(widget.data['deskripsi'])
                      .substring(0, 100))
                  : Text(_parseHtmlString(widget.data['deskripsi'])),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Icon(Icons.place, color: Colors.grey,),
                  Text(widget.data['wilayah']),
                ],
              ),
            ),
            Divider(),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(widget.data['dilihat']+" Dilihat"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
