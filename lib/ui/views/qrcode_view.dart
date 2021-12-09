import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kantin_pesat/locator.dart';
import 'package:kantin_pesat/services/cons_service.dart';
import 'package:kantin_pesat/services/storage_service.dart';
import 'package:kantin_pesat/ui/views/keranjang_pembeli_view.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:http/http.dart' as http;

class QrcodeView extends StatefulWidget {
  const QrcodeView({Key? key, required this.bayar, required this.jmlMenu})
      : super(key: key);
  final int bayar;
  final int jmlMenu;
  @override
  _QrcodeViewState createState() => _QrcodeViewState();
}

class _QrcodeViewState extends State<QrcodeView> {
  final StorageService _storageService = locator<StorageService>();
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;
  final client = http.Client();
  late int bayar = widget.bayar;
  late int jmlMenu = widget.jmlMenu;
  bool _isFirstLoadRunning = false;
  bool dataJson = false;
  String token = "";
  // int idLapak = 0;
  late Map<String, dynamic> scanDataJson;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // var scanArea = (MediaQuery.of(context).size.width < 400 ||
    //         MediaQuery.of(context).size.height < 400)
    //     ? 150.0
    //     : 300.0;
    final size = MediaQuery.of(context).size;
    var scanArea = size.width * 0.7;
    return Scaffold(
      body: _isFirstLoadRunning
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: <Widget>[
                Expanded(
                  flex: 5,
                  child: QRView(
                    key: qrKey,
                    onQRViewCreated: _onQRViewCreated,
                    overlay: QrScannerOverlayShape(
                        borderColor: Colors.red,
                        borderRadius: 10,
                        borderLength: 30,
                        borderWidth: 10,
                        cutOutSize: scanArea),
                  ),
                ),
                // Expanded(
                //   flex: 1,
                //   child: Center(
                //     child: (result != null)
                //         ? Text(
                //             'Barcode Type: ${describeEnum(result!.format)}   Data: ${result!.code}')
                //         : const Text('Scan a code'),
                //   ),
                // )
              ],
            ),
    );
  }

  void _loadQr(qrCode) async {
    setState(() {
      _isFirstLoadRunning = true;
    });

    var decodeSucceeded = false;

    try {
      scanDataJson = jsonDecode(qrCode!);
      decodeSucceeded = true;
    } on FormatException catch (e) {
      if (kDebugMode) {
        print('[QR] $e');
      }
    }

    if (decodeSucceeded == true) {
      try {
        token = (await _storageService.getString('token'))!;
        final qrId = scanDataJson['qr_id'];
        const qrUrl = '$baseURL/transaksi-pembeli-qrcode';
        if (kDebugMode) {
          print('[QR URL] $qrUrl');
        }
        final response = await client.post(Uri.parse(qrUrl), headers: {
          'Authorization': 'Bearer $token',
        }, body: {
          'qr_id': qrId,
        });
        if (kDebugMode) {
          print(response.body);
        }
        Map<String, dynamic> res = json.decode(response.body);

        if (res['success'] == true) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => KeranjangPembeliView(
                qrCode: res['id_lapak'],
                bayarConfirm: bayar,
                jmlMenuConfirm: jmlMenu,
                dataJson: null,
                dataEmpty: null,
              ),
            ),
          );
        }
        if (res['success'] == false) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => KeranjangPembeliView(
                qrCode: null,
                bayarConfirm: bayar,
                jmlMenuConfirm: jmlMenu,
                dataJson: null,
                dataEmpty: false,
              ),
            ),
          );
        }
      } catch (err) {
        if (kDebugMode) {
          print('[QR] $err');
        }
      }
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => KeranjangPembeliView(
            qrCode: null,
            bayarConfirm: bayar,
            jmlMenuConfirm: jmlMenu,
            dataJson: false,
            dataEmpty: null,
          ),
        ),
      );
    }

    setState(() {
      _isFirstLoadRunning = false;
    });
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      controller.pauseCamera();
      final String? qrCode = scanData.code;
      _loadQr(qrCode);
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
