// import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kantin_pesat/locator.dart';
import 'package:kantin_pesat/services/cons_service.dart';
import 'package:kantin_pesat/services/navigation_service.dart';
import 'package:kantin_pesat/services/storage_service.dart';
import 'package:http/http.dart' as http;
import 'package:kantin_pesat/ui/route_name.dart';

class ProfilPembeliView extends StatefulWidget {
  const ProfilPembeliView({Key? key}) : super(key: key);

  @override
  _ProfilPembeliViewState createState() => _ProfilPembeliViewState();
}

class _ProfilPembeliViewState extends State<ProfilPembeliView> {
  final StorageService _storageService = locator<StorageService>();
  final NavigationService _navigationService = locator<NavigationService>();
  final client = http.Client();
  bool _isFirstLoadRunning = false;
  String idUser = "";
  String nama = "";
  String email = "";
  String gambar = "";
  String token = "";
  bool gambarAda = false;

  void _loadProfil() async {
    setState(() {
      _isFirstLoadRunning = true;
    });
    idUser = (await _storageService.getString('id'))!;
    nama = (await _storageService.getString('name'))!;
    email = (await _storageService.getString('email'))!;
    gambar = (await _storageService.getString('gambar'))!;

    final pathUrl = imageURL + gambar;

    final response = await client.get(Uri.parse(pathUrl));

    if (response.statusCode == 200) {
      gambarAda = true;
    } else {
      gambarAda = false;
    }

    setState(() {
      _isFirstLoadRunning = false;
    });
  }

  @override
  void initState() {
    _loadProfil();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profilku'),
      ),
      body: _isFirstLoadRunning
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: () async {
                if (kDebugMode) {
                  print('refresh');
                }
                initState();
              },
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 20, left: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (gambarAda == true)
                                CircleAvatar(
                                  radius: 40,
                                  backgroundImage:
                                      NetworkImage(imageURL + gambar),
                                ),
                              if (gambarAda == false)
                                CircleAvatar(
                                  backgroundColor: Colors.blue.shade400,
                                  child: Text(
                                    nama[0],
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              Container(
                                margin: const EdgeInsets.only(left: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      nama,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(email),
                                    Container(
                                      padding: const EdgeInsets.only(
                                          left: 3,
                                          right: 10,
                                          top: 3,
                                          bottom: 3),
                                      margin: const EdgeInsets.only(top: 10),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                        color: Colors.black,
                                      ),
                                      constraints: const BoxConstraints(
                                        minWidth: 16,
                                        minHeight: 16,
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            height: 20,
                                            width: 20,
                                            padding: const EdgeInsets.all(1),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20.0),
                                              color: Colors.green,
                                            ),
                                            child: const Icon(
                                              Icons.star,
                                              size: 17,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Container(
                                            margin:
                                                const EdgeInsets.only(left: 5),
                                            child: const Text(
                                              'Warga',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Container(
                            margin: const EdgeInsets.only(right: 15),
                            child: const Icon(Icons.edit),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 40, left: 10),
                      child: const Text(
                        'Akun',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 10, left: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.help),
                              Container(
                                margin: const EdgeInsets.only(left: 10),
                                child: const Text(
                                  'Bantuan & Laporan Saya',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            margin: const EdgeInsets.only(right: 10),
                            child: const Icon(
                              Icons.arrow_forward_ios,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(
                      height: 20,
                      thickness: 1,
                      indent: 40,
                    ),
                    InkWell(
                      onTap: () {
                        _navigationService.navigateTo(aturAkunViewRoute);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(left: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.person),
                                Container(
                                  margin: const EdgeInsets.only(left: 10),
                                  child: const Text(
                                    'Atur Akun',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              margin: const EdgeInsets.only(right: 10),
                              child: const Icon(
                                Icons.arrow_forward_ios,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(
                      height: 20,
                      thickness: 1,
                      indent: 40,
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 20, left: 10),
                      child: const Text(
                        'Info lainnya',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 10, left: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.security),
                              Container(
                                margin: const EdgeInsets.only(left: 10),
                                child: const Text(
                                  'Kebijakan Privasi',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            margin: const EdgeInsets.only(right: 10),
                            child: const Icon(
                              Icons.arrow_forward_ios,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(
                      height: 20,
                      thickness: 1,
                      indent: 40,
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.note),
                              Container(
                                margin: const EdgeInsets.only(left: 10),
                                child: const Text(
                                  'Ketentuan Layanan',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            margin: const EdgeInsets.only(right: 10),
                            child: const Icon(
                              Icons.arrow_forward_ios,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(
                      height: 20,
                      thickness: 1,
                      indent: 40,
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.person),
                              Container(
                                margin: const EdgeInsets.only(left: 10),
                                child: const Text(
                                  'Beri Rating',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            margin: const EdgeInsets.only(right: 10),
                            child: const Icon(
                              Icons.arrow_forward_ios,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(
                      height: 20,
                      thickness: 1,
                      indent: 40,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
