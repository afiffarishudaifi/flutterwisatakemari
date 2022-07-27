import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:latlong2/latlong.dart';
import 'package:wisatakemari/components/itemObjekMap.dart';
import 'package:wisatakemari/components/itemObjekPopuler.dart';
import 'package:wisatakemari/components/listWilayah.dart';
import 'package:wisatakemari/components/slider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wisatakemari/pencarian.dart';
import 'config/app.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:carousel_slider/carousel_slider.dart';

import 'detailObjek.dart';
import 'objekWisata.dart';

GoogleSignIn _googleSignIn = GoogleSignIn(
  // Optional clientId
  // clientId: '479882132969-9i9aqik3jfjd7qhci1nqf0bm2g71rm1u.apps.googleusercontent.com',
  scopes: <String>[
    'email',
  ],
);

class HomeContent extends StatefulWidget {
  final ValueSetter<double> onOpenDrawer;
  final double open;
  const HomeContent({key, this.onOpenDrawer, this.open}) : super(key: key);

  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent>{
  List<dynamic> populers = [
    {
      "id":29,
      "nama":"Grand Surya Hotel Kediri",
      "url_gambar":null,
      "deskripsi":"<p>Hotel simpel ini berjarak 13 menit berjalan kaki dari Taman Brantas, 5 km dari Kebun Bunga Matahari, dan 3 km dari Taman Wisata Tirtoyoso.</p>\r\n\r\n<p>Memiliki lantai keramik dan perabotan kayu, kamar-kamar simpel dilengkapi dengan Wi-Fi gratis, TV layar datar, serta fasilitas untuk membuat teh dan kopi. Suite memiliki area duduk.</p>\r\n\r\n<p>Sarapan dan minuman selamat datang gratis. Pilihan bersantap terdiri dari restoran, kafe, lounge koktail, dan bar jus. Fasilitas lainnya termasuk toko wine, kolam renang outdoor, dan gym. Ada juga spa, serta ruang pertemuan dan ruang acara.</p>",
      "dilihat" : "0",
      "wilayah" : "Kediri"
    }
  ];
  List kategoris = [];
  List<Map<String, dynamic>> wilayahs = [{
    "id" : 0,
    "label" : "SELAMAT DATANG DI WISATA KEMARI",
    "logo" : "https://wisatakemari.com/public/images/bg/bg-mobile-1.jpg",
    "icon_logo" : "logoputih.png"
  },
  ];
  List<Map<String, dynamic>> wilayahsKabupaten = [
    {
      "id" : 0,
      "label" : "Kota / Kabupaten",
      "logo" : "https://wisatakemari.com/public/images/bg/bg-2.jpg",
      "icon_logo" : "logoputih.png"
    }
  ];
  int selectedKategori = 0;
  String selectedKategoriString = "";
  int selectedWilayah = 0;
  String valueWilayahString = "";
  String iconWilayah = "";
  String gambarWilayah = "";
  int openDrawer = 0;
  int selectedSlide = 0;
  bool isLogin = false;
  String nama = "";
  TextEditingController searchController = TextEditingController();
  int showMap = 0;
  LatLng mapCenter = LatLng(-7.812919, 112.014614);
  List<Marker> markers;
  bool isLoading;
  MapController mapControoler;
  List<dynamic> objeksAll;

  String errorLogin = "";

  @override
  void initState() {
    super.initState();
    markers = [];
    objeksAll = [];
    this.getKategori();
    this.getWilayah();
    this.getPopuler();
    this.getObjekAll();
    Firebase.initializeApp().whenComplete(() {
      this.checkLogin();
    });
  }

  dispose() {
    super.dispose();
  }

  Future<void> checkLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (await prefs.containsKey('id_user')) {
      setState(() {
        isLogin = true;
        nama = prefs.getString("nama");
      });
    }
  }

  Future<void> _handleLogout() async {
    await _googleSignIn.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (await prefs.containsKey('id_user')) {
      await prefs.clear();
      setState(() {
        isLogin = false;
        nama = "";
      });
    }
  }

