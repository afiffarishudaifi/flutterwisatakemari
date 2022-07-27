import 'package:flutter/material.dart';
import 'dart:core';
import 'package:html/parser.dart';

class PenawaranKamiItem extends StatefulWidget {
  final dynamic data;
  final ValueSetter<dynamic> onTap;
  const PenawaranKamiItem({Key key, this.data, this.onTap}) : super(key: key);

  @override
  _PenawaranKamiItemState createState() => _PenawaranKamiItemState();
}

class _PenawaranKamiItemState extends State<PenawaranKamiItem> {

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        widget.onTap(widget.data);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black87,
              image: DecorationImage(
                image: NetworkImage(widget.data['url_gambar']),
                fit: BoxFit.cover,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  color: Colors.yellow[600],
                  width: 80,
                  height: 80,
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(widget.data['rating'].toString(), style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold))),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Text(widget.data['nama_kategori']+" - "+widget.data['kabupaten'], style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold),),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20, top: 5),
            child: Text(widget.data['nama'], style: TextStyle(fontSize: 20, ),),
          )
        ],
      ),
    );
  }
}
