import 'package:flutter/material.dart';
import 'package:kantin_pesat/locator.dart';
import 'package:kantin_pesat/services/alert_service.dart';
import 'package:kantin_pesat/services/navigation_service.dart';
import 'package:kantin_pesat/services/storage_service.dart';
import 'package:kantin_pesat/ui/route_name.dart';

class AturAkunView extends StatefulWidget {
  const AturAkunView({Key? key}) : super(key: key);

  @override
  _AturAkunViewState createState() => _AturAkunViewState();
}

class _AturAkunViewState extends State<AturAkunView> {
  final StorageService _storageService = locator<StorageService>();
  final NavigationService _navigationService = locator<NavigationService>();
  final AlertService _alertService = locator<AlertService>();

  void clearBeforeSignOut() async {
    await _storageService.clearStorage();
    _navigationService.replaceTo(loginViewRoute);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Atur Akun'),
      ),
      body: Column(
        children: [
          InkWell(
            onTap: () {
              _alertService.showSignOut(context, 'Yakin keluar?', '',
                  clearBeforeSignOut, _navigationService.pop);
            },
            child: Container(
              margin: const EdgeInsets.only(top: 20, left: 15),
              height: size.width * 0.17,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.logout),
                      Container(
                        margin: const EdgeInsets.only(left: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Keluar',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 5),
                              width: size.width * 0.7,
                              child: const Text(
                                'Anda tidak akan dapat menggunakan layanan Gojek kecuali Anda login kembali',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.black45),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    margin: const EdgeInsets.only(right: 10),
                    child: const Icon(
                      Icons.arrow_forward_ios,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(
            height: 20,
            thickness: 1,
            indent: 45,
          ),
        ],
      ),
    );
  }
}
