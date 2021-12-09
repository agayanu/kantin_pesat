import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kantin_pesat/locator.dart';
import 'package:kantin_pesat/services/cons_service.dart';
import 'package:kantin_pesat/services/navigation_service.dart';
import 'package:kantin_pesat/services/storage_service.dart';
import 'package:http/http.dart' as http;
import 'package:kantin_pesat/ui/route_name.dart';
import 'package:kantin_pesat/ui/views/lapak_show_view.dart';
import 'package:kantin_pesat/ui/views/menu_show_view.dart';
import 'package:kantin_pesat/ui/views/promo_show_view.dart';
import 'package:kantin_pesat/ui/views/search_menu_view.dart';

class BerandaView extends StatefulWidget {
  const BerandaView({Key? key}) : super(key: key);

  @override
  _BerandaViewState createState() => _BerandaViewState();
}

class _BerandaViewState extends State<BerandaView> {
  final StorageService _storageService = locator<StorageService>();
  final NavigationService _navigationService = locator<NavigationService>();
  final CarouselController _controller = CarouselController();
  final f = NumberFormat.currency(
      locale: "id_ID", customPattern: '#,###', decimalDigits: 0);

  int _current = 0;
  String token = "";
  String idUser = "";
  bool _isFirstLoadRunning = false;
  final client = http.Client();
  List _promos = [];
  List _lapaks = [];
  List _menus = [];
  List _menuDiskons = [];