  Future<void> _handleSignIn() async {
    try {
      final GoogleSignInAccount userGoogle = await _googleSignIn.signIn();
      setState(() {
        errorLogin = userGoogle.toString();
      });
      if (userGoogle == null) {
        return;
      }

      this.getSessionOnserver(userGoogle);
    } catch (error) {
      setState(() {
        errorLogin = error.toString();
      });
    }
  }

  Future<void> getSessionOnserver(GoogleSignInAccount userGoogle) async {
    Uri urlApi = Uri.https(Config().urlApi, '/public/api/login_google');

    http.post(urlApi, body: {
      'email': userGoogle.email,
      'name': userGoogle.displayName,
      'id': userGoogle.id
    }).then((http.Response response) {
      dynamic result = json.decode(response.body);
      this.saveSession(result, userGoogle.displayName);
    }).onError((error, stackTrace) {
      // Toast.show(error.toString(), context);
    });
  }

  Future<void> saveSession(dynamic data, String name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', data['data']['token']);
    await prefs.setString('nama', name);
    await prefs.setString('id_user', data['data']['id_user'].toString());
    setState(() {
      isLogin = true;
      nama = "Almi Kurniawan";
    });
  }

  Future<void> getPopuler() async{
    Uri urlApi = Uri.https(Config().urlApi, '/public/api/wisata_rekomendasi');

    http.get(urlApi).then((http.Response response) {
      if (response.statusCode == 401) {
        // logout(context);
      } else {
        dynamic result = json.decode(response.body);
        dynamic populers_temp = [];
        result['data'].forEach((element){
          populers_temp.add({
            'id' : element['id_objek'],
            'nama' : element['nama_objek'],
            'deskripsi' : element['deskripsi'],
            'url_gambar' : element['gambar'],
            'dilihat' : element['dilihat'],
            'wilayah' : element['nama_wilayah']
          });
        });
        setState(() {
          populers  = populers_temp;
        });
      }
    }).onError((error, stackTrace) {
    });
  }

