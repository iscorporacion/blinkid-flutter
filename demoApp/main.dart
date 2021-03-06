import 'package:blinkid_flutter/blinkid_flutter.dart';
import 'package:flutter/material.dart';
import "dart:convert";

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  String _resultString = "";
  String _fullDocumentFrontImageBase64 = "";
  String _fullDocumentBackImageBase64 = "";
  String _faceImageBase64 = "";

  Future<void> scan() async {
    String license;
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      license = "sRwAAAEVY29tLm1pY3JvYmxpbmsuc2FtcGxl1BIcP+dpSuS/38LVOsaLNXzaiMXsGsDI9HoCvvTwW0ELAiAcBZdB/nLLlJdH4YxsICG1tc+42mh1/syML14kCuZrvHHUiGx1lwGyZGtAa65HTgU85+aXJwt95XSSiuiLjPXw6ue37/oqp3oHtw0P2xXzUA+jX6czpIynFScNPEInu81f1ylj15sbHxhmy/hPEvHEBd26myGxhjpM/JHX8jmrvmT02/ouLUWSbixVELFClQMBZ96X8omCq8l6SzuZJdRTcSxmpuj+";
    } else if (Theme.of(context).platform == TargetPlatform.android) {
      license = "";
    }

    var idRecognizer = BlinkIdCombinedRecognizer();
    idRecognizer.returnFullDocumentImage = true;
    idRecognizer.returnFaceImage = true;

    BlinkIdOverlaySettings settings = BlinkIdOverlaySettings();

    var results = await BlinkIDFlutter.scanWithCamera(RecognizerCollection([idRecognizer]), settings, license);

    if (!mounted) return;

    if (results.length == 0) return;
    if (results[0] is BlinkIdCombinedRecognizerResult) {
      BlinkIdCombinedRecognizerResult result = results[0];

      if (result.mrzResult.documentType == MrtdDocumentType.Passport) {
        _resultString = getPassportResultString(result);
      } else if (result.mrzResult.documentType == MrtdDocumentType.IdentityCard) {
        _resultString = getIdResultString(result);
      }

      setState(() {
        _resultString = _resultString;
        _fullDocumentFrontImageBase64 = result.fullDocumentFrontImage;
        _fullDocumentBackImageBase64 = result.fullDocumentBackImage;
        _faceImageBase64 = result.faceImage;
      });
    }
  }

  String getIdResultString(BlinkIdCombinedRecognizerResult result) {
    return
      "First name: ${result.firstName}\n"
      "Last name: ${result.lastName}\n"
      "Address: ${result.address}\n"
      "Document number: ${result.documentNumber}\n"
      "Sex: ${result.sex}\n"
      "Date of birth: ${result.dateOfBirth.day}."
        "${result.dateOfBirth.month}."
        "${result.dateOfBirth.year}\n"
      "Date of issue: ${result.dateOfIssue.day}."
        "${result.dateOfIssue.month}."
        "${result.dateOfIssue.year}\n"
      "Date of expiry: ${result.dateOfExpiry.day}."
        "${result.dateOfExpiry.month}."
        "${result.dateOfExpiry.year}\n";
  }

  String getPassportResultString(BlinkIdCombinedRecognizerResult result) {
    return
      "First name: ${result.mrzResult.secondaryId}\n"
      "Last name: ${result.mrzResult.primaryId}\n"
      "Document number: ${result.mrzResult.documentNumber}\n"
      "Sex: ${result.mrzResult.gender}\n"
      "Date of birth: ${result.mrzResult.dateOfBirth.day}."
        "${result.mrzResult.dateOfBirth.month}."
        "${result.mrzResult.dateOfBirth.year}\n"
      "Date of expiry: ${result.mrzResult.dateOfExpiry.day}."
        "${result.mrzResult.dateOfExpiry.month}."
        "${result.mrzResult.dateOfExpiry.year}\n";
  }

  @override
  Widget build(BuildContext context) {
    Widget fullDocumentFrontImage = Container();
    if (_fullDocumentFrontImageBase64 != null &&
        _fullDocumentFrontImageBase64 != "") {
      fullDocumentFrontImage = Column(
        children: <Widget>[
          Text("Document Front Image:"),
          Image.memory(
            Base64Decoder().convert(_fullDocumentFrontImageBase64),
            height: 180,
            width: 350,
          )
        ],
      );
    }

    Widget fullDocumentBackImage = Container();
    if (_fullDocumentBackImageBase64 != null &&
        _fullDocumentBackImageBase64 != "") {
      fullDocumentBackImage = Column(
        children: <Widget>[
          Text("Document Back Image:"),
          Image.memory(
            Base64Decoder().convert(_fullDocumentBackImageBase64),
            height: 180,
            width: 350,
          )
        ],
      );
    }

    Widget faceImage = Container();
    if (_faceImageBase64 != null && _faceImageBase64 != "") {
      faceImage = Column(
        children: <Widget>[
          Text("Face Image:"),
          Image.memory(
            Base64Decoder().convert(_faceImageBase64),
            height: 150,
            width: 100,
          )
        ],
      );
    }

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("BlinkID Sample"),
        ),
        body: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                Padding(
                    child: RaisedButton(
                      child: Text("Scan"),
                      onPressed: () => scan(),
                    ),
                    padding: EdgeInsets.only(bottom: 16.0)),
                Text(_resultString),
                fullDocumentFrontImage,
                fullDocumentBackImage,
                faceImage,
              ],
            )),
      ));
  }
}
