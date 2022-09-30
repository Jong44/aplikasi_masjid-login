import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'commons.dart';
import 'kota_model.dart';

class SettingInfoPage extends StatefulWidget{
  const SettingInfoPage({Key? key,}) : super(key: key);

  @override
  State<SettingInfoPage> createState() => _SettingInfoPageState();
}

class _SettingInfoPageState extends State<SettingInfoPage>{
  var namaController = TextEditingController(),phoneController = TextEditingController(),alamatController = TextEditingController();
  List<KotaModel> kota = [];
  KotaModel? selectedKota;
  final fDatabase = FirebaseDatabase.instance;
  final fStorage = FirebaseStorage.instance;
  final _auth = FirebaseAuth.instance;
  bool loading = false;
  String? logo;
  XFile? image;
  final ImagePicker _picker = ImagePicker();
  late String uid;
  late User user;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getKota();
  }


  Future<void> getKota() async {
    var url = Uri.parse('https://api.myquran.com/v1/sholat/kota/semua');
    var response = await http.get(url,);
    if (response.statusCode == 200){
      setState(() {
        kota  = (jsonDecode(response.body) as List?) != null &&
            (jsonDecode(response.body) as List).isNotEmpty
            ? (jsonDecode(response.body) as List)
            .map((f) => KotaModel.fromJson(f))
            .toList()
            : [];
        getData();
      });
    }else{
      throw Exception('Failed to load movie');
    }
  }



  Future<void> getData() async {

    user = await _auth.currentUser!;
    String uid = user.uid;

    var userdId = await fDatabase.reference().child(uid).once();
    var name = await fDatabase.reference().child(uid).child('setting').child('name').once();
    var address = await fDatabase.reference().child(uid).child('setting').child('address').once();
    var phone = await fDatabase.reference().child(uid).child('setting').child('phone').once();
    var city = await fDatabase.reference().child(uid).child('setting').child('cityId').once();
    var logoI = await fDatabase.reference().child(uid).child('setting').child('logo').once();

    setState(() {
        String? id;
        id = userdId.key;
        if(id == uid){
          namaController.text = name.value;
          alamatController.text = address.value;
          phoneController.text = phone.value;
          logo = logoI.value;
          if (kota.isNotEmpty){
            selectedKota = kota
                .where((element) =>
            element.id == city.value)
                .toList()[0];
          }
        }
    });
  }

  void save()async{
    setState(() {
      loading = true;
    });

    user = await _auth.currentUser!;
    uid = user.uid;


    String imageLogo;
    if (!logo!.contains('firebase') || !logo!.contains('http')){
      await fStorage.ref('image/${image?.name}').putFile(File(image!.path));
      var url = await fStorage.ref('image/${image?.name}').getDownloadURL();
      logo = url;
    }
    fDatabase.reference().child(uid).child('setting')
        .update({
      "name":namaController.text,
      "address":alamatController.text,
      "cityId":selectedKota?.id,
      "phone":phoneController.text,
      "logo": logo,
      "uid":uid,
    }).asStream();

    Future.delayed(Duration(seconds: 2)).then((value) {
      setState(() {
        loading = false;
      });
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          'Setting',
        ),
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
                        'Logo',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                      SizedBox(height: 5,),
                      InkWell(
                        onTap: ()async{
                          image = await _picker.pickImage(source: ImageSource.gallery);
                          setState(() {
                            logo = image!.path;
                          });
                        },
                        child: Container(
                            height: 160,
                            decoration: BoxDecoration(
                            ),
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: logo == null?Image.network('https://upload.wikimedia.org/wikipedia/commons/thumb/a/ac/No_image_available.svg/1024px-No_image_available.svg.png'):logo!.contains('firebase') || logo!.contains('http')?Image.network(logo!,fit: BoxFit.cover,):Image.file(File(logo!)))
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 15,),
                  SizedBox(height: 15,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nama Masjid',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                      SizedBox(height: 5,),
                      TextFormField(
                        controller: namaController,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          hintText: "Nama Masjid",
                          hintStyle: TextStyle(color: Colors.grey.shade300),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 15,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nomor Handphone',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                      SizedBox(height: 5,),
                      TextFormField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          hintText: "081234567890",
                          hintStyle: TextStyle(color: Colors.grey.shade300),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 15,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Alamat',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                      SizedBox(height: 5,),
                      TextFormField(
                        controller: alamatController,
                        keyboardType: TextInputType.streetAddress,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          hintText: "Alamat Masjid",
                          hintStyle: TextStyle(color: Colors.grey.shade300),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 15,),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.01),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Provinsi',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        DropdownButtonFormField<KotaModel>(
                          value: selectedKota,
                          decoration: InputDecoration(
                            fillColor: kota.isEmpty
                                ? Colors.grey.shade400
                                : Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: selectedKota != null
                                    ? primaryColor
                                    : Colors.grey[200]!,
                              ),
                            ),
                          ),
                          hint: new Text(
                            "Pilih kota anda",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          items: kota.map((value) {
                            return new DropdownMenuItem<KotaModel>(
                              value: value,
                              child: new Row(
                                children: <Widget>[
                                  new Text(
                                    value.lokasi!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  )
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            selectedKota = value as KotaModel;
                            FocusScope.of(context).unfocus();
                            // _getCity(selectedProvince!.id!);
                            // selectedCity = null;
                            // selectedDistrict = null;
                          },
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 10,),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: ElevatedButton(
                      onPressed: (){
                        save();
                      },
                      style: ElevatedButton.styleFrom(
                          primary: primaryColor
                      ),
                      child: Text(
                          'Simpan'
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          if (loading)Center(
              child: SizedBox(width:30,height: 30,child: CircularProgressIndicator()))
        ],
      ),
    );
  }
}