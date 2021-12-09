import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kantin_pesat/locator.dart';
import 'package:kantin_pesat/services/cons_service.dart';
import 'package:kantin_pesat/services/navigation_service.dart';
import 'package:kantin_pesat/services/storage_service.dart';
import 'package:http/http.dart' as http;
import 'package:kantin_pesat/ui/views/qrcode_view.dart';

class KeranjangPembeliView extends StatefulWidget {
  const KeranjangPembeliView(
      {Key? key,
      this.qrCode,
      this.bayarConfirm,
      this.dataJson,
      this.dataEmpty,
      this.jmlMenuConfirm})
      : super(key: key);
  final int? qrCode;
  final int? bayarConfirm;
  final int? jmlMenuConfirm;
  final bool? dataJson;
  final bool? dataEmpty;
  @override
  _KeranjangPembeliViewState createState() => _KeranjangPembeliViewState();
}

class _KeranjangPembeliViewState extends State<KeranjangPembeliView> {
  final NavigationService _navigationService = locator<NavigationService>();
  final StorageService _storageService = locator<StorageService>();
  final f = NumberFormat.currency(
      locale: "id_ID", customPattern: '#,###', decimalDigits: 0);
  final client = http.Client();
  int saldo = 0;
  int jmlKeranjang = 0;
  int jmlKeranjangC = 0;
  int jmlKeranjangSum = 0;
  List keranjang = [];
  bool _isFirstLoadRunning = false;
  String token = "";
  late int? qrCodeGet = widget.qrCode;
  late int? bayarConfirm = widget.bayarConfirm;
  late int? jmlMenuConfirm = widget.jmlMenuConfirm;
  late bool? dataJson = widget.dataJson;
  late bool? dataEmpty = widget.dataEmpty;

  void _loadSaldo() async {
    setState(() {
      _isFirstLoadRunning = true;
    });

    try {
      token = (await _storageService.getString('token'))!;
      const saldoUrl = '$baseURL/saldo-pembeli';
      if (kDebugMode) {
        print('[Saldo URL] $saldoUrl');
      }
      final response = await client.get(Uri.parse(saldoUrl), headers: {
        'Authorization': 'Bearer $token',
      });
      if (kDebugMode) {
        print(response.body);
      }
      Map<String, dynamic> res = json.decode(response.body);

      setState(() {
        saldo = res["saldo"];
      });
    } catch (err) {
      if (kDebugMode) {
        print('[Keranjang] $err');
      }
    }

    setState(() {
      _isFirstLoadRunning = false;
    });
  }

  void _loadKeranjang() async {
    setState(() {
      _isFirstLoadRunning = true;
    });

    try {
      token = (await _storageService.getString('token'))!;
      const keranjangUrl = '$baseURL/keranjang-pembeli-count';
      if (kDebugMode) {
        print('[Keranjang URL] $keranjangUrl');
      }
      final response = await client.get(Uri.parse(keranjangUrl), headers: {
        'Authorization': 'Bearer $token',
      });
      if (kDebugMode) {
        print(response.body);
      }
      Map<String, dynamic> res = json.decode(response.body);

      setState(() {
        jmlKeranjang = res["count"];
        jmlKeranjangSum = res["sum"];
      });
    } catch (err) {
      if (kDebugMode) {
        print('[Keranjang] $err');
      }
    }

    setState(() {
      _isFirstLoadRunning = false;
    });
  }

  // void _loadKeranjangCheckout() async {
  //   setState(() {
  //     _isFirstLoadRunning = true;
  //   });

  //   try {
  //     token = (await _storageService.getString('token'))!;
  //     const keranjangCUrl = '$baseURL/keranjang-pembeli-checkout-count';
  //     if (kDebugMode) {
  //       print('[KeranjangC URL] $keranjangCUrl');
  //     }
  //     final response = await client.get(Uri.parse(keranjangCUrl), headers: {
  //       'Authorization': 'Bearer $token',
  //     });
  //     if (kDebugMode) {
  //       print(response.body);
  //     }
  //     Map<String, dynamic> res = json.decode(response.body);

