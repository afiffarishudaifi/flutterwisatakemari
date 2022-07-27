import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:here_sdk/core.dart';
import 'package:here_sdk/mapview.dart';
import 'package:here_sdk/routing.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'config/app.dart';

class RouteNavigation extends StatefulWidget {
  final double latitute;
  final double longitude;
  final int wisataId;
  final int wilayahWisata;
  final String namaWilayahWisata;
  const RouteNavigation({Key key, this.latitute, this.longitude, this.namaWilayahWisata, this.wilayahWisata, this.wisataId})
      : super(key: key);

  @override
  _RouteNavigationState createState() => _RouteNavigationState();
}

class _RouteNavigationState extends State<RouteNavigation> {
  HereMapController _controller;
  MapPolyline mapPolyline;

  List kategoris = [];
  List<Map<String, dynamic>> wilayahs = [];
  int selectedWilayah;
  String selectedWilayahString;
  bool collapseFilter = true;
  List<MapMarker> currentMarker = [];

  @override
  void initState() {
    super.initState();
    this.getKategori();
    this.getWilayah();
  }

  Future getKategori() async {
    Uri urlApi = Uri.https(Config().urlApi, '/public/api/kategori');

    return http.get(urlApi).then((http.Response response) {
      if (response.statusCode == 401) {
        // logout(context);
      } else {
        Map<String, dynamic> result = json.decode(response.body);
        result['data'].forEach((value) {
          bool checked = false;
          Map<String, dynamic> item = {
            'id': value['id_kategori'],
            'label': value['nama_kategori'],
            'checked': checked
          };
          return kategoris.add(item);
        });
        setState(() {});
      }
    });
  }

  Future<void> getWilayah() async {
    Uri urlApi = Uri.https(Config().urlApi, '/public/api/wilayah');

    http.get(urlApi).then((http.Response response) {
      if (response.statusCode == 401) {
        // logout(context);
      } else {
        Map<String, dynamic> result = json.decode(response.body);
        result['data'].forEach((value) {
          Map<String, dynamic> item = {
            'id': value['id'],
            'label': value['kabupaten'],
            'logo': value['gambar'],
            'icon_logo' : value['icon_logo']
          };
          return wilayahs.add(item);
        });
        setState(() {});
      }
    });
  }

  void _reset() {
    List<Map<String, dynamic>> kategoriNew = [];
    kategoris.forEach((element) {
      element['checked'] = false;
      kategoriNew.add(element);
    });

    setState(() {
      kategoris = kategoriNew;
      selectedWilayah = 0;
      selectedWilayahString = "";

    });
    this.filter();
  }

