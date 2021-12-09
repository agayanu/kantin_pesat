import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kantin_pesat/locator.dart';
import 'package:kantin_pesat/services/cons_service.dart';
import 'package:kantin_pesat/services/storage_service.dart';
import 'package:kantin_pesat/ui/views/beranda_view.dart';
import 'package:kantin_pesat/ui/views/keranjang_pembeli_view.dart';
import 'package:kantin_pesat/ui/views/profil_pembeli_view.dart';
import 'package:kantin_pesat/ui/views/riwayat_pembeli_view.dart';
import 'package:http/http.dart' as http;

class DashboardView extends StatefulWidget {
  const DashboardView({Key? key}) : super(key: key);

  @override
  _DashboardViewState createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final StorageService _storageService = locator<StorageService>();
  final client = http.Client();
  bool _isFirstLoadRunning = false;
  String token = "";
  int _selectedIndex = 0;
  int jmlKeranjang = 0;

  static const List _widgetOptions = [
    BerandaView(),
    ProfilPembeliView(),
    RiwayatPembeliView(),
    KeranjangPembeliView(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _loadKeranjang();
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

  @override
  void initState() {
    _loadKeranjang();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isFirstLoadRunning
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'Profil',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.event_note),
            label: 'Riwayat',
          ),
          BottomNavigationBarItem(
            label: 'Keranjang',
            icon: Stack(
              children: [
                const Icon(Icons.shopping_cart_outlined),
                if (jmlKeranjang != 0 && jmlKeranjang < 100)
                  Positioned(
                    top: 0.0,
                    right: 0.0,
                    child: Container(
                      padding: const EdgeInsets.only(left: 2, right: 2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        color: Colors.lightBlue.shade100,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 12,
                        minHeight: 10,
                      ),
                      child: Text(
                        jmlKeranjang.toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ),
                  )
                else if (jmlKeranjang > 99)
                  Positioned(
                    top: 0.0,
                    right: 0.0,
                    child: Container(
                      padding: const EdgeInsets.only(left: 2, right: 2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        color: Colors.lightBlue.shade100,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 12,
                        minHeight: 10,
                      ),
                      child: Text(
                        '99+',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ),
                  )
                else
                  Positioned(
                    top: 0.0,
                    right: 0.0,
                    child: Container(),
                  )
              ],
            ),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.red,
        onTap: _onItemTapped,
      ),
    );
  }
}
