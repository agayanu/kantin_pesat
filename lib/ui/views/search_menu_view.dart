import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kantin_pesat/locator.dart';
import 'package:kantin_pesat/services/cons_service.dart';
import 'package:kantin_pesat/services/storage_service.dart';
import 'package:http/http.dart' as http;
import 'package:kantin_pesat/ui/views/menu_show_view.dart';

class SearchMenuView extends StatefulWidget {
  const SearchMenuView({Key? key}) : super(key: key);

  @override
  _SearchMenuViewState createState() => _SearchMenuViewState();
}

class _SearchMenuViewState extends State<SearchMenuView> {
  final StorageService _storageService = locator<StorageService>();
  final controller = TextEditingController();
  final client = http.Client();
  final f = NumberFormat.currency(
      locale: "id_ID", customPattern: '#,###', decimalDigits: 0);
  Timer? debouncer;
  bool _isFirstLoadRunning = false;
  String token = "";
  String idUser = "";
  List _menusSearch = [];

  @override
  void dispose() {
    debouncer?.cancel();
    super.dispose();
  }

  void debounce(
    VoidCallback callback, {
    Duration duration = const Duration(milliseconds: 1000),
  }) {
    if (debouncer != null) {
      debouncer!.cancel();
    }

    debouncer = Timer(duration, callback);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue.shade200,
        foregroundColor: Colors.black,
        title: ListTile(
          title: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Mau makan apa hari ini?',
              hintStyle: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontStyle: FontStyle.italic,
              ),
              border: InputBorder.none,
            ),
            style: const TextStyle(
              color: Colors.black,
            ),
            onChanged: searchList,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              controller.clear();
            },
            icon: const Icon(Icons.cancel),
          )
        ],
      ),
      body: _isFirstLoadRunning
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _menusSearch.length,
                    itemBuilder: (_, index) => InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MenuShowView(
                                idUser: idUser,
                                idMenu:
                                    _menusSearch[index]['id_menu'].toString(),
                                idLapak:
                                    _menusSearch[index]['id_lapak'].toString(),
                                nama: _menusSearch[index]['nama'],
                                namaLapak: _menusSearch[index]['nama_lapak'],
                                harga: _menusSearch[index]['harga'],
                                gambar: _menusSearch[index]['gambar']),
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
                                imageURL + _menusSearch[index]['gambar'],
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
                                        text: _menusSearch[index]['nama'],
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
                                        text: _menusSearch[index]['nama_lapak'],
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
                                            f.format(
                                                _menusSearch[index]['harga']),
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
              ],
            ),
    );
  }

  void searchList(String query) async => debounce(() async {
        setState(() {
          _isFirstLoadRunning = true;
        });
        if (query.isEmpty) {
          setState(() {
            _menusSearch = [];
            idUser = "";
          });
        } else {
          try {
            token = (await _storageService.getString('token'))!;
            idUser = (await _storageService.getString('id'))!;
            final menuUrl = '$baseURL/menu?search=' + query;
            if (kDebugMode) {
              print('[MenuSearch URL] $menuUrl');
            }
            final response = await client.get(Uri.parse(menuUrl), headers: {
              'Authorization': 'Bearer $token',
            });
            if (kDebugMode) {
              print(response.body);
            }
            Map<String, dynamic> map = jsonDecode(response.body);

            setState(() {
              _menusSearch = map["data"];
              idUser;
            });
          } catch (err) {
            if (kDebugMode) {
              print('[MenuSearch] $err');
            }
          }
        }

        if (!mounted) return;

        setState(() {
          _isFirstLoadRunning = false;
        });
      });
}
