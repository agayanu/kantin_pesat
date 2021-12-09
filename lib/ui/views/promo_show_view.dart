import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kantin_pesat/locator.dart';
import 'package:kantin_pesat/services/cons_service.dart';
import 'package:kantin_pesat/services/storage_service.dart';
import 'package:http/http.dart' as http;
import 'package:kantin_pesat/ui/views/menu_show_view.dart';

class PromoShowView extends StatefulWidget {
  const PromoShowView({Key? key, required this.id, required this.nama})
      : super(key: key);
  final int id;
  final String nama;

  @override
  _PromoShowViewState createState() => _PromoShowViewState();
}

class _PromoShowViewState extends State<PromoShowView> {
  final StorageService _storageService = locator<StorageService>();

  bool _isFirstLoadRunning = false;
  bool _hasNextPage = true;
  bool _isLoadMoreRunning = false;
  final client = http.Client();
  late ScrollController _controller;
  final f = NumberFormat.currency(
      locale: "id_ID", customPattern: '#,###', decimalDigits: 0);
  int _page = 1;
  String token = "";
  String idUser = "";
  List _promos = [];

  late int id = widget.id;
  late String nama = widget.nama;

  void _loadPromo() async {
    setState(() {
      _isFirstLoadRunning = true;
    });

    try {
      token = (await _storageService.getString('token'))!;
      idUser = (await _storageService.getString('id'))!;
      final promoUrl = '$baseURL/promo-show/$id?page=$_page';
      if (kDebugMode) {
        print('[Promo URL] $promoUrl');
      }
      final response = await client.get(Uri.parse(promoUrl), headers: {
        'Authorization': 'Bearer $token',
      });
      if (kDebugMode) {
        print(response.body);
      }
      Map<String, dynamic> map = json.decode(response.body);

      setState(() {
        _promos = map["data"];
        idUser;
      });
    } catch (err) {
      if (kDebugMode) {
        print('[Promo] $err');
      }
    }

    setState(() {
      _isFirstLoadRunning = false;
    });
  }

  void _loadMore() async {
    if (_hasNextPage == true &&
        _isFirstLoadRunning == false &&
        _isLoadMoreRunning == false &&
        _controller.position.extentAfter < 300) {
      setState(() {
        _isLoadMoreRunning = true;
      });
      _page += 1;
      try {
        token = (await _storageService.getString('token'))!;
        final promoUrl = '$baseURL/promo-show/$id?page=$_page';
        if (kDebugMode) {
          print('[PromoLoad URL] $promoUrl');
        }
        final response = await client.get(Uri.parse(promoUrl), headers: {
          'Authorization': 'Bearer $token',
        });
        if (kDebugMode) {
          print(response.body);
        }

        Map<String, dynamic> map = json.decode(response.body);
        final List fetchedPosts = map["data"];
        if (fetchedPosts.isNotEmpty) {
          setState(() {
            _promos.addAll(fetchedPosts);
          });
        } else {
          setState(() {
            _hasNextPage = false;
          });
        }
      } catch (err) {
        if (kDebugMode) {
          print(err);
        }
      }

      setState(() {
        _isLoadMoreRunning = false;
      });
    }
  }

  @override
  void initState() {
    _loadPromo();
    _controller = ScrollController()..addListener(_loadMore);
    super.initState();
  }

  @override
  void dispose() {
    _controller.removeListener(_loadMore);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Promo $nama'),
      ),
      body: _isFirstLoadRunning
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      if (kDebugMode) {
                        print('refresh');
                      }
                      _page = 1;
                      _hasNextPage = true;
                      _isLoadMoreRunning = false;
                      initState();
                    },
                    child: ListView.builder(
                      controller: _controller,
                      itemCount: _promos.length,
                      itemBuilder: (_, index) => InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MenuShowView(
                                  idUser: idUser,
                                  idMenu: _promos[index]['id'].toString(),
                                  idLapak:
                                      _promos[index]['id_lapak'].toString(),
                                  nama: _promos[index]['nama'],
                                  namaLapak: _promos[index]['nama_lapak'],
                                  harga: _promos[index]['harga'],
                                  gambar: _promos[index]['gambar']),
                            ),
                          );
                        },
                        child: Card(
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(10)),
                                child: Image.network(
                                  imageURL + _promos[index]['gambar'],
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
                                      margin: const EdgeInsets.only(
                                          left: 10, top: 10),
                                      child: RichText(
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                        text: TextSpan(
                                          text: _promos[index]['nama'],
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(
                                          left: 10, top: 10),
                                      child: RichText(
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                        text: TextSpan(
                                          text: _promos[index]['nama_lapak'],
                                          style: TextStyle(
                                            color: Colors.grey.shade700,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(
                                          left: 10, top: 10),
                                      child: RichText(
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                        text: TextSpan(
                                          text: 'Rp. ' +
                                              f.format(_promos[index]['harga']),
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
                ),
                if (_isLoadMoreRunning == true)
                  const Padding(
                    padding: EdgeInsets.only(top: 10, bottom: 40),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                if (_hasNextPage == false)
                  Container(
                    padding: const EdgeInsets.only(top: 30, bottom: 40),
                    color: Colors.amber,
                    child: const Center(
                      child:
                          Text('Sudah tidak ada menu lagi, coba kategori lain'),
                    ),
                  ),
              ],
            ),
    );
  }
}