  //     setState(() {
  //       jmlKeranjangC = res["count"];
  //     });
  //   } catch (err) {
  //     if (kDebugMode) {
  //       print('[KeranjangC] $err');
  //     }
  //   }

  //   setState(() {
  //     _isFirstLoadRunning = false;
  //   });
  // }

  void _loadKeranjangSaya() async {
    setState(() {
      _isFirstLoadRunning = true;
    });

    try {
      token = (await _storageService.getString('token'))!;
      const keranjangSUrl = '$baseURL/keranjang-pembeli';
      if (kDebugMode) {
        print('[KeranjangS URL] $keranjangSUrl');
      }
      final response = await client.get(Uri.parse(keranjangSUrl), headers: {
        'Authorization': 'Bearer $token',
      });
      if (kDebugMode) {
        print(response.body);
      }

      setState(() {
        keranjang = json.decode(response.body);
      });
    } catch (err) {
      if (kDebugMode) {
        print('[KeranjangS] $err');
      }
    }

    setState(() {
      _isFirstLoadRunning = false;
    });
  }

  void _loadBayar() async {
    setState(() {
      _isFirstLoadRunning = true;
    });

    try {
      token = (await _storageService.getString('token'))!;
      const keranjangUrl = '$baseURL/transaksi-pembeli-bayar';
      if (kDebugMode) {
        print('[Bayar URL] $keranjangUrl');
      }
      final response = await client.post(Uri.parse(keranjangUrl), headers: {
        'Authorization': 'Bearer $token',
      }, body: {
        'bayar': bayarConfirm.toString(),
        'id_lapak': qrCodeGet.toString(),
        'jml_keranjang': jmlMenuConfirm.toString(),
      });
      if (kDebugMode) {
        print(response.body);
      }
      Map<String, dynamic> res = json.decode(response.body);

      _loadKeranjangSaya();
      _loadKeranjang();

      if (res["success"] == true) {
        showCheckoutAlert(
            context, 'Sukses', res['message'], _navigationService.pop);
      }
      if (res["success"] == false) {
        showCheckoutAlert(
            context, 'Gagal', res['message'], _navigationService.pop);
      }
    } catch (err) {
      if (kDebugMode) {
        print('[Bayar] $err');
      }
      showCheckoutAlert(context, 'Error', '$err', _navigationService.pop);
    }

    setState(() {
      _isFirstLoadRunning = false;
    });
  }

  void _deleteKeranjang({idKeranjang}) async {
    setState(() {
      _isFirstLoadRunning = true;
    });

    try {
      token = (await _storageService.getString('token'))!;
      const keranjangUrl = '$baseURL/keranjang-hapus';
      if (kDebugMode) {
        print('[KeranjangHapus URL] $keranjangUrl');
      }
      final response = await client.delete(Uri.parse(keranjangUrl), headers: {
        'Authorization': 'Bearer $token',
      }, body: {
        'id_keranjang': idKeranjang.toString(),
      });
      if (kDebugMode) {
        print(response.body);
      }

      _loadKeranjangSaya();
      _loadKeranjang();
    } catch (err) {
      if (kDebugMode) {
        print('[KeranjangHapus] $err');
      }
    }

    setState(() {
      _isFirstLoadRunning = false;
    });
  }

