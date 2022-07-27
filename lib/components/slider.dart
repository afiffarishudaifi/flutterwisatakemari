import 'package:flutter/material.dart';
class SliderBanner extends StatefulWidget {
  final dynamic item;
  final ValueSetter<dynamic> onTap;
  final int index;
  const SliderBanner({ Key key, this.item, this.onTap, this.index }) : super(key: key);

  @override
  _SliderBannerState createState() => _SliderBannerState();
}

class _SliderBannerState extends State<SliderBanner> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 450,
      decoration: BoxDecoration(
        color: Colors.black87,
        image: DecorationImage(
          image: NetworkImage(
            widget.item['logo']
          ),
          colorFilter: new ColorFilter.mode(
              Colors.black.withOpacity(0.6), BlendMode.dstATop),
          fit: BoxFit.cover,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 15, left: 8, right: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 400,
                  width: double.infinity,
                  color: Colors.transparent
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 150, left: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      (widget.index>=1) ? 
                      Image(
                        image : NetworkImage('https://wisatakemari.com/public/images/wilayah/'+widget.item['icon_logo']),
                        height: 60,
                      ) : Container(),
                      Text(widget.item['label'],
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold)),
                      (widget.index>=1) ? 
                      ElevatedButton(
                          child: Text(
                            "Selengkapnya",
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            widget.onTap(widget.item);
                          },
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all<Color>(
                                      Colors.red[300]),
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(18.0),
                              )))) : Container(),
                      Padding(
                        padding: const EdgeInsets.only(top: 100),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(Icons.arrow_back, color: Colors.white),
                            Icon(Icons.slideshow, color: Colors.white),
                            Icon(Icons.arrow_forward, color: Colors.white),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}