import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'config/app.dart';

class AddUsulan extends StatefulWidget {
  const AddUsulan({Key key}) : super(key: key);

  @override
  _AddUsulanState createState() => _AddUsulanState();
}

class _AddUsulanState extends State<AddUsulan> {
  List wilayahs = [];
  TextEditingController objek = TextEditingController();
  TextEditingController deskripsi = TextEditingController();
  int idWilayah = 0;

  @override
  void initState(){
    super.initState();
    this.getWilayah();
  }

  Future<void> getWilayah() async{
    Uri urlApi = Uri.https(Config().urlApi, '/public/api/wilayah');

    http.get(urlApi).then((http.Response response) {
      if(response.statusCode==401){
        // logout(context);
      }else{
        Map<String, dynamic> result = json.decode(response.body);
        result['data'].insert(0,{
          "id" : 0,
          "kabupaten" : "Pilih Wilayah"
        });
        setState(() {
          wilayahs = result['data'];
        });
      }
    }).onError((error, stackTrace) {
      
    });
  }

  Future<void> usulkan() async{
    Uri urlApi = Uri.https(Config().urlApi, '/public/api/insert_usulan_objek');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = await prefs.getString("id_user");

    http.post(urlApi,
      body: {
        "user_id" : userId,
        "id_wilayah" : idWilayah.toString(),
        "objek" : objek.text,
        "deskripsi" : deskripsi.text
      }
    ).then((http.Response response) {
      if(response.statusCode==401){
        // logout(context);
      }else{
        setState(() {          
          idWilayah = 0;
          deskripsi.text = "";
          objek.text = "";
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
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black87,
                  image: DecorationImage(
                    image: AssetImage("assets/images/bg-objek.jpg"),
                    colorFilter: new ColorFilter.mode(
                        Colors.black.withOpacity(0.3), BlendMode.dstATop),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 50),
                  child: Align(
                      alignment: Alignment.center,
                      child: Text("KIRIM USULAN",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold))),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8, top: 40),
                child: Text(
                  "Kirim Usulan !",
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 24),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Usulkan objek disekitar Anda."),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Nama Wisata",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                    controller: objek,
                    decoration: InputDecoration(
                        hintText: '',
                        filled: true,
                        fillColor: Colors.white,
                        border: new OutlineInputBorder(
                          borderRadius: const BorderRadius.all(
                            const Radius.circular(10.0),
                          ),
                        ),
                        )),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Wilayah",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButtonFormField(
                  decoration : InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: new OutlineInputBorder(
                      borderRadius: const BorderRadius.all(
                        const Radius.circular(10.0),
                      ),
                    ),
                  ),
                  items: wilayahs.map((dynamic item){
                    return DropdownMenuItem(
                      value: item['id'],
                      child: Text(item['kabupaten']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    idWilayah = value;
                  },
                  value: idWilayah,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Deskripsi",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                    controller: deskripsi,
                    maxLines: 5,
                    decoration: InputDecoration(
                        hintText: '',
                        filled: true,
                        fillColor: Colors.white,
                        border: new OutlineInputBorder(
                          borderRadius: const BorderRadius.all(
                            const Radius.circular(10.0),
                          ),
                        ),
                        )),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  child: Text("Usulkan", style: TextStyle(color: Colors.white),),
                  onPressed: () {
                    this.usulkan();
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.red[300]),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      )
                    )
                  )
                ),
              ),
            ]),
      )),
    );
  }
}