  Future<void> getObjekAll() async{
    markers = [];
    objeksAll = [];
    setState(() {});
    Uri urlApi = Uri.https(Config().urlApi, '/api/wisata_all_android');

    http.get(urlApi).then((http.Response response) {
      if (response.statusCode == 401) {
        // logout(context);
      } else {
        dynamic result = json.decode(response.body);
        int index=0;

        result['data'].forEach((element){
          if(element['latitude']!='' && element['latitude']!=null){
            // print(" index "+index.toString());
            objeksAll.add(element);
            markers.add(
              Marker(
                width: 150,
                height: 150,
                point: LatLng(double.parse(element['latitude']), double.parse(element['longitude'])),
                builder: (ctx) => GestureDetector(
                  onTap: (){
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        contentPadding: const EdgeInsets.all(0),
                        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 150),
                        content: ItemObjekMap(data: element, onDetail: (element){
                          Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                              return DetailObjek(id: element['id'], data: element);
                            }));
                        },),
                        actions: [
                          IconButton(icon: Icon(Icons.close), onPressed: (){
                            Navigator.pop(context, true);
                          })
                        ],
                      ),
                    );
                  },
                  child: Container(
                    child: Icon(Icons.place, color: Colors.red,),
                  ),
                ),
              )
            );

            index++;
          }
        });
        setState(() {});
      }
    }).onError((error, stackTrace) {
      // Toast.show(error.toString(), context);
    });
  }

  Marker markerComponent(int index, dynamic element){
    return 
    Marker(
      width: 150,
      height: 150,
      point: LatLng(double.parse(element['latitude']), double.parse(element['longitude'])),
      builder: (ctx) => GestureDetector(
        onTap: (){
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              content: Text(element['nama'],),
            ),
          );
        },
        child: Container(
          child: Icon(Icons.place, color: Colors.red,),
        ),
      ),
    );
  }

  Future<void> getKategori() async {
    Uri urlApi = Uri.https(Config().urlApi, '/public/api/kategori');

    http.get(urlApi).then((http.Response response) {
      if (response.statusCode == 401) {
        // logout(context);
      } else {
        dynamic result = json.decode(response.body);
        dynamic tempKategori = [];
        int index = 0;
        result['data'].forEach((element) {
          element['child'] = [];
          tempKategori.add(element);
          this.getChildKategori(index, element['id_kategori'], element['nama_kategori']);
          index++;
        });
        this.setState(() {
          kategoris = tempKategori;
        });
      }
    }).onError((error, stackTrace) {
      // Toast.show(error.toString(), context);
    });
  }

  Future<void> getChildKategori(int index, int idKategori, String namaKategori) async{
    Map<String, dynamic> queryString = new Map<String, dynamic>();
    queryString['search_by'] = "kategori.nama_kategori";
    queryString['search'] = namaKategori;
    queryString['wilayah-id'] = 5.toString();

    Uri urlApi = Uri.https(Config().urlApi, '/public/api/wisata/search', queryString);

    http.get(urlApi).then((http.Response response) {
      if(response.statusCode==401){
        // logout(context);
      }else{
        Map<String, dynamic> result = json.decode(response.body);
        kategoris[index]['child'] = result['data']['data'];
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
          wilayahsKabupaten.add(item);
          return wilayahs.add(item);
        });
        setState(() {
        });
      }
    }).onError((error, stackTrace) {
      // Toast.show(error.toString(), context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: true,
        elevation: 1,
        backgroundColor: Colors.transparent,
        leading: IconButton(
                  icon: (widget.open == 0
                      ? const Icon(Icons.menu)
                      : const Icon(Icons.close)),
                  onPressed: () {
                    widget.onOpenDrawer(widget.open);
                  },
                  color: Colors.white,
                ),
        title: Image(
          image: AssetImage("assets/images/logo.png"),
          height: 45,
        ),
        actions: [
          (!isLogin)
            ? IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () {
                  this._handleSignIn();
                },
                color: Colors.white,
              )
            :
            PopupMenuButton(
              icon: Icon(Icons.account_circle),
              onSelected: (dynamic data){
                this._handleLogout();
              },
              itemBuilder: (context){
                return [
                  PopupMenuItem(child: Text("Logout"), height: 3, value: 1),
                ];
              }
            ),
        ],
      ),
        body: SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Container(
        color: const Color(0xffebe8e8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CarouselSlider.builder(
              options: CarouselOptions(
                height: 450,
                viewportFraction: 1,
                aspectRatio: 1,
                autoPlay: true,
                autoPlayInterval: Duration(seconds: 5),
                autoPlayAnimationDuration: Duration(milliseconds: 800),
                autoPlayCurve: Curves.fastOutSlowIn,
              ),
              itemCount: wilayahs.length,
              itemBuilder: (context, index, realIdx){
                return SliderBanner(
                  item: wilayahs[index],
                  index : index,
                  onTap: (dynamic value){
                    Navigator.push(context, MaterialPageRoute(builder: (context){
                      return ObjekWisata(idWilayah: value['id'], namaWilayah: value['label'], selectedKategori : []);
                    }));
                  },
                );
              }
            ),
            Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  border:
                      Border(bottom: BorderSide(color: Colors.grey[300]))),
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.red[300],
                        onPrimary: Colors.white,
                      ),
                      onPressed: () {
                        int show = (showMap == 1) ? 0 : 1;
                        setState(() {
                          showMap = show;
                        });
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.place,
                            color: Colors.white,
                          ),
                          Text(
                            (showMap == 1)
                                ? "Hide mini map"
                                : "View on mini map",
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                  ],
                ),
              ),
            ),
            Container(
              height: (showMap > 0) ? (showMap == 1) ? 300 : 500 : 0,
              child: FlutterMap(
                mapController: mapControoler,
                options: MapOptions(
                  center: mapCenter,
                  zoom: 16.0,
                ),
                layers: [
                  TileLayerOptions(
                      urlTemplate:
                          "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                      subdomains: ['a', 'b', 'c']),
                  (markers.length>0) ? 
                  MarkerLayerOptions(
                    markers: markers
                  ) : MarkerLayerOptions(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                            hintText: 'Apa yang kamu cari?',
                            filled: true,
                            fillColor: Colors.white,
                            border: new OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: const BorderRadius.all(
                                const Radius.circular(10.0),
                              ),
                            ),
                            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                            suffixIcon: Icon(Icons.search))),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: 
                    DropdownButtonFormField(
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
                        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      ),
                      items: wilayahsKabupaten.map((dynamic item) {
                        return DropdownMenuItem(
                          value: item['id'].toString()+'::'+item['label']+'::'+item['logo']+'::'+item['icon_logo'],
                          child: Text( (item['id']==0) ? "Semua Wilayah" : item['label']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        List<String> newValue = value.split("::");
                        setState(() {
                          selectedWilayah = int.parse(newValue[0]);
                          valueWilayahString = newValue[1];
                          gambarWilayah = newValue[2];
                          iconWilayah = newValue[3];
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: DropdownButtonFormField(
                      decoration: InputDecoration(
                        hintText: 'Kategori',
                        filled: true,
                        fillColor: Colors.white,
                        border: new OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: const BorderRadius.all(
                            const Radius.circular(10.0),
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      ),
                      items: kategoris.map((dynamic item) {
                        return DropdownMenuItem(
                          value: item['id_kategori'].toString()+'::'+item['nama_kategori'],
                          child: Text(item['nama_kategori']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        List<String> newValue = value.split("::");
                        setState(() {
                          selectedKategori = int.parse(newValue[0]);
                          selectedKategoriString = newValue[1];
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                          primary: Colors.red[300],
                          onPrimary: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return Pencarian(
                              selectedKategori: selectedKategori,
                              selectedWilayah: selectedWilayah,
                              valueWilayahString: valueWilayahString,
                              selectedKategoriString : selectedKategoriString,
                              iconWilayah : iconWilayah,
                              gambarWilayah : gambarWilayah,
                              search: searchController.text,
                            );
                          }));
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search),
                            Text("Cari"),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 50),
                    child: Text("Terpopuler Kami",
                        style: TextStyle(
                            fontSize: 26, fontWeight: FontWeight.bold)),
                  ),
                  Text(
                      "Jelajahi tempat wisata, akomodasi, kuliner, umkm, dan travel terbaik.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: 350,
                child: CarouselSlider.builder(
                  options: CarouselOptions(
                    disableCenter: false,
                    height: 340.0,
                    enlargeCenterPage: true,
                    viewportFraction: 0.8,
                    aspectRatio: 0.7,
                  ),
                  itemCount: populers.length,
                  itemBuilder: (context, index, realIdx){
                    return Container(
                          width: MediaQuery.of(context).size.width * 0.8,
                          child: ItemObjekPopuler(
                            data: populers[index],
                            onTap: (dynamic value){
                               Navigator.push(context, MaterialPageRoute(builder: (context){
                                return DetailObjek(id : value['id'], data : value);
                              }));
                            },
                          )
                    );
                  }
                )
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.only(left: 8, right: 8, top: 35),
                child: Text(
                  "Kategori",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            DefaultTabController(
              length: kategoris.length,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TabBar(
                    isScrollable: true,
                    unselectedLabelColor: Colors.black.withOpacity(0.6),
                    indicatorColor: Colors.black,
                    labelColor: Colors.black,
                    tabs: this.tabKategori(),
                  ),
                  Container(
                    height: 500,
                    child: TabBarView(
                      children: this.kontenKategori(),
                    ),
                  ),
                ],
              ),
            ),
            // Text(errorLogin)
          ],
        ),
      ),
    ));
  }

  List<Widget> tabKategori() {
    List<Widget> result = [];
    kategoris.forEach((element) {
      result.add(
        Tab(
          text: element['nama_kategori'],
        ),
      );
    });
    return result;
  }

  List<Widget> kontenKategori() {
    List<Widget> result = [];
    kategoris.forEach((element) {
      result.add(
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: element['child'].length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: ListWilayah(
                            item: element['child'][index],
                            onTap: (value){
                              Navigator.push(context, MaterialPageRoute(builder: (context){
                                return DetailObjek(id : value['id'], data : value);
                              }));
                            },
                          ),
                        );
                      }),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context){
                      return ObjekWisata(idWilayah: 0, namaWilayah:"", selectedKategori: [element['id_kategori']],);
                    }));
                  },
                  child: Text(
                    "Tampilkan Semua",
                    style: TextStyle(
                        color: Colors.red[300], fontWeight: FontWeight.w600),
                  ),
                ),
              )
            ],
          ),
        ),
      );
    });
    return result;
  }
}
