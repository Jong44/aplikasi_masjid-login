import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'information_modal.dart';
import 'menu_modal.dart';
import 'package:image_picker/image_picker.dart';
import 'text_modal.dart';
import 'setting.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'commons.dart';
import 'modals.dart';

late User loggedinUser;

class Home  extends StatefulWidget{
  const Home({Key? key}) : super(key: key);
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home>{
  final fDatabase = FirebaseDatabase.instance;
  final fStorage = FirebaseStorage.instance;
  List<String> lists = [];
  List<String> listsValue = [];
  final ImagePicker _picker = ImagePicker();
  bool loading = false;
  final _auth = FirebaseAuth.instance;
  bool isworking = false;
  String id = FirebaseAuth.instance.currentUser!.uid;








  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    init();
    getCurrentUser();
  }


  void getCurrentUser() async {
    try {
      final user =  await _auth.currentUser;
      if (user != null){
        loggedinUser = user;
      }
    } catch (e){
      print(e);
    }
  }

  void init()async{
  }

  void showMenuModal(String urlImage,String key,) async {
    var user = await _auth.currentUser!;
    late String uid = user.uid;
    await Modals.showCupertinoModal(
      context: context,
      builder: MenuModal(

        url: urlImage,
        keyData: key,
        onUpdate: ()async{
          fStorage.refFromURL(urlImage).delete();
          var image = await _picker.pickImage(source: ImageSource.gallery);
          Navigator.pop(context);
          setState(() {
            loading = true;
          });


          await fStorage.ref('image/${image?.name}').putFile(File(image!.path));
          var url = await fStorage.ref('image/${image.name}').getDownloadURL();
          Map<String,dynamic> body = {
            key:url
          };
          fDatabase.reference().child(uid).child('image')
              .update(body).asStream();
          setState(() {
            loading = false;
          });
        },
        onDelete: ()async{
          fStorage.refFromURL(urlImage).delete();
          Navigator.pop(context);
          setState(() {
            loading = true;
          });
          fDatabase.reference().child(uid).child('image').child(key)
              .remove().asStream();
          setState(() {
            loading = false;
          });
        },
      ),
    );
  }

  void showTextModal({bool isUpdate = true,String? text,String? key,}) async {
    var user = await _auth.currentUser!;
    late String uid = user.uid;
    await Modals.showCupertinoModal(
      context: context,
      builder: TextModal(
        text: text,
        id: key,
        isUpdate: isUpdate,
        onDelete: ()async{
          Navigator.pop(context);
          setState(() {
            loading = true;
          });
          fDatabase.reference().child(uid).child('image').child(key!)
              .remove().asStream();
          setState(() {
            loading = false;
          });
        },
      ),
    ).then((value) {
      if (value != null){
        setState(() {
          loading = true;
        });
        if (isUpdate){
          Map<String,dynamic> body = {
            key!:value!
          };
          fDatabase.reference().child(uid).child('image')
              .update(body).asStream();
        }else{
          fDatabase.reference().child(uid).child('image')
              .push()
              .set(value).asStream();
        }
        setState(() {
          loading = false;
        });
      }
    });
  }

  void updateRunningText(String text,key)async{
    var user = await _auth.currentUser!;
    late String uid = user.uid;

    await Modals.showCupertinoModal(
        context: context,
        builder: InformationModal(
          info: text,
          onSave: (){

          },
        )
    ).then((value) {
      if (value != null){
        setState(() {
          loading = true;
        });
        Map<String,dynamic> body = {
          key:value!
        };
        print(body);
        fDatabase.reference().child(uid).child('information')
            .update(body).asStream();
        setState(() {
          loading = false;
        });
      }
    });
  }

