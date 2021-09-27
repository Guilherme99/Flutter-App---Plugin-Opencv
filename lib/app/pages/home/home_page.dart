import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:flutter_modular/flutter_modular.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:opencv/core/core.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:opencv/opencv.dart';
//import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  const HomePage({ Key? key }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}
enum sourcePicture{ camera, gallery }
enum AppState {
  free,
  cropped,
}
class _HomePageState extends State<HomePage> {

  late AppState state;
  String _platformVersion = 'Unknown';
  dynamic res;
  File image = File('');
  String saveImage = '';
  Image imageNew = Image.asset('');
  File? file ;
  bool preloaded = false;
  bool loaded = false;

  List<String> urls = [
    "https://i.pinimg.com/564x/54/e2/ae/54e2aeefa75d031813ec56f6b3efc9ad.jpg",
    "https://raw.githubusercontent.com/opencv/opencv/master/samples/data/sudoku.png",
    "https://raw.githubusercontent.com/opencv/opencv/master/samples/data/left.jpg",
    "https://raw.githubusercontent.com/opencv/opencv/master/samples/data/left01.jpg",
    "https://raw.githubusercontent.com/opencv/opencv/master/samples/data/right01.jpg",
    "https://raw.githubusercontent.com/opencv/opencv/master/samples/data/smarties.png",
  ];
  int urlIndex = 0;
  String dropdownValue = 'None';

