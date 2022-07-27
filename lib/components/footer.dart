import 'package:flutter/material.dart';

class Footer extends StatelessWidget {
  const Footer({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.only(top: 30, left: 8, right: 8, bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Copyright © wisatakemari.com",
                style: TextStyle(color: Colors.white70, fontSize: 16)),
            Row(
              children: [
                Text("Supported by ",
                    style: TextStyle(color: Colors.white70, fontSize: 16)),
                Image(
                  image: AssetImage('assets/images/logobiputih.png'),
                  color: Colors.white70,
                  height: 40,
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
