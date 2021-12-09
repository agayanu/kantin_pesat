import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kantin_pesat/locator.dart';
import 'package:kantin_pesat/services/alert_service.dart';
import 'package:kantin_pesat/services/cons_service.dart';
import 'package:kantin_pesat/services/navigation_service.dart';
import 'package:http/http.dart' as http;
import 'package:kantin_pesat/services/storage_service.dart';

class MenuShowView extends StatefulWidget {
  const MenuShowView(
      {Key? key,
      required this.idUser,
      required this.idMenu,
      required this.idLapak,
      required this.nama,
      required this.namaLapak,
      required this.harga,
      required this.gambar})
      : super(key: key);
  final String idUser;
  final String idMenu;
  final String idLapak;
  final String nama;
  final String namaLapak;
  final int harga;
  final String gambar;
  @override
  _MenuShowViewState createState() => _MenuShowViewState();
}

class _MenuShowViewState extends State<MenuShowView> {
  final NavigationService _navigationService = locator<NavigationService>();
  final StorageService _storageService = locator<StorageService>();
  final AlertService _alertService = locator<AlertService>();
  final client = http.Client();
  final f = NumberFormat.currency(
      locale: "id_ID", customPattern: '#,###', decimalDigits: 0);

  late String idUser = widget.idUser;
  late String idMenu = widget.idMenu;
  late String idLapak = widget.idLapak;
  late String nama = widget.nama;
  late String namaLapak = widget.namaLapak;
  late int harga = widget.harga;
  late String gambar = widget.gambar;
  bool _isFirstLoadRunning = false;
  String token = "";

  void tambahKeranjang(BuildContext context) async {
    setState(() {
      _isFirstLoadRunning = true;
    });

    try {
      token = (await _storageService.getString('token'))!;
      const menuUrl = '$baseURL/keranjang-pembeli-store';
      if (kDebugMode) {
        print('[Menu URL] $menuUrl');
      }
      final response = await client.post(Uri.parse(menuUrl), headers: {
        'Authorization': 'Bearer $token',
      }, body: {
        'id_user': idUser,
        'id_lapak': idLapak,
        'id_menu': idMenu,
      });
      if (kDebugMode) {
        print(response.body);
      }
      Map<String, dynamic> res = jsonDecode(response.body);

      if (res['success'] == true) {
        _alertService.showAlert(
            context, 'Berhasil', res['message'], _navigationService.pop);
      }
      if (res['success'] == false) {
        _alertService.showAlert(
            context, 'Gagal', res['message'], _navigationService.pop);
      }
    } catch (err) {
      if (kDebugMode) {
        print('[Menu] $err');
      }
      _alertService.showAlert(
          context, 'Error', '[Keranjang] $err', _navigationService.pop);
    }

    setState(() {
      _isFirstLoadRunning = false;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(nama),
      ),
      body: _isFirstLoadRunning
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              margin: const EdgeInsets.only(top: 30, left: 20, right: 20),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 30),
                        width: size.width * 1,
                        height: size.height * 0.4,
                        child: Card(
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          child: Image.network(imageURL + gambar),
                        ),
                      ),
                    ),
                    RichText(
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      text: TextSpan(
                        text: nama,
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                    ),
                    Text(namaLapak),
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      child: RichText(
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        text: TextSpan(
                          text: 'Rp. ' + f.format(harga),
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.only(
                              left: 10, right: 10, top: 3, bottom: 3),
                          margin: const EdgeInsets.only(right: 10, top: 30),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.0),
                            color: Colors.white,
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Row(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(right: 5),
                                child: Icon(
                                  Icons.favorite,
                                  color: Colors.grey.shade300,
                                  size: 18,
                                ),
                              ),
                              const Text(
                                'Suka',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.only(
                                  left: 10, right: 10, top: 3, bottom: 3),
                              margin: const EdgeInsets.only(right: 10, top: 30),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20.0),
                                color: Colors.white,
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(right: 5),
                                    child: const Icon(
                                      Icons.warning,
                                      color: Colors.grey,
                                      size: 18,
                                    ),
                                  ),
                                  const Text(
                                    'Report',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.only(
                                  left: 10, right: 10, top: 3, bottom: 3),
                              margin: const EdgeInsets.only(right: 10, top: 30),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20.0),
                                color: Colors.white,
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(right: 5),
                                    child: const Icon(
                                      Icons.share,
                                      color: Colors.grey,
                                      size: 18,
                                    ),
                                  ),
                                  const Text(
                                    'Share',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Expanded(
                      child: Align(
                        alignment: FractionalOffset.bottomCenter,
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              textStyle: const TextStyle(fontSize: 16),
                              shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20)),
                              ),
                            ),
                            onPressed: () {
                              tambahKeranjang(context);
                            },
                            child: const Text('Tambah ke keranjang'),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