  @override
  void initState() {
    super.initState();
    state = AppState.free;
    initPlatformState();
    _requestPermission();
  }

   Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await OpenCV.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }
   Future<void> runAFunction(String functionName) async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      switch (functionName) {
        case 'blur':
          res = await ImgProc.blur(
              await file!.readAsBytes(), [45, 45], [20, 30], Core.borderReflect);
          break;
        case 'GaussianBlur':
          res =
              await ImgProc.gaussianBlur(await file!.readAsBytes(), [45, 45], 0);
          break;
        case 'medianBlur':
          res = await ImgProc.medianBlur(await file!.readAsBytes(), 45);
          break;
        case 'bilateralFilter':
          res = await ImgProc.bilateralFilter(
              await file!.readAsBytes(), 15, 80, 80, Core.borderConstant);
          break;
        case 'boxFilter':
          res = await ImgProc.boxFilter(await file!.readAsBytes(), 50, [45, 45],
              [-1, -1], true, Core.borderConstant);
          break;
        case 'sqrBoxFilter':
          res =
              await ImgProc.sqrBoxFilter(await file!.readAsBytes(), -1, [1, 1]);
          break;
        case 'filter2D':
          res = await ImgProc.filter2D(await file!.readAsBytes(), -1, [2, 2]);
          break;
        case 'dilate':
          res = await ImgProc.dilate(await file!.readAsBytes(), [2, 2]);
          break;
        case 'erode':
          res = await ImgProc.erode(await file!.readAsBytes(), [2, 2]);
          break;
        case 'morphologyEx':
          res = await ImgProc.morphologyEx(
              await file!.readAsBytes(), ImgProc.morphTopHat, [5, 5]);
          break;
        case 'pyrUp':
          res = await ImgProc.pyrUp(
              await file!.readAsBytes(), [563 * 2, 375 * 2], Core.borderDefault);
          break;
        case 'pyrDown':
          res = await ImgProc.pyrDown(await file!.readAsBytes(),
              [563 ~/ 2.toInt(), 375 ~/ 2.toInt()], Core.borderDefault);
          break;
        case 'pyrMeanShiftFiltering':
          res = await ImgProc.pyrMeanShiftFiltering(
              await file!.readAsBytes(), 10, 15);
          break;
        case 'threshold':
          res = await ImgProc.threshold(
              await file!.readAsBytes(), 80, 255, ImgProc.threshBinary);
          break;
        case 'adaptiveThreshold':
          res = await ImgProc.adaptiveThreshold(await file!.readAsBytes(), 125,
              ImgProc.adaptiveThreshMeanC, ImgProc.threshBinary, 11, 12);
          break;
        case 'copyMakeBorder':
          res = await ImgProc.copyMakeBorder(
              await file!.readAsBytes(), 20, 20, 20, 20, Core.borderConstant);
          break;
        case 'sobel':
          res = await ImgProc.sobel(await file!.readAsBytes(), -1, 1, 1);
          break;
        case 'scharr':
          res = await ImgProc.scharr(
              await file!.readAsBytes(), ImgProc.cvSCHARR, 0, 1);
          break;
        case 'laplacian':
          res = await ImgProc.laplacian(await file!.readAsBytes(), 10);
          break;
        case 'distanceTransform':
          res = await ImgProc.threshold(
              await file!.readAsBytes(), 80, 255, ImgProc.threshBinary);
          res = await ImgProc.distanceTransform(await res, ImgProc.distC, 3);
          break;
        case 'resize':
          res = await ImgProc.resize(
              await file!.readAsBytes(), [500, 500], 0, 0, ImgProc.interArea);
          break;
        case 'applyColorMap':
          res = await ImgProc.applyColorMap(
              await file!.readAsBytes(), ImgProc.colorMapHot);
          break;
        case 'houghLines':
          res = await ImgProc.canny(await file!.readAsBytes(), 50, 200);
          res = await ImgProc.houghLines(await res,
              threshold: 300, lineColor: "#ff0000");
          break;
        case 'houghLinesProbabilistic':
          res = await ImgProc.canny(await file!.readAsBytes(), 50, 200);
          res = await ImgProc.houghLinesProbabilistic(await res,
              threshold: 50,
              minLineLength: 50,
              maxLineGap: 10,
              lineColor: "#ff0000");
          break;
        case 'houghCircles':
          res = await ImgProc.cvtColor(await file!.readAsBytes(), 6);
          res = await ImgProc.houghCircles(await res,
              method: 3,
              dp: 2.1,
              minDist: 0.1,
              param1: 150,
              param2: 100,
              minRadius: 0,
              maxRadius: 0);
          break;
        case 'warpPerspectiveTransform':
          // 4 points are represented as:
          // P1         P2
          //
          //
          // P3         P4
          // and stored in a linear array as:
          // sourcePoints = [P1.x, P1.y, P2.x, P2.y, P3.x, P3.y, P4.x, P4.y]
          res = await ImgProc.warpPerspectiveTransform(await file!.readAsBytes(),
              sourcePoints: [113, 137, 260, 137, 138, 379, 271, 340],
              destinationPoints: [0, 0, 612, 0, 0, 459, 612, 459],
              outputSize: [612, 459]);
          break;
        case 'grabCut':
          res = await ImgProc.grabCut(await file!.readAsBytes(),
              px: 0, py: 0, qx: 400, qy: 400, itercount: 1);
          break;
        default:
          print("No function selected");
          break;
      }
      
      setState(() {
        imageNew = Image.memory(res);
        saveImage = uint8ListTob64(res);
        loaded = true;
      });
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    if (!mounted) return;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
          appBar: AppBar(
            title: const Text('Flutter App'),
            
          ),
          
          floatingActionButton: 
          preloaded
                  ? 
           Column(
             mainAxisAlignment: MainAxisAlignment.end,
             crossAxisAlignment: CrossAxisAlignment.end,
             children: [
              FloatingActionButton(
                onPressed: () async {

                  if(saveImage!=''){
                    var result = saveImage.split(',');
                    File imageFile =  await _createFileFromString(result[1]);
                  //  print(imageFile);
                    _saveImage(imageFile);

                    _showMyDialog();
                  }
                  return ;
                },
                child: Icon(Icons.save),
          ) ,
          SizedBox(height: 10,),
          FloatingActionButton(
                onPressed: () {
                  emptyValues();
                },
                child: Icon(Icons.refresh),
          ),
             ],
           ) : 
          FloatingActionButton.extended(
            onPressed: () {},
            label: Container(
              child: Row(
                children: [
                  new IconButton(
                            onPressed: () {
                              if (state == AppState.free) {
                                _imageSelected(sourcePicture.camera);
                              } else
                                return null;
                            },
                              icon: Icon(Icons.camera_alt, color: Colors.white,)),
                              Text('|', style: TextStyle(fontSize: 22),),
                              new IconButton(
                      onPressed: () {
                        if (state == AppState.free) {
                          _imageSelected(sourcePicture.gallery);
                        } else
                          return null;
                      }, 
                      icon: Icon(Icons.photo_library, color: Colors.white,)),
                ],
              ),
                ),
            ),
          body: Center(
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                /* Center(
                  child: Text('Running on: $_platformVersion\n'),
                ), */
              Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  children: [
               /*    Container(
                    decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    /* child: 
                          state == AppState.cropped?
                    (
                      Container()
                    )
                    :
                    Padding(padding: EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Selecionar Imagem", style: TextStyle(color: Colors.white, fontSize: 15),),
                          ],
                        ),
                         Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            new IconButton(
                                onPressed: () {
                                  if (state == AppState.free) {
                                    _imageSelected(sourcePicture.camera);
                                  } else
                                    return null;
                                },
                                 icon: Icon(Icons.camera_alt, color: Colors.white,)),
                            new IconButton(
                              onPressed: () {
                                if (state == AppState.free) {
                                  _imageSelected(sourcePicture.gallery);
                                } else
                                  return null;
                              }, 
                              icon: Icon(Icons.photo_library, color: Colors.white,)),
                          ],
                        ),
                      ],
                    )                  
                    ) , */
                    ), */
                    preloaded
                    ? 
                    Column(
                      children: [
                        Container(
                          margin: EdgeInsets.only(bottom: 10),
                          
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Imagem Fonte:", style: TextStyle(color: Colors.black, fontSize: 16),),
                            ],
                          ),
                        ),
                        Container(
                           decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                            gradient: LinearGradient(
                                begin: FractionalOffset.topCenter,
                                end: FractionalOffset.bottomCenter,
                                colors: [
                                  Colors.red.withOpacity(0.6),
                                  Colors.red.withOpacity(0.6),
                                ],
                                stops: [
                                  0.0,
                                  1.0
                                ])),
                          width: MediaQuery.of(context).size.width,
                          /* height: MediaQuery.of(context).size.height*0.5, */
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                             ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: Image.file(image),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                    : Container(
                      margin: EdgeInsets.only(top: 40),
                      decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                      gradient: LinearGradient(
                          begin: FractionalOffset.topCenter,
                          end: FractionalOffset.bottomCenter,
                          colors: [
                            Colors.red.withOpacity(0.6),
                            Colors.red,
                          ],
                          stops: [
                            0.0,
                            1.0
                          ])),
                      width: 300,
                      height: MediaQuery.of(context).size.height*0.3,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(onPressed: () => {}, icon: Icon(Icons.visibility_off, color: Colors.white,)),
                            Text("Nenhuma Imagem Selecionada", style: TextStyle(color: Colors.white),),
                          ],
                        ),
                      ),
                    ),              
                ],
                ),
                ),
                preloaded
                    ? 
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Filtro para a Imagem Fonte:", 
                          style: TextStyle(color: Colors.black.withOpacity(1.0), fontSize: 15, decorationStyle: TextDecorationStyle.wavy),
                        ),
                      ],
                    ), 
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        DropdownButton<String>(
                          value: dropdownValue,
                          icon: Icon(Icons.arrow_downward),
                          iconSize: 24,
                          elevation: 16,
                          underline: Container(
                            color: Colors.grey,
                            height: 2,
                          ),
                          onChanged: (String? newValue) {
                            setState(() {
                              dropdownValue = newValue!;
                            });
                          },
                          items: <String>[
                            'None',
                            'blur',
                            'GaussianBlur',
                            'medianBlur',
                            'bilateralFilter',
                            'boxFilter',
                            'sqrBoxFilter',
                            'filter2D',
                            'dilate',
                            'erode',
                            'morphologyEx',
                            'pyrUp',
                            'pyrDown',
                            'pyrMeanShiftFiltering',
                            'threshold',
                            'adaptiveThreshold',
                            'copyMakeBorder',
                            'sobel',
                            'scharr',
                            'laplacian',
                            'distanceTransform',
                            'resize',
                            'applyColorMap',
                            'houghLines',
                            'houghLinesProbabilistic',
                            'houghCircles',
                            'warpPerspectiveTransform',
                            'grabCut'
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    ElevatedButton(
                          onPressed: () {
                            runAFunction(dropdownValue);
                          },
                          child: Text('Run'),
                        ),
                  ],
                ) : Container(),
                loaded ? 
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text("Imagem Processada:"),
                        ],
                      ),
                      
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: imageNew
                      ) 
                    ],
                  ),
                ) : Container(),
              ],
            ),
          ));
  }

  void _imageSelected(sourcePicture sourceImage) async {
    
    
    XFile? image2 = await ImagePicker().pickImage(
        source: sourceImage == sourcePicture.camera ? ImageSource.camera : ImageSource.gallery );

    if (image2 != null) {
      File? croppedImage = await ImageCropper.cropImage(
          sourcePath: image2.path,
          aspectRatioPresets: Platform.isAndroid
              ? [
                  CropAspectRatioPreset.square,
                  CropAspectRatioPreset.ratio3x2,
                  CropAspectRatioPreset.original,
                  CropAspectRatioPreset.ratio4x3,
                  CropAspectRatioPreset.ratio16x9
                ]
              : [
                  CropAspectRatioPreset.original,
                  CropAspectRatioPreset.square,
                  CropAspectRatioPreset.ratio3x2,
                  CropAspectRatioPreset.ratio4x3,
                  CropAspectRatioPreset.ratio5x3,
                  CropAspectRatioPreset.ratio5x4,
                  CropAspectRatioPreset.ratio7x5,
                  CropAspectRatioPreset.ratio16x9
                ],
          androidUiSettings: AndroidUiSettings(
              toolbarTitle: 'Cortador',
              toolbarColor: Colors.red,
              toolbarWidgetColor: Colors.white,
              activeControlsWidgetColor: Colors.red,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false));


          setState(() {
            image = croppedImage! ;
            file = croppedImage;
            preloaded = true;
          });

          if(sourceImage==sourcePicture.camera){
            _saveImage(image2);
          }

          _afterCropImage();
     } else {
     return ;
    } 
  }


  void _saveImage(image) async {
    var bytes;
    Uri myUri = Uri.parse(image.path);
    File originalImageFile = new File.fromUri(myUri);
    await originalImageFile.readAsBytes().then((value) {
      bytes = Uint8List.fromList(value);
      print('leitura dos bytes completa');
    }).catchError((onError) {
      print('Mensagem de erro:' + onError.toString());
    });
    final result = await ImageGallerySaver.saveImage(Uint8List.fromList(bytes));
   
    print(result);
  }

  _requestPermission() async {
    
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
    ].request();

    final info = statuses[Permission.storage].toString();
    print(info);
  }

  void _afterCropImage() {
    setState(() {
      state = AppState.cropped;
    });
    //intervalStatusPages();
    //Navigator.of(context).pop();
  }
  void emptyValues(){
    setState(() {
      preloaded = false;
      image = File('');
      state = AppState.free;
      imageNew = Image.asset('');
      loaded = false;
    });
  }

    Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Salvar Imagem'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('A imagem foi salva no seu dispositivo!'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Fechar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  String uint8ListTob64(Uint8List uint8list) {
    String base64String = base64Encode(uint8list);
    String header = "data:image/png;base64,";
    return header + base64String;
  }
  Future<File> _createFileFromString(String imageBase64) async {
    final encodedStr = imageBase64;
    Uint8List bytes = base64.decode(encodedStr);
    String dir = (await getApplicationDocumentsDirectory()).path;
    File file = File(
        "$dir/" + DateTime.now().millisecondsSinceEpoch.toString() + ".png");
    await file.writeAsBytes(bytes);
    return file;
  }
}