  List<String> information = [];
  List<String> informationKey = [];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: primaryColor,
        title: Text(
            'Master Masjid'
        ),
        actions: [
          IconButton(
            icon: Icon(
                Icons.settings
            ),
            onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context){
                return SettingInfoPage();
              }));
            },
          ),
          IconButton(
              onPressed: (){
                _auth.signOut();
                Navigator.pop(context);

              },
              icon: Icon(Icons.output)),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Informasi Running Text',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600
                        ),
                      ),
                      SizedBox(height: 10,),
                      FutureBuilder(
                          future: fDatabase.reference().child(id).child('information').once(),
                          builder: (context, AsyncSnapshot<DataSnapshot> snapshot) {
                            if (snapshot.hasError)return Text('Empty', style: TextStyle(fontSize: 100),);
                            if (snapshot.hasData) {
                              if (snapshot.hasError)return Text('error');
                              if (snapshot.hasData) {
                                information.clear();
                                if (snapshot.data!.value != null){
                                  Map<dynamic, dynamic> values = snapshot.data!.value;
                                  values.forEach((key, values) {
                                    information.add(values);
                                    informationKey.add(key);
                                  });
                                  return Column(
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Informasi 1',
                                            style: TextStyle(
                                                fontSize: 16
                                            ),
                                          ),
                                          SizedBox(height: 5,),
                                          InkWell(
                                            onTap: (){
                                              updateRunningText(information[0],informationKey[0]);
                                            },
                                            child: Container(
                                              width: MediaQuery.of(context).size.width,
                                              decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(10),
                                                  border: Border.all(color: Colors.grey.shade400)
                                              ),
                                              padding: EdgeInsets.symmetric(horizontal: 16,vertical: 10),
                                              child: Text(
                                                information[0],
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w600
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 5,),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Informasi 2',
                                            style: TextStyle(
                                                fontSize: 16
                                            ),
                                          ),
                                          SizedBox(height: 5,),
                                          InkWell(
                                            onTap: (){
                                              updateRunningText(information[1],informationKey[1]);
                                            },
                                            child: Container(
                                              width: MediaQuery.of(context).size.width,
                                              decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(10),
                                                  border: Border.all(color: Colors.grey.shade400)
                                              ),
                                              padding: EdgeInsets.symmetric(horizontal: 16,vertical: 10),
                                              child: Text(
                                                information[1],
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w600
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  );
                                }
                              }
                              return Column(
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Informasi 1',
                                        style: TextStyle(
                                            fontSize: 16
                                        ),
                                      ),
                                      SizedBox(height: 5,),
                                      InkWell(
                                        onTap: () async {
                                          updateRunningText('Informasi 1','information0');
                                          fDatabase.reference().child(id).child('information').child('information0').set('Informasi 1');
                                          fDatabase.reference().child(id).child('information').child('information1').set('Informasi 2');
                                        },
                                        child: Container(
                                          width: MediaQuery.of(context).size.width,
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(10),
                                              border: Border.all(color: Colors.grey.shade400)
                                          ),
                                          padding: EdgeInsets.symmetric(horizontal: 16,vertical: 10),
                                          child: Text(
                                            'Informasi 1',
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 5,),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Informasi 2',
                                        style: TextStyle(
                                            fontSize: 16
                                        ),
                                      ),
                                      SizedBox(height: 5,),
                                      InkWell(
                                        onTap: (){
                                          updateRunningText('Informasi 2','information1');
                                          fDatabase.reference().child(id).child('information').child('information0').set('Informasi 1');
                                          fDatabase.reference().child(id).child('information').child('information1').set('Informasi 2');
                                        },
                                        child: Container(
                                          width: MediaQuery.of(context).size.width,
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(10),
                                              border: Border.all(color: Colors.grey.shade400)
                                          ),
                                          padding: EdgeInsets.symmetric(horizontal: 16,vertical: 10),
                                          child: Text(
                                            'Informasi 2',
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              );
                              if (snapshot.data!.value != null){
                                Map<dynamic, dynamic> values = snapshot.data!.value;
                                print(values);
                                String? info;
                                String? keyData;
                                values.forEach((key, values) {
                                  info = values;
                                  keyData = key;
                                });
                                print(keyData);
                                return InkWell(
                                  onTap: (){
                                    updateRunningText(info!,keyData);
                                  },
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: Colors.grey.shade400)
                                    ),
                                    padding: EdgeInsets.symmetric(horizontal: 16,vertical: 10),
                                    child: Text(
                                      info ?? '-',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600
                                      ),
                                    ),
                                  ),
                                );
                              }
                            }
                            return SizedBox();
                          }),
                    ],
                  ),
                  SizedBox(height: 16,),Text(
                    'Gambar Poster',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600
                    ),
                  ),
                  SizedBox(height: 16,),
                  FutureBuilder(
                      future: FirebaseDatabase().reference().child(id).child('image').once(),
                      builder: (context, AsyncSnapshot<DataSnapshot> snapshot) {
                        if (snapshot.hasError)return Text('Empty');
                        if (snapshot.hasData) {
                          lists.clear();
                          listsValue.clear();
                          if (snapshot.data!.value != null){
                            Map<dynamic, dynamic> values = snapshot.data!.value;
                            print(values);
                            values.forEach((key, values) {
                              lists.add(values);
                              listsValue.add(key);
                            });
                            return Container(
                              height: MediaQuery.of(context).size.height * .6,
                              child: GridView.builder(
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2,mainAxisSpacing: 15,crossAxisSpacing: 15),
                                itemBuilder: (context,index){
                                  return  InkWell(
                                    onTap: (){
                                      if (lists[index].contains('http')){
                                        showMenuModal(lists[index],listsValue[index]);
                                      }else{
                                        showTextModal(text:lists[index],key:listsValue[index]);
                                      }
                                    },
                                    child: lists[index].contains('http')?Container(
                                        decoration: BoxDecoration(
                                        ),
                                        child: ClipRRect(
                                            borderRadius: BorderRadius.circular(10),
                                            child: Image.network(lists[index],fit: BoxFit.cover,))
                                    ):Container(
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(color: Colors.grey)
                                      ),
                                      padding: EdgeInsets.all(10),
                                      child: Text(
                                        lists[index],
                                      ),
                                    ),
                                  );
                                },
                                itemCount: lists.length,
                              ),
                            );
                          }
                        }
                        return SizedBox();
                      }),
                  // Expanded(
                  //   child: FirebaseAnimatedList(
                  //     // controller: _scrollController,
                  //     query: fDatabase.reference()..child('epk1a7CPOvZdoEcxNuZHPXzNvjJ2').child('image'),
                  //     itemBuilder: (context, snapshot, animation, index) {
                  //       return Container(
                  //         child: Text(snapshot.value.toString()),
                  //       );
                  //     },
                  //   ),
                  // )
                ],
              ),
            ),
          ),
          if (loading)Center(
              child: SizedBox(width:30,height: 30,child: CircularProgressIndicator()))
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: ()async{
              var image = await _picker.pickImage(source: ImageSource.gallery);
              setState(() {
                loading = true;
              });
              var user = await _auth.currentUser!;
              late String uid = user.uid;
              await fStorage.ref('image/${image?.name}').putFile(File(image!.path));
              var url = await fStorage.ref('image/${image.name}').getDownloadURL();
              fDatabase.reference().child(uid).child('image')
                  .push()
                  .set(url).asStream();
              setState(() {
                loading = false;
              });
            },
            backgroundColor: primaryColor,
            child: Icon(
                Icons.add_a_photo_outlined
            ),
          ),
          SizedBox(height: 10,),
          FloatingActionButton(
            onPressed: ()async{
              showTextModal(isUpdate: false);
            },
            backgroundColor: primaryColor,
            child: Icon(
                Icons.edit
            ),
          ),
        ],
      ),
    );
  }

}