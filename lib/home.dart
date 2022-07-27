import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:wisatakemari/about.dart';
import 'package:wisatakemari/addUsulan.dart';
import 'package:wisatakemari/youtube.dart';
import 'homeContent.dart';
import 'objekWisata.dart';

class Home extends StatefulWidget {
  const Home({key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  double value = 0;

  Future<Widget> loadMenu()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(await prefs.containsKey('id_user')){
      return ListView(
                children: [
                    ListTile(
                      onTap: () {
                        setState(() {
                          value = 0;
                        });
                      },
                      title: Text("Home"),
                      leading: Icon(Icons.home),
                    ),
                    ListTile(
                      onTap: () {
                        setState(() {
                          value = 0;
                        });
                        Navigator.push(context, MaterialPageRoute(builder: (context){
                          return ObjekWisata(idWilayah: 0, namaWilayah: "", selectedKategori: [],);
                        }));
                      },
                      title: Text("Objek"),
                      leading: Icon(Icons.place),
                    ),
                    ListTile(
                      onTap: () {
                        setState(() {
                          value = 0;
                        });
                        Navigator.push(context, MaterialPageRoute(builder: (context){
                          return Youtube();
                        }));
                      },
                      title: Text("Video 360"),
                      leading: Icon(Icons.videocam_sharp),
                    ),
                    ListTile(
                      onTap: () {
                        setState(() {
                          value = 0;
                        });
                        Navigator.push(context, MaterialPageRoute(builder: (context){
                          return About();
                        }));
                      },
                      title: Text("Tentang Kami"),
                      leading: Icon(Icons.place),
                    ),
                    ListTile(
                      onTap: () {
                        setState(() {
                          value = 0;
                        });
                        Navigator.push(context, MaterialPageRoute(builder: (context){
                          return AddUsulan();
                        }));
                      },
                      title: Text("Usulan"),
                      leading: Icon(Icons.settings),
                    ),
                ],
              );
    }else{
      return ListView(
                children: [
                    ListTile(
                      onTap: () {
                        setState(() {
                          value = 0;
                        });
                      },
                      title: Text("Home"),
                      leading: Icon(Icons.home),
                    ),
                    ListTile(
                      onTap: () {
                        setState(() {
                          value = 0;
                        });
                        Navigator.push(context, MaterialPageRoute(builder: (context){
                          return ObjekWisata(idWilayah: 0, namaWilayah:"", selectedKategori: [],);
                        }));
                      },
                      title: Text("Objek"),
                      leading: Icon(Icons.place),
                    ),
                    ListTile(
                      onTap: () {
                        setState(() {
                          value = 0;
                        });
                        Navigator.push(context, MaterialPageRoute(builder: (context){
                          return Youtube();
                        }));
                      },
                      title: Text("Video 360"),
                      leading: Icon(Icons.videocam_sharp),
                    ),
                    ListTile(
                      onTap: () {
                        setState(() {
                          value = 0;
                        });
                        Navigator.push(context, MaterialPageRoute(builder: (context){
                          return About();
                        }));
                      },
                      title: Text("Tentang Kami"),
                      leading: Icon(Icons.person),
                    ),
                ],
              );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(children: [
      Container(
        decoration: BoxDecoration(color: Colors.white70),
      ),
      SafeArea(
          child: Container(
        width: 250,
        child: Padding(
          padding: const EdgeInsets.only(top: 15),
          child: Column(
            children: [
              Text(
                "MENU",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              Divider(
                height: 2,
                color: Colors.white,
              ),
              Expanded(
                  child: FutureBuilder(
                    future: loadMenu(),
                    builder: (BuildContext context, AsyncSnapshot<Widget> widget){
                      if (widget.hasData) {
                        if (widget.data != null) {
                          return widget.data;
                        }else{
                          return Container();
                        }
                      }else{
                        return Container();
                      }
                    },
                )
              )
            ],
          ),
        ),
      )),

      TweenAnimationBuilder(
        tween: Tween<double>(begin: 0, end: value), 
        duration: Duration(milliseconds: 700), 
        builder: (BuildContext context, double val, Widget child){
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..setEntry(0, 3, 250 * val),
            child: HomeContent(
              onOpenDrawer: (double val){
                setState(() {
                  val == 0.0 ? value = 1 : value = 0;
                });
              },
              open : value
            ),
          );
        }
      ),

      // GestureDetector(
      //   onTap: (){
      //     setState(() {
      //       value == 0 ? value = 1 : value = 0;
      //     });
      //   },
      // )


    ]));
  }
}
