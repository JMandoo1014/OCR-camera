import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  XFile? _image; //이미지를 담을 변수 선언
  final ImagePicker picker = ImagePicker(); //ImagePicker 초기화
  String scannedText = "";  // textRecognizer로 인식된 텍스트를 담을 String

  //이미지를 가져오는 함수
  Future getImage(ImageSource imageSource) async {
    //pickedFile에 ImagePicker로 가져온 이미지가 담긴다.
    final XFile? pickedFile = await picker.pickImage(source: imageSource);
    if (pickedFile != null) {
      setState(() {
        _image = XFile(pickedFile.path); //가져온 이미지를 _image에 저장
      });
      getRecognizedText(_image!); // 이미지를 가져온 뒤 텍스트 인식 실행
    }
  }

  void getRecognizedText(XFile image) async {
    // XFile 이미지를 InputImage 이미지로 변환
    final InputImage inputImage = InputImage.fromFilePath(image.path);

    // textRecognizer 초기화, 이때 script에 인식하고자하는 언어를 인자로 넘겨줌
    // ex) 영어는 script: TextRecognitionScript.latin, 한국어는 script: TextRecognitionScript.korean
    final textRecognizer =
    GoogleMlKit.vision.textRecognizer(script: TextRecognitionScript.latin);

    // 이미지의 텍스트 인식해서 recognizedText에 저장
    RecognizedText recognizedText =
    await textRecognizer.processImage(inputImage);

    // Release resources
    await textRecognizer.close();

    // 인식한 텍스트 정보를 scannedText에 저장
    scannedText = "";
    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        scannedText = scannedText + line.text + "\n";
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("Camera Test")),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 30, width: double.infinity),
            _buildPhotoArea(),
            _buildRecognizedText(),
            SizedBox(height: 20),
            _buildButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoArea() {
    return _image != null
        ? Container(
      width: 300,
      height: 300,
      child: Image.file(File(_image!.path)), //가져온 이미지를 화면에 띄워주는 코드
    )
        : Container(
      width: 300,
      height: 300,
      color: Colors.grey,
    );
  }

  Widget _buildRecognizedText() {
    return Text(scannedText); //getRecognizedText()에서 얻은 scannedText 값 출력
  }

  Widget _buildButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () {
            getImage(ImageSource.camera); //getImage 함수를 호출해서 카메라로 찍은 사진 가져오기
          },
          child: Text("카메라"),
        ),
        SizedBox(width: 30),
        ElevatedButton(
          onPressed: () {
            getImage(ImageSource.gallery); //getImage 함수를 호출해서 갤러리에서 사진 가져오기
          },
          child: Text("갤러리"),
        ),
      ],
    );
  }
}