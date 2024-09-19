import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final GlobalKey<SfSignaturePadState> signatureGlobalKey = GlobalKey();
  Color selectedColor = Colors.black;
  String selectedLevel = '1';
  var listLevel = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10'];

  @override
  void initState() {
    super.initState();
  }

  void _clearCanvas() {
    signatureGlobalKey.currentState!.clear();
  }

  void _saveImage() async {
    final data = await signatureGlobalKey.currentState!.toImage(pixelRatio: 3.0);
    final bytes = await data.toByteData(format: ui.ImageByteFormat.png);

    Directory? directory;
    if (Platform.isAndroid) {
      directory = await getExternalStorageDirectory();
    } else if (Platform.isIOS) {
      directory = await getApplicationDocumentsDirectory();
    }

    if (directory != null) {
      File file = File('${directory.path}/signature.png');
      await file.writeAsBytes(bytes!.buffer.asUint8List());

      await GallerySaver.saveImage(file.path);

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (BuildContext context) =>
              SignatureImage(
                  bytes: bytes.buffer.asUint8List()
              ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check_circle_outline,
              color: Colors.white,
            ),
            SizedBox(
                width: 10
            ),
            Text('Ups, Failed to access external storage directory!',
                style: TextStyle(
                    color: Colors.white
                )
            ),
          ],
        ),
        backgroundColor: Colors.red,
        shape: StadiumBorder(),
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  void _openColorPicker() async {
    bool pickedColor = await ColorPicker(
      color: selectedColor,
      onColorChanged: (Color newColor) {
        setState(() {
          selectedColor = newColor;
        });
      },
      width: 40,
      height: 40,
      borderRadius: 20,
      spacing: 10,
      runSpacing: 10,
      heading: const Text('Select Color'),
      subheading: const Text('Select a color for your widget'),
      wheelDiameter: 200,
      wheelWidth: 20,

    ).showPickerDialog(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Signature Pad"),
        ),
        body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                  padding: const EdgeInsets.all(10),
                  child: Container(
                    height: 360,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey)
                      ),
                      child: SfSignaturePad(
                          key: signatureGlobalKey,
                          backgroundColor: Colors.white,
                          strokeColor: selectedColor,
                          minimumStrokeWidth: 1,
                          maximumStrokeWidth: (double.parse(selectedLevel) + 2)
                      )
                  )
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(10, 20, 0, 0),
                child: Text('Thickness Level',
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.black
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.0),
                    border: Border.all(
                        color: Colors.grey,
                        style: BorderStyle.solid,
                        width: 1
                    ),
                  ),
                  child: DropdownButton<String>(
                    dropdownColor: Colors.white,
                    hint: const Text('Select Level:',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        )
                    ),
                    value: selectedLevel,
                    onChanged: (value) {
                      setState(() {
                        selectedLevel = value.toString();
                      });
                    },
                    items: listLevel.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value.toString(),
                        child: Text(value),
                      );
                    }).toList(),
                    icon: const Icon(Icons.arrow_drop_down),
                    iconSize: 24,
                    elevation: 16,
                    style: const TextStyle(color: Colors.black, fontSize: 14),
                    underline: Container(
                      height: 2,
                      color: Colors.transparent,
                    ),
                    isExpanded: true,
                  ),
                ),
              ),
              const SizedBox(
                  height: 10
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _openColorPicker,
                      child: const Text('Change Color'),
                    ),
                    ElevatedButton(
                      onPressed: _saveImage,
                      child: const Text('Save Image'),
                    ),
                    ElevatedButton(
                      onPressed: _clearCanvas,
                      child: const Text('Clear'),
                    )
                  ]
              ),
            ],
        )
    );
  }
}

class SignatureImage extends StatelessWidget {
  final Uint8List bytes;

  const SignatureImage({super.key, required this.bytes});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Image Saved in Gallery')
      ),
      body: Center(
        child: Container(
          color: Colors.grey[300],
          child: Image.memory(bytes),
        ),
      ),
    );
  }
}
