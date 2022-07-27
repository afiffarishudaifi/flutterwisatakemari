import 'package:flutter/material.dart';
import 'dart:core';
import 'package:html/parser.dart';

class ItemObjek extends StatefulWidget {
  final dynamic data;
  final ValueSetter<dynamic> onTap;
  const ItemObjek({Key key, this.data, this.onTap}) : super(key: key);

  @override
  _ItemObjekState createState() => _ItemObjekState();
}

class _ItemObjekState extends State<ItemObjek> {
  String _parseHtmlString(String htmlString) {
    final document = parse(htmlString);
    final String parsedString = parse(document.body.text).documentElement.text;

    return parsedString;
  }

  @override
  Widget build(BuildContext context) {
    List<Icon> rating = [];
    for(int i=1; i <= 5; i++){
      if(widget.data['rating'].floor()>=i){
        rating.add(Icon(Icons.star, color: Colors.yellow[700], size: 18,));
      }else{
        rating.add(Icon(Icons.star, size: 18));
      }
    }
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
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
              child: Row(
                children: [
                  Icon(Icons.place, color: Colors.grey,),
                  Text(widget.data['wilayah']['kabupaten']),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
              child: Row(
                children: [
                  Icon(Icons.category, color: Colors.grey,),
                  Text(widget.data['kategori']['nama_kategori']),
                ],
              ),
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.remove_red_eye, color: Colors.grey,),
                      Text(widget.data['number'].toString()+" Dilihat", style: TextStyle(fontWeight: FontWeight.bold),)
                    ],
                  ),
                  Row(
                    children: [
                      Column(
                        children: [
                          Row(
                            children: rating,
                          ),
                          (widget.data['rating'].floor()>=4) ? Text("Sangat Baik") : Text("Baik")
                        ],
                      ),
                      Container(
                        color: Colors.blue,
                        padding:const EdgeInsets.all(8),
                        child: Text(widget.data['rating'].toString(), style: TextStyle(color: Colors.white),),
                      )
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
            )
          ],
        ),
      ),
    );
  }
}
