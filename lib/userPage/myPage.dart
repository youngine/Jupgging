import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'package:jupgging/models/user.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:jupgging/auth/url.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class MyPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MyPage();
}

class _MyPage extends State<MyPage> {
  TextEditingController _pwTextController;
  TextEditingController _emailTextController;

  String id;
  String _profileImgUrl;
  User user;
  File _image;

  FirebaseDatabase _database;
  DatabaseReference reference;
  FirebaseStorage _firebaseStorage;

  URL url=URL();
  String _databaseURL;
  static final storage = new FlutterSecureStorage();

  void Photo(ImageSource source) async {
    File file = await ImagePicker.pickImage(source: source);
    setState(() => _image = file);
  }

  @override
  void initState() {
    super.initState();
    _databaseURL=url.databaseURL;
    _firebaseStorage = FirebaseStorage.instance;
    _database = FirebaseDatabase(databaseURL: _databaseURL);
    reference = _database.reference().child('user');

    _pwTextController = TextEditingController();
    _emailTextController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _asyncMethod();
    });
  }

  _asyncMethod() async {
    String _id=await storage.read(key: "login");
    setState(() {id=_id;});
    await reference.child(id).onChildAdded.listen((event) {
      setState(() {
        user=User.fromSnapshot(event.snapshot);
        _profileImgUrl=user.profileImg;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    //user = ModalRoute.of(context).settings.arguments;
    //print('username-------------------------${user.name}');
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color:Colors.white),
        title: Text(
          '????????? ??????',
          style: TextStyle(color: Colors.white),
        ),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              if (_pwTextController.value.text.length == 0) {
                makeDialog('??????????????? ??????????????????');
              } else {
                if (_emailTextController.value.text != "") {
                  var bytes = utf8.encode(_pwTextController.value.text);
                  var digest = sha1.convert(bytes);
                  if (user.pw == digest.toString()) {
                    if (user.email != _emailTextController.value.text) {
                      User upUser = User(user.name, user.id, user.pw,
                          _emailTextController.value.text, user.profileImg, user.createTime);
                      reference
                          .child(id)
                          .child(user.key)
                          .set(upUser.toJson())
                          .then((_) {
                        Navigator.of(context).pop();
                      });
                    } else {
                      makeDialog('?????? ???????????? ???????????????');
                    }
                  } else {
                    makeDialog('??????????????? ???????????? ????????????');
                  }
                } else {
                  makeDialog('????????? ???????????? ??????????????????');
                }
              }
            },
            child: Text(
              '??????',
              style: TextStyle(color: Colors.white),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Center(
            child: Column(
              children: <Widget>[
                Container(
                  height: 200,
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(55.0),
                        child: _profileImgUrl!=null? Image.network(
                          _profileImgUrl,
                          width: 90,
                          height: 90,
                          fit: BoxFit.fill,
                        ):Container(),
                      ),
                      FlatButton(
                          onPressed: () => setState(() {
                            _selectPhotoButton(context);
                          }),
                          child: Text(
                            '????????? ?????? ?????????',
                            style: TextStyle(color: Colors.blue),
                          ))
                    ],
                    mainAxisAlignment: MainAxisAlignment.center,
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          SizedBox(
                            width: 70,
                            child: Text('??????'),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width - 110,
                            child: Text(user.name),
                          ),
                        ],
                        //mainAxisAlignment: MainAxisAlignment.center,
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      Row(
                        children: <Widget>[
                          SizedBox(
                            width: 70,
                            child: Text('?????????'),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width - 110,
                            child: Text(user.id),
                          ),
                        ],
                        //mainAxisAlignment: MainAxisAlignment.center,
                      ),
                      Row(
                        children: <Widget>[
                          SizedBox(
                            width: 70,
                            child: Text('?????????'),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width - 110,
                            child: TextField(
                              controller: _emailTextController,
                              maxLines: 1,
                              decoration: InputDecoration(
                                hintText: user.email,
                              ),
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                        //mainAxisAlignment: MainAxisAlignment.center,
                      ),
                      Row(
                        children: <Widget>[
                          SizedBox(
                            width: 70,
                            child: Text('????????????'),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width - 110,
                            child: TextField(
                              controller: _pwTextController,
                              obscureText: true,
                              maxLines: 1,
                              decoration: InputDecoration(
                                hintText: '??????????????? ??????????????????',
                              ),
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                        //mainAxisAlignment: MainAxisAlignment.center,
                      ),
                      Row(
                        children: <Widget>[
                          SizedBox(
                            width: 70,
                          ),
                          FlatButton(
                              onPressed: () {
                                Navigator.of(context).pushReplacementNamed(
                                    '/pwChange',
                                    arguments: id);
                              },
                              child: Text(
                                '???????????? ??????',
                                style: TextStyle(),
                              ))
                        ],
                        //mainAxisAlignment: MainAxisAlignment.center,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                          child: FlatButton(
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text('${user.id}???'),
                                        content: Text('???????????? ???????????????????'),
                                        actions: <Widget>[
                                          FlatButton(
                                              onPressed: () {
                                                reference
                                                    .child(user.id)
                                                    .remove()
                                                    .then((_) {
                                                  Navigator.of(context).pop();
                                                  Navigator.of(context).pop();
                                                  Navigator.of(context)
                                                      .pushReplacementNamed(
                                                    '/login',
                                                  );
                                                });
                                              },
                                              child: Text('???')),
                                          FlatButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: Text('?????????'))
                                        ],
                                      );
                                    });
                              },
                              child: Text(
                                '?????? ????????????',
                                style: TextStyle(color: Colors.blue),
                              ))),
                      Container(
                          child: FlatButton(
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text('${user.id}???'),
                                        content: Text('???????????? ???????????????????'),
                                        actions: <Widget>[
                                          FlatButton(
                                              onPressed: () {
                                                storage.delete(key: "login");
                                                Navigator.of(context).pop();//???????????????
                                                Navigator.of(context).pop();//???????????????
                                                Navigator.of(context)
                                                    .pushReplacementNamed(
                                                  '/login',
                                                );//?????????????????? -> ????????? ????????????
                                              },
                                              child: Text('???')),
                                          FlatButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: Text('?????????'))
                                        ],
                                      );
                                    });

                              },
                              child: Text(
                                '????????????',
                                style: TextStyle(color: Colors.blue),
                              ))),
                    ],
                  ),
                ),
              ],
              //mainAxisAlignment: MainAxisAlignment.center,
            ),
          ),
        ),
      ),
    );
  }

  void _selectPhotoButton(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            child: Wrap(
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.photo_camera),
                  title: Text("?????? ??????"),
                  onTap: () => _uploadImageToStorage(ImageSource.camera),
                ),
                ListTile(
                  leading: Icon(Icons.photo),
                  title: Text("???????????? ????????????"),
                  onTap: () => _uploadImageToStorage(ImageSource.gallery),
                ),
              ],
            ),
          );
        });
  }


  Future<void> _uploadImageToStorage(ImageSource source) async {
    File file = await ImagePicker.pickImage(source: source);
    setState(() => _image = file);

    // ????????? ????????? ???????????? ????????? ???????????? ??????.
    StorageReference storageReference = _firebaseStorage
        .ref()
        .child("assets/${id}_${DateTime.now().millisecondsSinceEpoch}.png");

    // ?????? ?????????
    StorageUploadTask storageUploadTask = storageReference.putFile(_image);

    // ?????? ????????? ???????????? ??????
    await storageUploadTask.onComplete;

    // ???????????? ????????? URL ??????
    String downloadURL = await storageReference.getDownloadURL();

    setState(() {
      _profileImgUrl=downloadURL;
    });

    //profileImg??? db??? update
    User upUser = User(
        user.name,
        user.id,
        user.pw,
        user.email,
        downloadURL,
        user.createTime);

    reference
        .child(id)
        .child(user.key)
        .set(upUser.toJson())
        .then((_) {
      print('???????????? ??????');
      Navigator.of(context).pop();
    });
  }

  void makeDialog(String text) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text(text),
          );
        });
  }
}
