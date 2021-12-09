import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kantin_pesat/locator.dart';
import 'package:kantin_pesat/services/cons_service.dart';
import 'package:kantin_pesat/services/storage_service.dart';
import 'package:http/http.dart' as http;
import 'package:kantin_pesat/ui/views/menu_show_view.dart';

class MakananView extends StatefulWidget {
  const MakananView({Key? key}) : super(key: key);

  @override
  _MakananViewState createState() => _MakananViewState();
}

class _MakananViewState extends State<MakananView> {
  final StorageService _storageService = locator<StorageService>();
  final client = http.Client();
  late ScrollController _controller;
  final f = NumberFormat.currency(
      locale: "id_ID", customPattern: '#,###', decimalDigits: 0);
  int _page = 1;
  bool _hasNextPage = true;
  bool _isFirstLoadRunning = false;
  bool _isLoadMoreRunning = false;
  String token = "";
  String idUser = "";
  List _menus = [];

  void _loadMenu() async {
    setState(() {
      _isFirstLoadRunning = true;
    });

    try {
      token = (await _storageService.getString('token'))!;
      idUser = (await _storageService.getString('id'))!;
      final menuUrl = '$baseURL/menu?page=$_page';
      if (kDebugMode) {
        print('[Menu URL] $menuUrl');
      }
      final response = await client.get(Uri.parse(menuUrl), headers: {
        'Authorization': 'Bearer $token',
      });
      if (kDebugMode) {
        print(response.body);
      }
      Map<String, dynamic> map = json.decode(response.body);

      setState(() {
        _menus = map["data"];
        idUser;
      });
    } catch (err) {
      if (kDebugMode) {
        print('[Lapak] $err');
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
        final menuUrl = '$baseURL/menu?page=$_page';
        if (kDebugMode) {
          print('[MenuLoad URL] $menuUrl');
        }
        final response = await client.get(Uri.parse(menuUrl), headers: {
          'Authorization': 'Bearer $token',
        });
        if (kDebugMode) {
          print(response.body);
        }

        Map<String, dynamic> map = json.decode(response.body);
        final List fetchedPosts = map["data"];
        if (fetchedPosts.isNotEmpty) {
          setState(() {
            _menus.addAll(fetchedPosts);
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
    _loadMenu();
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
        title: const Text('Makanan'),
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
                      itemCount: _menus.length,
                      itemBuilder: (_, index) => InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MenuShowView(
                                  idUser: idUser,
                                  idMenu: _menus[index]['id_menu'].toString(),
                                  idLapak: _menus[index]['id_lapak'].toString(),
                                  nama: _menus[index]['nama'],
                                  namaLapak: _menus[index]['nama_lapak'],
                                  harga: _menus[index]['harga'],
                                  gambar: _menus[index]['gambar']),
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
                                  imageURL + _menus[index]['gambar'],
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
                                          text: _menus[index]['nama'],
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
                                          text: _menus[index]['nama_lapak'],
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
                                              f.format(_menus[index]['harga']),
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