  getRoute(HereMapController hereMapController) async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
    ].request();
    if (await Permission.location.isGranted) {
      Position posisi = await Geolocator.getCurrentPosition();
      drawRoute(GeoCoordinates(posisi.latitude, posisi.longitude),
          GeoCoordinates(widget.latitute, widget.longitude), hereMapController);
    } else {      
    }
  }

  Future<void> drawRoute(GeoCoordinates start, GeoCoordinates end,
      HereMapController hereMapController) async {
    RoutingEngine routeEngine = RoutingEngine();

    Waypoint startWaypoint = Waypoint.withDefaults(start);
    Waypoint endWaypoint = Waypoint.withDefaults(end);

    List<Waypoint> wayPoints = [startWaypoint, endWaypoint];
    routeEngine.calculateCarRoute(wayPoints, CarOptions.withDefaults(),
        (RoutingError routingError, List<dynamic> routes) {
      if (routingError == null) {
        dynamic route = routes.first;

        GeoPolyline geoPolyline = GeoPolyline(route.polyline);
        mapPolyline = MapPolyline(geoPolyline, 20, Colors.blue);
        hereMapController.mapScene.addMapPolyline(mapPolyline);
        GeoBox routeGeoBox = route.boundingBox;
        hereMapController.camera.lookAtAreaWithOrientation(
            routeGeoBox, MapCameraOrientationUpdate.withDefaults());
        this.filter();
      }
    });

    ByteData fileData = await rootBundle.load('assets/images/marker_kecil.png');
    Uint8List pixelData = fileData.buffer.asUint8List();
    MapImage mapImage =
        MapImage.withPixelDataAndImageFormat(pixelData, ImageFormat.png);
    hereMapController.mapScene.addMapMarker(MapMarker(start, mapImage));
    hereMapController.mapScene.addMapMarker(MapMarker(end, mapImage));
  }

  _onMapCreated(HereMapController hereMapController) {
    _controller = hereMapController;
    hereMapController.mapScene.loadSceneForMapScheme(MapScheme.normalDay,
        (MapError mapError) {
      if (mapError != null) {
        print("error : " + mapError.toString());
        return;
      }
    });
    this.getRoute(hereMapController);
  }

  Future<void> filter() async{
    Map<String, dynamic> queryString = new Map<String, dynamic>();
    queryString['search'] = '';
    queryString['search_by'] = '';
    List queryKategori = [];
    kategoris.forEach((element) {
      if (element['checked']) {
        queryKategori.add(element['id'].toString());
      }
    });
    if (queryKategori.length > 0) {
      queryString['kategori-id_kategori[]'] = queryKategori;
    }
    queryString['id_rute_tujuan'] = widget.wilayahWisata.toString();
    queryString['rute_tujuan'] = widget.namaWilayahWisata;
    queryString['rute_melewati'] = selectedWilayahString;
    queryString['id_wisata'] = widget.wisataId.toString();

    Uri urlApi = Uri.https(Config().urlApi, '/api/rute_nonpaginate/search', queryString);
    currentMarker.forEach((MapMarker mapMarker) {
      _controller.mapScene.removeMapMarker(mapMarker);
    });
    setState(() {
      currentMarker = [];
    });

    http.get(urlApi).then((http.Response response) async{
      if (response.statusCode == 401) {
        // logout(context);
      } else {
        Map<String, dynamic> result = json.decode(response.body);
        ByteData fileData = await rootBundle.load('assets/images/marker_kecil.png');
        Uint8List pixelData = fileData.buffer.asUint8List();
        MapImage mapImage = MapImage.withPixelDataAndImageFormat(pixelData, ImageFormat.png);
        result['data']['data'].forEach((value) {
          currentMarker.add(MapMarker(GeoCoordinates(double.parse(value['latitude']), double.parse(value['longitude']) ), mapImage));
        });
        currentMarker.forEach((MapMarker mapMarker) {
          _controller.mapScene.addMapMarker(mapMarker);
        });
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black45,
        title: Image(
          image: AssetImage("assets/images/logo.png"),
          height: 45,
        ),
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(top: 70),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Filters",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            IconButton(
                                icon: Icon(Icons.filter_alt_outlined),
                                onPressed: () {
                                  setState(() {
                                    collapseFilter = !collapseFilter;
                                  });
                                }),
                          ],
                        ),
                        Divider(
                          color: Colors.grey[300],
                        ),
                        (collapseFilter)
                            ? Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Melewati Wilayah",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600)),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 5),
                                      child: DropdownButtonFormField(
                                        decoration: InputDecoration(
                                          hintText: 'Kemana?',
                                          filled: true,
                                          fillColor: Colors.white,
                                          border: new OutlineInputBorder(
                                            borderSide: BorderSide.none,
                                            borderRadius: const BorderRadius.all(
                                              const Radius.circular(10.0),
                                            ),
                                          ),
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 10),
                                        ),
                                        items: wilayahs.map((dynamic item) {
                                          return DropdownMenuItem(
                                            value: item['id'].toString() +
                                                '::' +
                                                item['label'] +
                                                '::' +
                                                item['logo'] +
                                                '::' +
                                                item['icon_logo'],
                                            child: Text((item['id'] == 0)
                                                ? "Semua Wilayah"
                                                : item['label']),
                                          );
                                        }).toList(),
                                        onChanged: (value) {
                                          List<String> newValue =
                                              value.split("::");
                                          setState(() {
                                            selectedWilayah =
                                                int.parse(newValue[0]);
                                                selectedWilayahString = newValue[1];
                                          });
                                        },
                                      ),
                                    ),
                                    Divider(
                                      color: Colors.grey[300],
                                    ),
                                    Text("Kategori",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600)),
                                    MediaQuery.removePadding(
                                      context: context,
                                      removeTop: true,
                                      child: ListView.builder(
                                          itemCount: kategoris.length,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemBuilder: (context, index) {
                                            return Row(
                                              children: [
                                                Checkbox(
                                                  checkColor: Colors.white,
                                                  activeColor: Colors.red,
                                                  value: kategoris[index]
                                                      ['checked'],
                                                  onChanged: (bool value) {
                                                    setState(() {
                                                      kategoris[index]
                                                              ['checked'] =
                                                          !kategoris[index]
                                                              ['checked'];
                                                    });
                                                  },
                                                ),
                                                Text(kategoris[index]['label'])
                                              ],
                                            );
                                          }),
                                    ),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.refresh),
                                              Text(
                                                "Reset",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ],
                                          ),
                                          onPressed: () {
                                            this._reset();
                                          },
                                          style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty.all<
                                                      Color>(Colors.red[300]),
                                              shape: MaterialStateProperty.all<
                                                      RoundedRectangleBorder>(
                                                  RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5.0),
                                              )))),
                                    ),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.filter_alt_outlined),
                                              Text(
                                                "Filter",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ],
                                          ),
                                          onPressed: (){
                                            this.filter();
                                          },
                                          style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty.all<
                                                      Color>(Colors.blue),
                                              shape: MaterialStateProperty.all<
                                                      RoundedRectangleBorder>(
                                                  RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5.0),
                                              )))),
                                    ),
                                  ],
                                ),
                              )
                            : Container(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 600,
              child: HereMap(
                onMapCreated: _onMapCreated,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
