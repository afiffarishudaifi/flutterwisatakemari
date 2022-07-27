import 'package:flutter/material.dart';

class ListWilayah extends StatefulWidget {
  final dynamic item;
  final ValueSetter<dynamic> onTap;
  const ListWilayah({Key key, this.item, this.onTap}) : super(key: key);

  @override
  _ListWilayahState createState() => _ListWilayahState();
}

class _ListWilayahState extends State<ListWilayah> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        widget.onTap(widget.item);
      },
      child: Stack(
          textDirection: TextDirection.rtl,
          fit: StackFit.loose,
          clipBehavior: Clip.hardEdge,
          children: [
            Container(
              height: 220,
              width: double.infinity,
              child: (widget.item['url_gambar'] != null)
                  ? FittedBox(
                      child: Image.network(
                            widget.item['url_gambar']
                          ),
                      fit: BoxFit.fill,
                    )
                  : Container(),
            ),
            Container(
              height: 220,
              width: double.infinity,
              alignment: Alignment.bottomCenter,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    Colors.grey.withOpacity(0.0),
                    Colors.black,
                  ],
                  stops: [0.0, 0.9],
                ),
              ),
            ),
            Container(
              height: 220,
              width: double.infinity,
              alignment: Alignment.bottomLeft,
              child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.white, size: 12),
                          Icon(Icons.star, color: Colors.white, size: 12),
                          Icon(Icons.star, color: Colors.white, size: 12),
                          Icon(Icons.star, color: Colors.white, size: 12),
                        ],
                      ),
                      Text(
                        widget.item['nama'],
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                      ),
                    ],
                  )),
            ),
          ]),
    );
  }
}
