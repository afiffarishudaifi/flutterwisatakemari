import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wisatakemari/components/itemObjekMapObjek.dart';
import 'components/itemObjek.dart';
import 'config/app.dart';
import 'detailObjek.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class ObjekWisata extends StatefulWidget {
  final int idWilayah;
  final String namaWilayah;
  final List<int> selectedKategori;
  const ObjekWisata(
      {Key key, this.idWilayah, this.namaWilayah, this.selectedKategori})
      : super(key: key);

  @override
  _ObjekWisataState createState() => _ObjekWisataState();
}

class _ObjekWisataState extends State<ObjekWisata> {
  List kategoris = [];
  List<Map<String, dynamic>> wilayahs = [];
  List objeks = [];
  List selectedRating;
  List<Map<String, dynamic>> urutkans;
  String selectedUrutan;
  int selectedWilayah;
  String selectedWilayahString;
  String iconWilayah;
  String gambarWilayah;
  bool collapseFilter = false;
  int currentPage = 1;
  int totalPage = 1;
  int showMap = 0;
  LatLng mapCenter = LatLng(-7.812919, 112.014614);
  List<Marker> markers;
  bool isLoading;
  MapController mapControoler;

  @override
  void initState() {
    super.initState();
    selectedWilayahString = "";
    iconWilayah = "pacitan.png";
    gambarWilayah = "https://wisatakemari.com/public/images/wilayah/20210719074008_5.jpg";
    markers = [];
    selectedRating = [];
    urutkans = [
      {
        "id" : "",
        "label" : "--Pilih--"
      },
      {
        "id" : "nama-ASC",
        "label" : "Alphabet (A-Z)"
      },
      {
        "id" : "nama-DESC",
        "label" : "Alphabet (Z-A)"
      },
      {
        "id" : "number-DESC",
        "label" : "Paling Banyak Dilihat"
      },
      {
        "id" : "number-ASC",
        "label" : "Paling Sedikit Dilihat"
      },
      {
        "id" : "rating-DESC",
        "label" : "Penilaian Paling Tinggi"
      },
      {
        "id" : "rating-ASC",
        "label" : "Penilaian Paling Rendah"
      }
    ];
    selectedUrutan = "";
    mapControoler = MapController();
    isLoading = true;
    this.getWilayah();
    this.getKategori(widget.selectedKategori).then((value) {
      selectedWilayah = widget.idWilayah;
      selectedWilayahString = widget.namaWilayah;
      this.getObjek();
    });
  }

