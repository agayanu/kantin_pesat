import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kantin_pesat/locator.dart';
import 'package:kantin_pesat/services/cons_service.dart';
import 'package:kantin_pesat/services/storage_service.dart';
import 'package:http/http.dart' as http;
import 'package:kantin_pesat/ui/views/lapak_show_view.dart';

class LapakRatingView extends StatefulWidget {
  const LapakRatingView({Key? key}) : super(key: key);

  @override
  _LapakRatingViewState createState() => _LapakRatingViewState();
}

class _LapakRatingViewState extends State<LapakRatingView> {
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
  List _lapaks = [];

  // menu
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _loadLapak() async {
    setState(() {
      _isFirstLoadRunning = true;
    });

    try {
      token = (await _storageService.getString('token'))!;
      final lapakUrl = '$baseURL/lapak?page=$_page';
      if (kDebugMode) {
        print('[Lapak URL] $lapakUrl');
      }
      final response = await client.get(Uri.parse(lapakUrl), headers: {
        'Authorization': 'Bearer $token',
      });
      if (kDebugMode) {
        print(response.body);
      }
      Map<String, dynamic> map = json.decode(response.body);

      setState(() {
        _lapaks = map["data"];
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
        final lapakUrl = '$baseURL/lapak?page=$_page';
        if (kDebugMode) {
          print('[LapakLoad URL] $lapakUrl');
        }
        final response = await client.get(Uri.parse(lapakUrl), headers: {
          'Authorization': 'Bearer $token',
        });
        if (kDebugMode) {
          print(response.body);
        }

        Map<String, dynamic> map = json.decode(response.body);
        final List fetchedPosts = map["data"];
        if (fetchedPosts.isNotEmpty) {
          setState(() {
            _lapaks.addAll(fetchedPosts);
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
    _loadLapak();
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
        title: const Text('Kantin Rating Jempolan'),
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
                      itemCount: _lapaks.length,
                      itemBuilder: (_, index) => InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LapakShowView(
                                  id: _lapaks[index]['id'],
                                  nama: _lapaks[index]['nama']),
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
                                  imageURL + _lapaks[index]['gambar'],
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
                                          text: _lapaks[index]['nama'],
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
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.star,
                                            color: Colors.yellowAccent.shade700,
                                          ),
                                          Container(
                                            margin:
                                                const EdgeInsets.only(left: 3),
                                            child: Text(
                                              _lapaks[index]['rating']
                                                      .toString() +
                                                  ' - ' +
                                                  _lapaks[index]['user_rating']
                                                      .toString() +
                                                  ' rating',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey.shade600,
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
                          Text('Sudah tidak ada kantin lain, coba menu lain'),
                    ),
                  ),
              ],
            ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'Profil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_note),
            label: 'Riwayat',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