  void showCheckout(BuildContext context, VoidCallback onCancel) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Pilih Metode Pembayaran'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 150,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 16),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QrcodeView(
                        bayar: jmlKeranjangSum,
                        jmlMenu: jmlKeranjang,
                      ),
                    ),
                  );
                },
                child: const Text('Scan QR'),
              ),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            style: TextButton.styleFrom(
              textStyle: const TextStyle(
                fontSize: 20,
                color: Colors.blue,
              ),
            ),
            onPressed: onCancel,
            child: const Text('Cancel'),
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

  void _errorK() {
    setState(() {
      _isFirstLoadRunning = true;
    });

    if (dataJson == false) {
      showCheckoutAlert(
          context, 'Error', 'Barcode tidak sesuai', _navigationService.pop);
    }
    if (dataEmpty == false) {
      showCheckoutAlert(
          context, 'Error', 'Kantin tidak terdaftar', _navigationService.pop);
    }

    setState(() {
      _isFirstLoadRunning = false;
    });
  }

  @override
  void initState() {
    if (qrCodeGet != null) {
      _loadBayar();
    }
    _errorK();
    _loadSaldo();
    // _loadKeranjangCheckout();
    _loadKeranjang();
    _loadKeranjangSaya();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Keranjang Saya'),
      ),
      body: _isFirstLoadRunning
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(left: 10, top: 20, bottom: 10),
                  child: Row(
                    children: [
                      const Text('SALDO : Rp. '),
                      Text(
                        f.format(saldo),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 10),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            textStyle: const TextStyle(fontSize: 16),
                            shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                            ),
                          ),
                          onPressed: () {},
                          child: const Text('Top Up'),
                        ),
                      ),
                    ],
                  ),
                ),
                // Container(
                //   margin: const EdgeInsets.only(left: 10, top: 20, bottom: 10),
                //   child: Row(
                //     children: [
                //       Text('Checkout belum dibayar : $jmlKeranjangC'),
                //       Container(
                //         margin: const EdgeInsets.only(left: 10),
                //         child: ElevatedButton(
                //           style: ElevatedButton.styleFrom(
                //             textStyle: const TextStyle(fontSize: 16),
                //             shape: const RoundedRectangleBorder(
                //               borderRadius:
                //                   BorderRadius.all(Radius.circular(20)),
                //             ),
                //           ),
                //           onPressed: () {},
                //           child: const Text('Lihat'),
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                const Divider(
                  height: 20,
                  thickness: 3,
                  indent: 0,
                  endIndent: 0,
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      qrCodeGet = null;
                      dataJson = null;
                      dataEmpty = null;
                      initState();
                    },
                    child: Stack(
                      children: [
                        ListView.builder(
                          itemCount: keranjang.length,
                          shrinkWrap: true,
                          itemBuilder: (_, index) => Card(
                            shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(10)),
                                  child: Image.network(
                                    imageURL + keranjang[index]['gambar'],
                                    fit: BoxFit.cover,
                                    height: 120,
                                    width: 120,
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.only(
                                            left: 10, top: 10),
                                        child: RichText(
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                          text: TextSpan(
                                            text: keranjang[index]['nama_menu'],
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
                                            text: keranjang[index]
                                                ['nama_lapak'],
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
                                                    keranjang[index]['harga']),
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
                                Container(
                                  margin:
                                      const EdgeInsets.only(right: 10, top: 10),
                                  height: 40,
                                  width: 40,
                                  child: FloatingActionButton(
                                    heroTag: keranjang[index]['id'].toString(),
                                    onPressed: () {
                                      _deleteKeranjang(
                                          idKeranjang: keranjang[index]['id']);
                                    },
                                    child: const Icon(Icons.remove,
                                        color: Colors.red),
                                    backgroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(
                      top: 5, bottom: 5, left: 10, right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Bayar : Rp. ' + f.format(jmlKeranjangSum)),
                      SizedBox(
                        width: 150,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            textStyle: const TextStyle(fontSize: 16),
                            shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                            ),
                          ),
                          onPressed: () {
                            if (jmlKeranjang == 0) {
                              showCheckoutAlert(
                                  context,
                                  'error',
                                  'Silahkan masukkan pesanan anda dahulu dikeranjang',
                                  _navigationService.pop);
                            } else if (jmlKeranjangSum > saldo) {
                              showCheckoutAlert(
                                  context,
                                  'error',
                                  'Saldo anda tidak mencukupi. Silahkan isi saldo anda',
                                  _navigationService.pop);
                            } else {
                              showCheckout(context, _navigationService.pop);
                            }
                          },
                          child: Text(
                              'Checkout (' + jmlKeranjang.toString() + ')'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