  Future getKategori(List<int> selectedKategori) async {
    Uri urlApi = Uri.https(Config().urlApi, '/public/api/kategori');

    return http.get(urlApi).then((http.Response response) {
      if (response.statusCode == 401) {
        // logout(context);
      } else {
        Map<String, dynamic> result = json.decode(response.body);
        result['data'].forEach((value) {
          bool checked =
              (selectedKategori.contains(value['id_kategori']) ? true : false);
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

  Future<void> getObjek() async {
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> queryString = new Map<String, dynamic>();
    queryString['page'] = currentPage.toString();
    bool search = false;

    if (selectedWilayah > 0) {
      search = true;
      queryString['wilayah-id'] = selectedWilayah.toString();
    } else {
      queryString['wilayah-id'] = 5.toString();
    }

    List queryKategori = [];
    kategoris.forEach((element) {
      if (element['checked']) {
        queryKategori.add(element['id'].toString());
      }
    });
    if (queryKategori.length > 0) {
      search = true;
      queryString['kategori-id_kategori[]'] = queryKategori;
    }

    if(search) {
      queryString['search_by'] = "";
      queryString['search'] = "";
    } else {
      queryString['search_by'] = "";
      queryString['search'] = "";
    }

    if(selectedRating.length>0){
      List<String> queryRating = [];
      selectedRating.forEach((element) {
        queryRating.add(element.toString());
      });
      queryString['wisata-rating[]'] = queryRating;
    }

    queryString['wisata-ordering'] = selectedUrutan;

    Uri urlApi =
        Uri.https(Config().urlApi, '/public/api/wisata/search', queryString);

    http.get(urlApi).then((http.Response response) {
      if (response.statusCode == 401) {
        // logout(context);
      } else {
        Map<String, dynamic> result = json.decode(response.body);
        if(result['data'].length>0){
          result['data']['data'].forEach((element) {
            objeks.add(element);
            if(element['latitude']!=null){
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
                          content: ItemObjekMapObjek(data: element, onDetail: (element){
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
            }
          });

          if(markers.length>=1){
            setState(() {
              currentPage = result['data']['current_page'] + 1;
              totalPage = result['data']['last_page'];
              isLoading = false;
            });
            if(showMap>0){
              mapControoler.move(LatLng(double.parse(objeks[0]['latitude']), double.parse(objeks[0]['longitude'])), 13.0);
            }
          }else{
            setState(() {
              currentPage = result['data']['current_page'] + 1;
              totalPage = result['data']['last_page'];
              isLoading = false;
            });
          }
        }
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
      objeks = [];
      markers = [];
      selectedRating = [];
      selectedUrutan = "";
      selectedWilayah = 0;
      currentPage = 1;
    });
    this.getObjek();
  }

  @override
  Widget build(BuildContext context) {
    String judul = "Kabupaten Pacitan";
    String kategoriSelected = "";
    kategoris.forEach((element) {
      if(element['checked']){
        kategoriSelected = kategoriSelected + element['label']+", ";
      }
    });
    if(kategoriSelected!=""){
      kategoriSelected = kategoriSelected ;
    }
    if(selectedWilayahString!=""){
      kategoriSelected = kategoriSelected + "\n" + selectedWilayahString;
    }
    if(kategoriSelected!=""){
      judul = kategoriSelected;
    }
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
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black87,
                  image: DecorationImage(
                    image: NetworkImage(gambarWilayah),
                    colorFilter: new ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.dstATop),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image(image: NetworkImage('https://wisatakemari.com/public/images/wilayah/'+iconWilayah), height: 60,),
                      Text(judul, style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
                    ],
                  ),
                ),
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
                          if(show>0){
                            mapControoler.onReady.whenComplete((){
                              if(objeks.isNotEmpty){
                                mapControoler.move(LatLng(double.parse(objeks[0]['latitude']), double.parse(objeks[0]['longitude'])), 13.0);
                              }
                            });
                          }
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
                    zoom: 13.0,
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
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("Kabupaten / Kota",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600)),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 5),
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
                                          items: wilayahs.map((dynamic item) {
                                            return DropdownMenuItem(
                                              value: item['id'].toString()+'::'+item['label']+'::'+item['logo']+'::'+item['icon_logo'],
                                              child: Text( (item['id']==0) ? "Semua Wilayah" : item['label']),
                                            );
                                          }).toList(),
                                          onChanged: (value) {
                                            List<String> newValue = value.split("::");
                                            setState(() {
                                              selectedWilayah = int.parse(newValue[0]);
                                              selectedWilayahString = newValue[1];
                                              gambarWilayah = newValue[2];
                                              iconWilayah = newValue[3];
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
                                                    // fillColor: MaterialStateProperty.resolveWith(getColor),
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
                                                  Text(
                                                      kategoris[index]['label'])
                                                ],
                                              );
                                            }),
                                      ),
                                      Text("Penilaian",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600)),
                                      MediaQuery.removePadding(
                                        context: context,
                                        removeTop: true,
                                        child: ListView.builder(
                                            itemCount: 5,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            itemBuilder: (context, index) {
                                              List<Widget> rating = [];
                                              for(int i=5; i >= (index+1); i--){
                                                rating.add(Icon(Icons.star, color: Colors.yellow[700],));
                                              }
                                              rating.add(Text("("+(5-index).toString()+"+)"));
                                              return Row(
                                                children: [
                                                  Checkbox(
                                                    checkColor: Colors.white,
                                                    activeColor: Colors.red,
                                                    // fillColor: MaterialStateProperty.resolveWith(getColor),
                                                    value: selectedRating.contains((5-index)) ? true : false,
                                                    onChanged: (bool value) {
                                                      if(value){
                                                        selectedRating.add((5-index));
                                                      }else{
                                                        selectedRating.remove((5-index));
                                                      }
                                                      setState(() {});
                                                    },
                                                  ),
                                                  Row(
                                                    children: rating,
                                                  )
                                                ],
                                              );
                                            }),
                                      ),
                                      Text("Urutkan",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600)),
                                      DropdownButtonFormField(
                                        decoration: InputDecoration(
                                          hintText: 'Urutkan',
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
                                        value: selectedUrutan,
                                        items: urutkans.map((Map<String, dynamic> item) {
                                          return DropdownMenuItem(
                                            value: item['id'],
                                            child: Text(item['label']),
                                          );
                                        }).toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            selectedUrutan = value;
                                          });
                                        },
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
                                                      BorderRadius.circular(
                                                          5.0),
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
                                            onPressed: () async {
                                              setState(() {
                                                currentPage = 1;
                                                objeks = [];
                                                markers = [];
                                                collapseFilter = false;
                                              });
                                              this.getObjek();
                                            },
                                            style: ButtonStyle(
                                                backgroundColor:
                                                    MaterialStateProperty.all<
                                                        Color>(Colors.blue),
                                                shape: MaterialStateProperty.all<
                                                        RoundedRectangleBorder>(
                                                    RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5.0),
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
              Padding(
                padding: const EdgeInsets.only(left: 15, right: 15, top: 0),
                child: MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: objeks.length,
                      itemBuilder: (context, index) {
                        return ItemObjek(
                          data: objeks[index],
                          onTap: (value) {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return DetailObjek(id: value['id'], data: value);
                            }));
                          },
                        );
                      }),
                ),
              ),
              (isLoading) ? 
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.center,
                  child: CircularProgressIndicator()),
              ) : Container(),
              (currentPage > totalPage)
                  ? Container()
                  : Padding(
                      padding:
                          const EdgeInsets.only(left: 15, right: 15, top: 8),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                            child: Text(
                              "Load More",
                              style: TextStyle(color: Colors.white),
                            ),
                            onPressed: () {
                              this.getObjek();
                            },
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.red[300]),
                                shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.0),
                                )))),
                      ),
                    ),
            ]),
      )),
    );
  }
}
