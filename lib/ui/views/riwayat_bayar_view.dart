import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:kantin_pesat/locator.dart';
import 'package:kantin_pesat/services/cons_service.dart';
import 'package:kantin_pesat/services/storage_service.dart';
import 'package:http/http.dart' as http;
import 'package:kantin_pesat/ui/views/detail_riwayat_view.dart';

class RiwayatBayarView extends StatefulWidget {
  const RiwayatBayarView({Key? key}) : super(key: key);

  @override
  _RiwayatBayarViewState createState() => _RiwayatBayarViewState();
}

class _RiwayatBayarViewState extends State<RiwayatBayarView> {
  final StorageService _storageService = locator<StorageService>();
  final a = initializeDateFormatting('id_ID', null);
  final f = NumberFormat.currency(
      locale: "id_ID", customPattern: '#,###', decimalDigits: 0);
  final d = DateFormat('dd MMMM yyyy', 'id_ID');
  final client = http.Client();
  late ScrollController _controller;
  bool _isFirstLoadRunning = false;
  bool _hasNextPage = true;
  bool _isLoadMoreRunning = false;
  int _page = 1;
  String token = "";
  List riwayat = [];

  void _loadRiwayat() async {
    setState(() {
      _isFirstLoadRunning = true;
    });

    try {
      token = (await _storageService.getString('token'))!;
      final riwayatUrl = '$baseURL/keranjang-pembeli-riwayat-bayar?page=$_page';
      if (kDebugMode) {
        print('[Riwayat URL] $riwayatUrl');
      }
      final response = await client.get(Uri.parse(riwayatUrl), headers: {
        'Authorization': 'Bearer $token',
      });
      if (kDebugMode) {
        print(response.body);
      }
      Map<String, dynamic> map = json.decode(response.body);

      setState(() {
        riwayat = map["data"];
      });
    } catch (err) {
      if (kDebugMode) {
        print('[Riwayat] $err');
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
        final riwayatUrl =
            '$baseURL/keranjang-pembeli-riwayat-bayar?page=$_page';
        if (kDebugMode) {
          print('[RiwayatLoad URL] $riwayatUrl');
        }
        final response = await client.get(Uri.parse(riwayatUrl), headers: {
          'Authorization': 'Bearer $token',
        });
        if (kDebugMode) {
          print(response.body);
        }

        Map<String, dynamic> map = json.decode(response.body);
        final List fetchedPosts = map["data"];
        if (fetchedPosts.isNotEmpty) {
          setState(() {
            riwayat.addAll(fetchedPosts);
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
    _loadRiwayat();
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
    return _isFirstLoadRunning
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    _hasNextPage = true;
                    initState();
                  },
                  child: ListView.builder(
                    itemCount: riwayat.length,
                    itemBuilder: (_, index) => Card(
                      child: Container(
                        margin: const EdgeInsets.only(
                            left: 10, right: 10, bottom: 10),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.store),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          margin:
                                              const EdgeInsets.only(left: 5),
                                          child: Text(
                                            riwayat[index]['nama_lapak'],
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          margin:
                                              const EdgeInsets.only(left: 5),
                                          child: Text(
                                            d.format(DateTime.parse(
                                                riwayat[index]['created_at'])),
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.black45),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const Text(
                                  'Sudah Bayar',
                                  style: TextStyle(
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(top: 10),
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10)),
                                    child: Image.network(
                                      imageURL + riwayat[index]['gambar'],
                                      fit: BoxFit.cover,
                                      height: 80,
                                    ),
                                  ),
                                ),
                                Column(
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      height: 30,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          textStyle:
                                              const TextStyle(fontSize: 12),
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(20)),
                                          ),
                                        ),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  DetailRiwayatView(
                                                idRiwayat: riwayat[index]['id'],
                                                namaRiwayat: riwayat[index]
                                                    ['nama_lapak'],
                                                jmlRiwayat: riwayat[index]
                                                        ['jml_menu']
                                                    .toString(),
                                              ),
                                            ),
                                          );
                                        },
                                        child: const Text('Detail'),
                                      ),
                                    ),
                                    Table(
                                      columnWidths: const <int,
                                          TableColumnWidth>{
                                        0: IntrinsicColumnWidth(),
                                        1: IntrinsicColumnWidth(),
                                        2: IntrinsicColumnWidth(),
                                      },
                                      defaultVerticalAlignment:
                                          TableCellVerticalAlignment.middle,
                                      children: <TableRow>[
                                        TableRow(
                                          children: <Widget>[
                                            const Text(
                                              'Total item',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.black45,
                                              ),
                                            ),
                                            const Text(
                                              ' : ',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.black45,
                                              ),
                                            ),
                                            Text(
                                              riwayat[index]['jml_menu']
                                                  .toString(),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        TableRow(
                                          children: <Widget>[
                                            const Text(
                                              'Total bayar',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.black45,
                                              ),
                                            ),
                                            const Text(
                                              ' : ',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.black45,
                                              ),
                                            ),
                                            Text(
                                              'Rp.' +
                                                  f.format(riwayat[index]
                                                      ['total_harga']),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
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
                    child: Text('Sudah tidak ada riwayat'),
                  ),
                ),
            ],
          );
  }
}
