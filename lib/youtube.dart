import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'config/app.dart';

class Youtube extends StatefulWidget {
  const Youtube({Key key}) : super(key: key);

  @override
  _YoutubeState createState() => _YoutubeState();
}

class _YoutubeState extends State<Youtube> {
  List dataVideo = [];
  int currentPage = 1;
  int totalPage = 1;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    this.getDataVideo();
  }

  Future<void> getDataVideo() async {
    setState(() {
      loading = true;
    });
    Map<String, dynamic> queryString = new Map<String, dynamic>();
    queryString['page'] = currentPage.toString();

    Uri urlApi =
        Uri.https(Config().urlApi, '/public/api/video_360', queryString);

    http.get(urlApi).then((http.Response response) {
      if (response.statusCode == 401) {
        // logout(context);
      } else {
        Map<String, dynamic> result = json.decode(response.body);
        if (result['data']['paginate']['data'].length > 0) {
          result['data']['paginate']['data'].forEach((element) {
            dataVideo.add(element);
          });
        }
        setState(() {
          currentPage = result['data']['paginate']['current_page'] + 1;
          totalPage = result['data']['paginate']['last_page'];
          loading = false;
        });
      }
    }).onError((error, stackTrace) {});
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
                    image: NetworkImage(
                        "https://wisatakemari.com/public/images/bg/bg-1.jpg"),
                    colorFilter: new ColorFilter.mode(
                        Colors.black.withOpacity(0.3), BlendMode.dstATop),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("VIDEO 360",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: dataVideo.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: GestureDetector(
                            onTap: () async {
                              if (await canLaunch(dataVideo[index]['url'])) {
                                await launch(
                                  dataVideo[index]['url'],
                                  universalLinksOnly: true,
                                );
                              } else {
                                throw 'Could not launch ' +
                                    dataVideo[index]['url'];
                              }
                            },
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Image(
                                  image:
                                      AssetImage('assets/images/youtube.png'),
                                  height: 30,
                                ),
                                Flexible(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 4),
                                    child: Text(dataVideo[index]['nama_wisata'],
                                      softWrap: true,
                                        style: TextStyle(
                                          fontSize: 20,
                                        )),
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      }),
                ),
              ),
              (loading)
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                          alignment: Alignment.center,
                          child: CircularProgressIndicator()),
                    )
                  : Container(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    child: Text(
                      "Load More",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      this.getDataVideo();
                    },
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.red[300]),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        )))),
              ),
            ]),
      )),
    );
  }
}
