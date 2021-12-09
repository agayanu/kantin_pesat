import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kantin_pesat/locator.dart';
import 'package:kantin_pesat/services/cons_service.dart';
import 'package:kantin_pesat/services/storage_service.dart';
import 'package:http/http.dart' as http;
import 'package:kantin_pesat/ui/views/menu_show_view.dart';

class DetailRiwayatView extends StatefulWidget {
  const DetailRiwayatView(
      {Key? key,
      required this.idRiwayat,
      required this.namaRiwayat,
      required this.jmlRiwayat})
      : super(key: key);
  final int idRiwayat;
  final String namaRiwayat;
  final String jmlRiwayat;

  @override
  _DetailRiwayatViewState createState() => _DetailRiwayatViewState();
}

class _DetailRiwayatViewState extends State<DetailRiwayatView> {
  final StorageService _storageService = locator<StorageService>();
  final f = NumberFormat.currency(
      locale: "id_ID", customPattern: '#,###', decimalDigits: 0);
  final client = http.Client();
  late int idRiwayat = widget.idRiwayat;
  late String namaRiwayat = widget.namaRiwayat;
  late String jmlRiwayat = widget.jmlRiwayat;
  bool _isFirstLoadRunning = false;
  String token = "";
  String idUser = "";
  List riwayat = [];

  void _loadDetailRiwayat() async {
    setState(() {
      _isFirstLoadRunning = true;
    });

    try {
      token = (await _storageService.getString('token'))!;
      idUser = (await _storageService.getString('id'))!;
      const riwayatDUrl = '$baseURL/keranjang-pembeli-riwayat';
      if (kDebugMode) {
        print('[RiwayatD URL] $riwayatDUrl');
      }
      final response = await client.post(Uri.parse(riwayatDUrl), headers: {
        'Authorization': 'Bearer $token',
      }, body: {
        'id_riwayat': idRiwayat.toString(),
      });
      if (kDebugMode) {
        print(response.body);
      }

      setState(() {
        riwayat = jsonDecode(response.body);
      });
    } catch (err) {
      if (kDebugMode) {
        print('[RiwayatD] $err');
      }
    }

    setState(() {
      _isFirstLoadRunning = false;
    });
  }

  @override
  void initState() {
    _loadDetailRiwayat();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(namaRiwayat + ' (' + jmlRiwayat + ')'),
      ),
      body: _isFirstLoadRunning
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: () async {
                initState();
              },
              child: ListView.builder(
                itemCount: riwayat.length,
                itemBuilder: (_, index) => InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MenuShowView(
                            idUser: idUser,
                            idMenu: riwayat[index]['id_menu'].toString(),
                            idLapak: riwayat[index]['id_lapak'].toString(),
                            nama: riwayat[index]['nama_menu'],
                            namaLapak: riwayat[index]['nama_lapak'],
                            harga: riwayat[index]['harga'],
                            gambar: riwayat[index]['gambar']),
                      ),
                    );
                  },
                  child: Card(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                          child: Image.network(
                            imageURL + riwayat[index]['gambar'],
                            fit: BoxFit.cover,
                            height: 120,
                            width: 120,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin:
                                    const EdgeInsets.only(left: 10, top: 10),
                                child: RichText(
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  text: TextSpan(
                                    text: riwayat[index]['nama_menu'],
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                margin:
                                    const EdgeInsets.only(left: 10, top: 10),
                                child: RichText(
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  text: TextSpan(
                                    text: riwayat[index]['nama_lapak'],
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                margin:
                                    const EdgeInsets.only(left: 10, top: 10),
                                child: RichText(
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  text: TextSpan(
                                    text: 'Rp. ' +
                                        f.format(riwayat[index]['harga']),
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
