//#region Imports
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:random_words/random_words.dart';
import 'package:translator/translator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wallpaperplugin/wallpaperplugin.dart';
//#endregion

class MainScreen extends StatefulWidget {
  static const String route = '/';
  @override
  _MainScreenState createState() => _MainScreenState();
}

enum Language { pl, de, nl, fr, es, se, ru, pt, no }

class _MainScreenState extends State<MainScreen> {
//#region Variables
  final Color mainColor = Color(0xFF005E45);
  Color textColor = Colors.black;
  int fontSize = 20;

  List words = [];
  List translatedWords = [];

  String textOnImage = "";
  int wordsAmount = 10;
  int wordsFrom = 0;

  static File _image;
  String language = "pl";
  String fullPath;

  final translator = GoogleTranslator();
  GlobalKey _globalKey = new GlobalKey(); //#endregion

  @override
  Widget build(BuildContext context) {
    return Container(
      child: new Scaffold(
        appBar: new AppBar(
          title: new Text('Learn By Seeing'),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.info,
                color: Colors.white,
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Informations'),
                      content: SingleChildScrollView(
                        child: Column(
                          children: <Widget>[
                            Text(
                                "App use google translator and takes first available meaning. For sureness in translation and more definitions check each word standalone."),
                            SizedBox(height: 15),
                            Text(
                                "Uploaded image should be previously cropped and adjusted to desired size. If you having trouble with size first screenshot your wallpaper."),
                            SizedBox(height: 15),
                            Text("Most popular words are available till 5000."),
                            SizedBox(height: 15),
                            Text(
                                "If image is not saving check permissions in settings."),
                            SizedBox(height: 15),
                            Text(
                                "App created overnight. Content bugs, errors and is heavily simplified. Feel free to edit, adjust and enhance."),
                            Row(children: [
                              Text("Source code: "),
                              GestureDetector(
                                  child: Text("github",
                                      style: TextStyle(color: Colors.blue)),
                                  onTap: () {
                                    launch(
                                        "https://github.com/LessIsMoreMK/WordWallpaperPlacer");
                                  }),
                            ]),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              RepaintBoundary(
                key: _globalKey,
                child: GestureDetector(
                  onTap: () {
                    _showPicker(context);
                  },
                  child: _image != null
                      ? ClipRRect(
                          child: Stack(
                            alignment: Alignment.center,
                            children: <Widget>[
                              Image.file(
                                _image,
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height,
                                fit: BoxFit.fill,
                              ),
                              Container(
                                height: MediaQuery.of(context).size.height,
                                alignment: Alignment.center,
                                child: Text(
                                  textOnImage,
                                  textAlign: TextAlign.justify,
                                  style: TextStyle(
                                    fontSize: fontSize.toDouble(),
                                    color: textColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(color: Colors.grey[200]),
                          width: MediaQuery.of(context).size.width,
                          height: 300,
                          child: Icon(
                            Icons.camera_alt,
                            color: Colors.grey[800],
                          ),
                        ),
                ),
              ),
              Row(
                children: [
                  SizedBox(width: 10),
                  MaterialButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    color: mainColor,
                    minWidth: 140,
                    padding: EdgeInsets.symmetric(
                      horizontal: 15.0,
                      vertical: 20.0,
                    ),
                    onPressed: () {
                      if (words.isNotEmpty) words.clear();
                      words.addAll(generateAdjective().take(wordsAmount));
                      translateWords();
                    },
                    child: Text(
                      'Generate\nNouns',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "Words\nAmount:",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  NumberPicker.integer(
                    initialValue: wordsAmount,
                    minValue: 5,
                    maxValue: 50,
                    step: 5,
                    onChanged: (value) => setState(() => wordsAmount = value),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SizedBox(width: 10),
                  MaterialButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    color: mainColor,
                    minWidth: 140,
                    padding: EdgeInsets.symmetric(
                      horizontal: 15.0,
                      vertical: 20.0,
                    ),
                    onPressed: () {
                      if (words.isNotEmpty) words.clear();
                      words.addAll(generateAdjective().take(wordsAmount));
                      translateWords();
                    },
                    child: Text(
                      'Generate\nAdjectives',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "Text\nColor:",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 50,
                    height: 50,
                    child: MaterialButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50.0),
                      ),
                      color: textColor,
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Select a color'),
                              content: SingleChildScrollView(
                                child: SlidePicker(
                                  pickerColor: textColor,
                                  onColorChanged: changeColor,
                                  paletteType: PaletteType.rgb,
                                  enableAlpha: false,
                                  displayThumbColor: true,
                                  showLabel: false,
                                  showIndicator: true,
                                  indicatorBorderRadius:
                                      const BorderRadius.vertical(
                                    top: const Radius.circular(25.0),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  SizedBox(width: 25),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SizedBox(width: 10),
                  MaterialButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    color: mainColor,
                    minWidth: 140,
                    padding: EdgeInsets.symmetric(
                      horizontal: 15.0,
                      vertical: 20.0,
                    ),
                    onPressed: () {
                      if (words.isNotEmpty) words.clear();
                      words.addAll(
                          all.getRange(wordsFrom, wordsFrom + wordsAmount));
                      translateWords();
                    },
                    child: Text(
                      'Generate \nMost Popular',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "Most Popular\nStart Point:",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  NumberPicker.integer(
                    initialValue: wordsFrom,
                    minValue: 0,
                    maxValue: 5000,
                    step: 5,
                    onChanged: (value) => setState(() => wordsFrom = value),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SizedBox(width: 10),
                  MaterialButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    color: mainColor,
                    minWidth: 140,
                    padding: EdgeInsets.symmetric(
                      horizontal: 15.0,
                      vertical: 20.0,
                    ),
                    onPressed: () {
                      saveImage();
                    },
                    child: Text(
                      'Save\nImage',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "Language: ",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  MaterialButton(
                    child: Text(language),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return SimpleDialog(
                            title: const Text('Select Language'),
                            children: <Widget>[
                              SimpleDialogOption(
                                onPressed: () {
                                  Navigator.pop(context, Language.pl);
                                  setState(() => language = "pl");
                                },
                                child: const Text('Polish'),
                              ),
                              SimpleDialogOption(
                                onPressed: () {
                                  Navigator.pop(context, Language.de);
                                  setState(() => language = "de");
                                },
                                child: const Text('German'),
                              ),
                              SimpleDialogOption(
                                onPressed: () {
                                  Navigator.pop(context, Language.nl);
                                  setState(() => language = "nl");
                                },
                                child: const Text('Dutch'),
                              ),
                              SimpleDialogOption(
                                onPressed: () {
                                  Navigator.pop(context, Language.fr);
                                  setState(() => language = "fr");
                                },
                                child: const Text('French'),
                              ),
                              SimpleDialogOption(
                                onPressed: () {
                                  Navigator.pop(context, Language.es);
                                  setState(() => language = "sp");
                                },
                                child: const Text('Spanish'),
                              ),
                              SimpleDialogOption(
                                onPressed: () {
                                  Navigator.pop(context, Language.se);
                                  setState(() => language = "se");
                                },
                                child: const Text('Swedish'),
                              ),
                              SimpleDialogOption(
                                onPressed: () {
                                  Navigator.pop(context, Language.ru);
                                  setState(() => language = "ru");
                                },
                                child: const Text('Russian'),
                              ),
                              SimpleDialogOption(
                                onPressed: () {
                                  Navigator.pop(context, Language.pt);
                                  setState(() => language = "pt");
                                },
                                child: const Text('Portuguese'),
                              ),
                              SimpleDialogOption(
                                onPressed: () {
                                  Navigator.pop(context, Language.es);
                                  setState(() => language = "es");
                                },
                                child: const Text('Spanish'),
                              ),
                              SimpleDialogOption(
                                onPressed: () {
                                  Navigator.pop(context, Language.no);
                                  setState(() => language = "no");
                                },
                                child: const Text('Norwegian'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                  SizedBox(width: 10),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SizedBox(width: 10),
                  MaterialButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    color: mainColor,
                    minWidth: 140,
                    padding: EdgeInsets.symmetric(
                      horizontal: 15.0,
                      vertical: 20.0,
                    ),
                    onPressed: () {
                      setWallpaper();
                    },
                    child: Text(
                      'Save And Set\nAs Wallpaper',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "Font\Size:",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  NumberPicker.integer(
                    initialValue: fontSize,
                    minValue: 10,
                    maxValue: 35,
                    step: 1,
                    onChanged: (value) => setState(() => fontSize = value),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

//#region Functions
  void changeColor(Color color) => setState(() => textColor = color);

  void translateWords() async {
    if (translatedWords.isNotEmpty) translatedWords.clear();
    textOnImage = "";

    for (int i = 0; i < words.length; i++) {
      var translatedWord = await translator.translate(words[i].toString(),
          from: 'en', to: language);

      translatedWords.add(translatedWord.toString());

      setState(() {
        textOnImage += words[i].toString() + " - " + translatedWords[i] + "\n";
      });
    }
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Photo Library'),
                      onTap: () {
                        _imgFromGallery();
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () {
                      _imgFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  void _imgFromCamera() async {
    File image = await ImagePicker.pickImage(
        source: ImageSource.camera, imageQuality: 50);

    setState(() {
      _image = image;
    });
  }

  void _imgFromGallery() async {
    File image = await ImagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 50);

    setState(() {
      _image = image;
    });
  }

  Future<Uint8List> saveImage() async {
    try {
      RenderRepaintBoundary boundary =
          _globalKey.currentContext.findRenderObject();
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      var pngBytes = byteData.buffer.asUint8List();
      //var bs64 = base64Encode(pngBytes);
      String dir = (await getApplicationDocumentsDirectory()).path;
      fullPath = '$dir/WordWallpaperPlacer.png';
      File file = File(fullPath);
      await file.writeAsBytes(pngBytes);
      GallerySaver.saveImage(fullPath);
      return pngBytes;
    } catch (e) {
      print(e);
    }
  }

  void setWallpaper() {
    saveImage();
    try {
      Wallpaperplugin.setAutoWallpaper(localFile: fullPath);
    } on PlatformException {
      print("Platform exception");
    }
  }
//#endregion
}
