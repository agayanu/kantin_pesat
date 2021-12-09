import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:kantin_pesat/locator.dart';
import 'package:kantin_pesat/services/cons_service.dart';
import 'package:kantin_pesat/services/navigation_service.dart';
import 'package:kantin_pesat/services/storage_service.dart';
import 'package:http/http.dart' as http;
import 'package:kantin_pesat/ui/route_name.dart';
import 'package:kantin_pesat/ui/views/detail_riwayat_view.dart';

class RiwayatSelesaiView extends StatefulWidget {
  const RiwayatSelesaiView({Key? key}) : super(key: key);

  @override
  _RiwayatSelesaiViewState createState() => _RiwayatSelesaiViewState();
}

class _RiwayatSelesaiViewState extends State<RiwayatSelesaiView> {
  final StorageService _storageService = locator<StorageService>();
  final NavigationService _navigationService = locator<NavigationService>();

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
      final riwayatUrl =
          '$baseURL/keranjang-pembeli-riwayat-selesai?page=$_page';
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
            '$baseURL/keranjang-pembeli-riwayat-selesai?page=$_page';
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

  void _beliLagiYes({idRiwayat}) async {
    setState(() {
      _isFirstLoadRunning = true;
    });

    try {
      token = (await _storageService.getString('token'))!;
      const beliLagiUrl = '$baseURL/keranjang-pembeli-riwayat-beli-lagi';
      if (kDebugMode) {
        print('[BeliLagi URL] $beliLagiUrl');
      }
      final response = await client.post(Uri.parse(beliLagiUrl), headers: {
        'Authorization': 'Bearer $token',
      }, body: {
        'id_riwayat': idRiwayat.toString(),
      });
      if (kDebugMode) {
        print(response.body);
      }
      Map<String, dynamic> res = json.decode(response.body);
      if (res["success"] == true) {
        _navigationService.replaceTo(keranjangPembeliViewRoute);
      }
      if (res["success"] == false) {
        showCheckoutAlert(
            context, 'Gagal', res['message'], _navigationService.pop);
      }
    } catch (err) {
      showCheckoutAlert(context, 'Gagal', '$err', _navigationService.pop);
      if (kDebugMode) {
        print('[BeliLagi] $err');
      }
    }

    setState(() {
      _isFirstLoadRunning = false;
    });
  }

  void confirmBeliLagi(BuildContext context, String title, String desc,
      VoidCallback onYes, VoidCallback onNo) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) => AlertDialog(
        title: Text(title),
        content: Text(desc),
        actions: <Widget>[
          TextButton(
            style: TextButton.styleFrom(
              textStyle: const TextStyle(
                fontSize: 20,
                color: Colors.blue,
              ),
            ),
            onPressed: onYes,
            child: const Text('Ya'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              textStyle: const TextStyle(
                fontSize: 20,
                color: Colors.blue,
              ),
            ),
            onPressed: onNo,
            child: const Text('Tidak'),
          ),
        ],
      ),
    );
  }

  void showCheckoutAlert(BuildContext context, String title, String message,
      VoidCallback onCancel) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            style: TextButton.styleFrom(
              textStyle: const TextStyle(
                fontSize: 20,
                color: Colors.blue,
              ),
            ),
            onPressed: onCancel,
            child: const Text('OK'),
          ),
        ],
      ),
    );
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
                    initState();
                  },
                  child: ListView.builder(
                    itemCount: riwayat.length,
                    itemBuilder: (_, index) => Card(
                      child: Container(
                        margin: const EdgeInsets.only(left: 10, right: 10),
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
                                                riwayat[index]['updated_at'])),
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
                                  'Selesai',
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
                            const Divider(
                              height: 20,
                              thickness: 1,
                              indent: 0,
                              endIndent: 0,
                            ),
                            Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              height: 30,
                              width: 100,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  textStyle: const TextStyle(fontSize: 12),
                                  shape: const RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20)),
                                  ),
                                ),
                                onPressed: () {
                                  // showDialog(
                                  //   context: context,
                                  //   barrierDismissible: true,
                                  //   builder: (BuildContext context) =>
                                  //       AlertDialog(
                                  //     title: const Text('Beli Lagi?'),
                                  //     content: const Text(
                                  //         'Semua menu dipembelian ini akan dimasukkan ke keranjang'),
                                  //     actions: <Widget>[
                                  //       TextButton(
                                  //         style: TextButton.styleFrom(
                                  //           textStyle: const TextStyle(
                                  //             fontSize: 20,
                                  //             color: Colors.blue,
                                  //           ),
                                  //         ),
                                  //         onPressed: () => _beliLagiYes(
                                  //             idRiwayat: riwayat[index]['id']),
                                  //         child: const Text('Ya'),
                                  //       ),
                                  //       TextButton(
                                  //         style: TextButton.styleFrom(
                                  //           textStyle: const TextStyle(
                                  //             fontSize: 20,
                                  //             color: Colors.blue,
                                  //           ),
                                  //         ),
                                  //         onPressed: _navigationService.pop,
                                  //         child: const Text('Tidak'),
                                  //       ),
                                  //     ],
                                  //   ),
                                  // );
                                  confirmBeliLagi(
                                      context,
                                      'Beli Lagi?',
                                      'Semua menu dipembelian ini akan dimasukkan ke keranjang',
                                      () => _beliLagiYes(
                                          idRiwayat: riwayat[index]['id']),
                                      _navigationService.pop);
                                },
                                child: const Text('Beli Lagi'),
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
                    child: Text('Sudah tidak ada riwayat'),
                  ),
                ),
            ],
          );
  }
}