  void _loadPromo() async {
    setState(() {
      _isFirstLoadRunning = true;
    });

    try {
      token = (await _storageService.getString('token'))!;
      idUser = (await _storageService.getString('id'))!;
      const promoUrl = '$baseURL/promo';
      if (kDebugMode) {
        print('[Promo URL] $promoUrl');
      }
      final response = await client.get(Uri.parse(promoUrl), headers: {
        'Authorization': 'Bearer $token',
      });
      if (kDebugMode) {
        print(response.body);
      }
      Map<String, dynamic> map = jsonDecode(response.body);

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

  void _loadLapak() async {
    setState(() {
      _isFirstLoadRunning = true;
    });

    try {
      token = (await _storageService.getString('token'))!;
      const lapakUrl = '$baseURL/lapak';
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

  void _loadMenu() async {
    setState(() {
      _isFirstLoadRunning = true;
    });

    try {
      token = (await _storageService.getString('token'))!;
      const menuUrl = '$baseURL/menu';
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
      });
    } catch (err) {
      if (kDebugMode) {
        print('[Menu] $err');
      }
    }

    setState(() {
      _isFirstLoadRunning = false;
    });
  }

  void _loadMenuDiskon() async {
    setState(() {
      _isFirstLoadRunning = true;
    });

    try {
      token = (await _storageService.getString('token'))!;
      const menuUrl = '$baseURL/menu-diskon';
      if (kDebugMode) {
        print('[MenuDiskon URL] $menuUrl');
      }
      final response = await client.get(Uri.parse(menuUrl), headers: {
        'Authorization': 'Bearer $token',
      });
      if (kDebugMode) {
        print(response.body);
      }
      Map<String, dynamic> map = json.decode(response.body);

      setState(() {
        _menuDiskons = map["data"];
      });
    } catch (err) {
      if (kDebugMode) {
        print('[MenuDiskon] $err');
      }
    }

    setState(() {
      _isFirstLoadRunning = false;
    });
  }

  @override
  void initState() {
    _loadPromo();
    _loadLapak();
    _loadMenu();
    _loadMenuDiskon();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Selamat Datang'),
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
                      initState();
                    },
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SearchMenuView(),
                                ),
                              );
                            },
                            child: Container(
                              height: 42,
                              margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.white,
                                border: Border.all(color: Colors.black26),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: const TextField(
                                decoration: InputDecoration(
                                  icon:
                                      Icon(Icons.search, color: Colors.black54),
                                  hintText: 'Mau makan apa hari ini?',
                                  hintStyle: TextStyle(color: Colors.black54),
                                  border: InputBorder.none,
                                  enabled: false,
                                ),
                              ),
                            ),
                          ),

                          // Promo
                          Column(
                            children: [
                              CarouselSlider(
                                options: CarouselOptions(
                                  height: 150,
                                  aspectRatio: 2.0,
                                  enlargeCenterPage: true,
                                  enableInfiniteScroll: false,
                                  initialPage: 2,
                                  autoPlay: true,
                                  onPageChanged: (index, reason) {
                                    setState(() {
                                      _current = index;
                                    });
                                  },
                                ),
                                items: _promos
                                    .map(
                                      (item) => Container(
                                        margin: const EdgeInsets.all(5.0),
                                        child: InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    PromoShowView(
                                                        id: item['id'],
                                                        nama: item['nama']),
                                              ),
                                            );
                                          },
                                          child: ClipRRect(
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(10)),
                                            child: Image.network(
                                              imageURL + item['gambar'],
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                              Container(
                                margin: const EdgeInsets.only(left: 15),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children:
                                      _promos.asMap().entries.map((entry) {
                                    return GestureDetector(
                                      onTap: () =>
                                          _controller.animateToPage(entry.key),
                                      child: Container(
                                        width: 8.0,
                                        height: 8.0,
                                        margin: const EdgeInsets.symmetric(
                                          vertical: 8.0,
                                          horizontal: 4.0,
                                        ),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: (Theme.of(context)
                                                          .brightness ==
                                                      Brightness.dark
                                                  ? Colors.white
                                                  : Colors.blue)
                                              .withOpacity(_current == entry.key
                                                  ? 0.9
                                                  : 0.4),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),

                          // Menu Utama
                          Container(
                            margin: const EdgeInsets.only(top: 10, left: 10),
                            child: Row(
                              children: [
                                InkWell(
                                  onTap: () {
                                    _navigationService
                                        .navigateTo(makananViewRoute);
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(left: 25),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.only(
                                              top: 15, bottom: 5),
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                  width: 2,
                                                  color:
                                                      Colors.blueGrey.shade50)),
                                          child: const Icon(
                                            Icons.restaurant_menu,
                                            color: Colors.blue,
                                            size: 50,
                                          ),
                                        ),
                                        Text(
                                          'Makanan',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blueGrey.shade700),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    _navigationService
                                        .navigateTo(minumanViewRoute);
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(left: 25),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.only(
                                              top: 15, bottom: 5),
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                  width: 2,
                                                  color:
                                                      Colors.blueGrey.shade50)),
                                          child: const Icon(
                                            Icons.local_cafe,
                                            color: Colors.blue,
                                            size: 50,
                                          ),
                                        ),
                                        Text(
                                          'Minuman',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blueGrey.shade700),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Lapak Rating
                          Container(
                            margin: const EdgeInsets.only(top: 30, left: 10),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Kantin dengan rating jempolan',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        _navigationService
                                            .navigateTo(lapakRatingViewRoute);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.only(
                                            left: 10,
                                            right: 10,
                                            top: 3,
                                            bottom: 3),
                                        margin:
                                            const EdgeInsets.only(right: 10),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                          color: Colors.lightBlue.shade100,
                                        ),
                                        constraints: const BoxConstraints(
                                          minWidth: 16,
                                          minHeight: 16,
                                        ),
                                        child: Text(
                                          'Lihat Semua',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue.shade900,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  margin: const EdgeInsets.only(top: 5),
                                  child: const Align(
                                    alignment: Alignment.topLeft,
                                    child: Text('Kami pilihin yang enak'),
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(top: 5),
                                  child: CarouselSlider(
                                    options: CarouselOptions(
                                      viewportFraction: 0.5,
                                      enableInfiniteScroll: false,
                                      aspectRatio: 2.0,
                                      height: 230,
                                    ),
                                    items: _lapaks
                                        .map(
                                          (item) => InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      LapakShowView(
                                                          id: item['id'],
                                                          nama: item['nama']),
                                                ),
                                              );
                                            },
                                            child: Card(
                                              shape:
                                                  const RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  10))),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                            bottom: 10),
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          const BorderRadius
                                                                  .all(
                                                              Radius.circular(
                                                                  10)),
                                                      child: Image.network(
                                                        imageURL +
                                                            item['gambar'],
                                                        fit: BoxFit.cover,
                                                        height: 120,
                                                      ),
                                                    ),
                                                  ),
                                                  Flexible(
                                                    child: Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                              left: 10,
                                                              right: 10),
                                                      child: RichText(
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        maxLines: 2,
                                                        text: TextSpan(
                                                          text: item['nama'],
                                                          style:
                                                              const TextStyle(
                                                            color: Colors.black,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 18,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                            left: 10,
                                                            right: 10,
                                                            top: 10),
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          Icons.star,
                                                          color: Colors
                                                              .yellowAccent
                                                              .shade700,
                                                        ),
                                                        Container(
                                                          margin:
                                                              const EdgeInsets
                                                                      .only(
                                                                  left: 3),
                                                          child: Text(
                                                            item['rating']
                                                                    .toString() +
                                                                ' - ' +
                                                                item['user_rating']
                                                                    .toString() +
                                                                ' rating',
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Colors.grey
                                                                  .shade600,
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
                                        )
                                        .toList(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Menu Makanan sort sukai
                          Container(
                            margin: const EdgeInsets.only(top: 30, left: 10),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Mari makan enak',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        _navigationService
                                            .navigateTo(makananViewRoute);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.only(
                                            left: 10,
                                            right: 10,
                                            top: 3,
                                            bottom: 3),
                                        margin:
                                            const EdgeInsets.only(right: 10),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                          color: Colors.lightBlue.shade100,
                                        ),
                                        constraints: const BoxConstraints(
                                          minWidth: 16,
                                          minHeight: 16,
                                        ),
                                        child: Text(
                                          'Lihat Semua',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue.shade900,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  margin: const EdgeInsets.only(top: 5),
                                  child: const Align(
                                    alignment: Alignment.topLeft,
                                    child:
                                        Text('Biar kegiatanmu makin semangat'),
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(top: 5),
                                  child: CarouselSlider(
                                    options: CarouselOptions(
                                      viewportFraction: 0.75,
                                      enableInfiniteScroll: false,
                                      aspectRatio: 2.0,
                                      height: 120,
                                    ),
                                    items: _menus
                                        .map(
                                          (item) => InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      MenuShowView(
                                                          idUser: idUser,
                                                          idMenu:
                                                              item['id_menu']
                                                                  .toString(),
                                                          idLapak:
                                                              item['id_lapak']
                                                                  .toString(),
                                                          nama: item['nama'],
                                                          namaLapak: item[
                                                              'nama_lapak'],
                                                          harga: item['harga'],
                                                          gambar:
                                                              item['gambar']),
                                                ),
                                              );
                                            },
                                            child: Card(
                                              shape:
                                                  const RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(10),
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(
                                                                10)),
                                                    child: Image.network(
                                                      imageURL + item['gambar'],
                                                      fit: BoxFit.cover,
                                                      height: 120,
                                                      width: 120,
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Column(
                                                      children: [
                                                        Flexible(
                                                          child: Container(
                                                            margin:
                                                                const EdgeInsets
                                                                        .only(
                                                                    left: 10,
                                                                    right: 10,
                                                                    top: 10),
                                                            child: RichText(
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              maxLines: 2,
                                                              text: TextSpan(
                                                                text: item[
                                                                    'nama'],
                                                                style:
                                                                    const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 16,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Flexible(
                                                          child: Container(
                                                            margin:
                                                                const EdgeInsets
                                                                        .only(
                                                                    left: 10,
                                                                    right: 10,
                                                                    top: 10,
                                                                    bottom: 10),
                                                            child: RichText(
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              maxLines: 1,
                                                              text: TextSpan(
                                                                text: item[
                                                                    'nama_lapak'],
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade700,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 10,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Container(
                                                          margin:
                                                              const EdgeInsets
                                                                      .only(
                                                                  left: 10),
                                                          child: Align(
                                                            alignment: Alignment
                                                                .topLeft,
                                                            child: Text(
                                                              'Rp. ' +
                                                                  f.format(item[
                                                                      'harga']),
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .grey
                                                                    .shade700,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 12,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Menu Makanan promo sort disuka
                          Container(
                            margin: const EdgeInsets.only(top: 30, left: 10),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Takasimuraaaa!',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        _navigationService
                                            .navigateTo(promoMenuViewRoute);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.only(
                                            left: 10,
                                            right: 10,
                                            top: 3,
                                            bottom: 3),
                                        margin:
                                            const EdgeInsets.only(right: 10),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                          color: Colors.lightBlue.shade100,
                                        ),
                                        constraints: const BoxConstraints(
                                          minWidth: 16,
                                          minHeight: 16,
                                        ),
                                        child: Text(
                                          'Lihat Semua',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue.shade900,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  margin: const EdgeInsets.only(top: 5),
                                  child: const Align(
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                        'Cek menu yang lagi diskon disini'),
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(top: 5),
                                  child: CarouselSlider(
                                    options: CarouselOptions(
                                      viewportFraction: 0.75,
                                      enableInfiniteScroll: false,
                                      aspectRatio: 2.0,
                                      height: 120,
                                    ),
                                    items: _menuDiskons
                                        .map(
                                          (item) => InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      MenuShowView(
                                                          idUser: idUser,
                                                          idMenu:
                                                              item['id_menu']
                                                                  .toString(),
                                                          idLapak:
                                                              item['id_lapak']
                                                                  .toString(),
                                                          nama: item['nama'],
                                                          namaLapak: item[
                                                              'nama_lapak'],
                                                          harga: item['harga'],
                                                          gambar:
                                                              item['gambar']),
                                                ),
                                              );
                                            },
                                            child: Card(
                                              shape:
                                                  const RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  10))),
                                              child: Row(
                                                children: [
                                                  Stack(
                                                    children: [
                                                      ClipRRect(
                                                        borderRadius:
                                                            const BorderRadius
                                                                    .all(
                                                                Radius.circular(
                                                                    10)),
                                                        child: Image.network(
                                                          imageURL +
                                                              item['gambar'],
                                                          fit: BoxFit.cover,
                                                          height: 120,
                                                          width: 120,
                                                        ),
                                                      ),
                                                      Container(
                                                        decoration:
                                                            const BoxDecoration(
                                                          color: Colors.red,
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          10)),
                                                        ),
                                                        width: 50.0,
                                                        height: 30.0,
                                                        child: const Center(
                                                          child: Text(
                                                            'Promo',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Expanded(
                                                    child: Column(
                                                      children: [
                                                        Flexible(
                                                          child: Container(
                                                            margin:
                                                                const EdgeInsets
                                                                        .only(
                                                                    left: 10,
                                                                    right: 10,
                                                                    top: 10),
                                                            child: RichText(
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              maxLines: 2,
                                                              text: TextSpan(
                                                                text: item[
                                                                    'nama'],
                                                                style:
                                                                    const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 16,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Flexible(
                                                          child: Container(
                                                            margin:
                                                                const EdgeInsets
                                                                        .only(
                                                                    left: 10,
                                                                    right: 10,
                                                                    top: 10,
                                                                    bottom: 10),
                                                            child: RichText(
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              maxLines: 1,
                                                              text: TextSpan(
                                                                text: item[
                                                                    'nama_lapak'],
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade700,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 10,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Container(
                                                          margin:
                                                              const EdgeInsets
                                                                      .only(
                                                                  left: 10),
                                                          child: Align(
                                                            alignment: Alignment
                                                                .topLeft,
                                                            child: Text(
                                                              'Rp. ' +
                                                                  f.format(item[
                                                                      'harga']),
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .grey
                                                                    .shade700,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 12,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
      // bottomNavigationBar: BottomNavigationBar(
      //   type: BottomNavigationBarType.fixed,
      //   items: [
      //     const BottomNavigationBarItem(
      //       icon: Icon(Icons.home),
      //       label: 'Beranda',
      //     ),
      //     const BottomNavigationBarItem(
      //       icon: Icon(Icons.business),
      //       label: 'Profil',
      //     ),
      //     const BottomNavigationBarItem(
      //       icon: Icon(Icons.event_note),
      //       label: 'Riwayat',
      //     ),
      //     BottomNavigationBarItem(
      //       label: 'Keranjang',
      //       icon: Stack(
      //         children: [
      //           const Icon(Icons.shopping_cart_outlined),
      //           if (jmlKeranjang != 0 && jmlKeranjang < 100)
      //             Positioned(
      //               top: 0.0,
      //               right: 0.0,
      //               child: Container(
      //                 padding: const EdgeInsets.only(left: 2, right: 2),
      //                 decoration: BoxDecoration(
      //                   borderRadius: BorderRadius.circular(5.0),
      //                   color: Colors.lightBlue.shade100,
      //                 ),
      //                 constraints: const BoxConstraints(
      //                   minWidth: 12,
      //                   minHeight: 10,
      //                 ),
      //                 child: Text(
      //                   jmlKeranjang.toString(),
      //                   textAlign: TextAlign.center,
      //                   style: TextStyle(
      //                     fontSize: 9,
      //                     fontWeight: FontWeight.bold,
      //                     color: Colors.blue.shade900,
      //                   ),
      //                 ),
      //               ),
      //             )
      //           else if (jmlKeranjang > 99)
      //             Positioned(
      //               top: 0.0,
      //               right: 0.0,
      //               child: Container(
      //                 padding: const EdgeInsets.only(left: 2, right: 2),
      //                 decoration: BoxDecoration(
      //                   borderRadius: BorderRadius.circular(5.0),
      //                   color: Colors.lightBlue.shade100,
      //                 ),
      //                 constraints: const BoxConstraints(
      //                   minWidth: 12,
      //                   minHeight: 10,
      //                 ),
      //                 child: Text(
      //                   '99+',
      //                   textAlign: TextAlign.center,
      //                   style: TextStyle(
      //                     fontSize: 9,
      //                     fontWeight: FontWeight.bold,
      //                     color: Colors.blue.shade900,
      //                   ),
      //                 ),
      //               ),
      //             )
      //           else
      //             Positioned(
      //               top: 0.0,
      //               right: 0.0,
      //               child: Container(),
      //             )
      //         ],
      //       ),
      //     ),
      //   ],
      //   currentIndex: 0,
      //   selectedItemColor: Colors.red,
      //   onTap: _onItemTapped,
      // ),
    );
  }
}
