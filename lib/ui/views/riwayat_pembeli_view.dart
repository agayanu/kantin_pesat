import 'package:flutter/material.dart';
import 'package:kantin_pesat/ui/views/riwayat_bayar_view.dart';
import 'package:kantin_pesat/ui/views/riwayat_selesai_view.dart';

class RiwayatPembeliView extends StatefulWidget {
  const RiwayatPembeliView({Key? key}) : super(key: key);

  @override
  _RiwayatPembeliViewState createState() => _RiwayatPembeliViewState();
}

class _RiwayatPembeliViewState extends State<RiwayatPembeliView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(vsync: this, length: 2);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              text: 'Bayar',
            ),
            Tab(
              text: 'Selesai',
            ),
          ],
        ),
      ),
      body: Container(
        margin: const EdgeInsets.only(top: 10),
        child: TabBarView(
          controller: _tabController,
          children: const [
            RiwayatBayarView(),
            RiwayatSelesaiView(),
          ],
        ),
      ),
    );
  }
}
