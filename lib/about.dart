import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'config/app.dart';
import 'package:html/parser.dart';

class About extends StatefulWidget {
  const About(
      {Key key})
      : super(key: key);

  @override
  _AboutState createState() => _AboutState();
}

class _AboutState extends State<About> {
  String tentangKami = "";
  bool loading = true;
  @override
  void initState() {
    super.initState();
    this.getTentangKami();
  }

  String _parseHtmlString(String htmlString) {
    final document = parse(htmlString);
    final String parsedString = parse(document.body.text).documentElement.text;

    return parsedString;
  }

  Future<void> getTentangKami() async{

    Uri urlApi = Uri.https(Config().urlApi, '/public/api/about');

    http.get(urlApi).then((http.Response response) {
      if (response.statusCode == 401) {
        // logout(context);
      } else {
        Map<String, dynamic> result = json.decode(response.body);
        setState(() {
          tentangKami = result['data'];
          loading = false;
        });
      }
    }).onError((error, stackTrace) {
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Image(
          image: AssetImage("assets/images/logo.png"),
          height: 45,
        ),
        backgroundColor: Colors.transparent,
        elevation: 1,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
          child: Container(
        color: Colors.grey[300],
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black87,
                  image: DecorationImage(
                    image: NetworkImage("https://wisatakemari.com/public/images/bg/bg-1.jpg"),
                    colorFilter: new ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.dstATop),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("TENTANG KAMI", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 25),
                child: Align(
                  alignment: Alignment.center,
                  child: Text("WISATA KEMARI", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold))),
              ),
              (loading) ? 
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.center,
                  child: CircularProgressIndicator()),
              ) : Container(),
              Text(_parseHtmlString(tentangKami)),
            ]),
      )),
    );
  }
}
