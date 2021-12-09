import 'package:flutter/material.dart';
import 'package:kantin_pesat/ui/route_name.dart';
import 'package:kantin_pesat/ui/views/admin_view.dart';
import 'package:kantin_pesat/ui/views/atur_akun_view.dart';
import 'package:kantin_pesat/ui/views/dashboard_view.dart';
import 'package:kantin_pesat/ui/views/keranjang_pembeli_view.dart';
import 'package:kantin_pesat/ui/views/lapak_rating_view.dart';
import 'package:kantin_pesat/ui/views/login_view.dart';
import 'package:kantin_pesat/ui/views/makanan_view.dart';
import 'package:kantin_pesat/ui/views/minuman_view.dart';
import 'package:kantin_pesat/ui/views/profil_pembeli_view.dart';
import 'package:kantin_pesat/ui/views/promo_menu_view.dart';
import 'package:kantin_pesat/ui/views/riwayat_pembeli_view.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case loginViewRoute:
      return MaterialPageRoute(builder: (_) => const LoginView());
    case dashboardViewRoute:
      return MaterialPageRoute(builder: (_) => const DashboardView());
    case adminViewRoute:
      return MaterialPageRoute(builder: (_) => const AdminView());
    case aturAkunViewRoute:
      return MaterialPageRoute(builder: (_) => const AturAkunView());
    case makananViewRoute:
      return MaterialPageRoute(builder: (_) => const MakananView());
    case minumanViewRoute:
      return MaterialPageRoute(builder: (_) => const MinumanView());
    case lapakRatingViewRoute:
      return MaterialPageRoute(builder: (_) => const LapakRatingView());
    case promoMenuViewRoute:
      return MaterialPageRoute(builder: (_) => const PromoMenuView());
    case keranjangPembeliViewRoute:
      return MaterialPageRoute(builder: (_) => const KeranjangPembeliView());
    case profilPembeliViewRoute:
      return MaterialPageRoute(builder: (_) => const ProfilPembeliView());
    case riwayatPembeliViewRoute:
      return MaterialPageRoute(builder: (_) => const RiwayatPembeliView());
    default:
      return _errorRoute();
  }
}

Route<dynamic> _errorRoute() {
  return MaterialPageRoute(builder: (_) {
    return Scaffold(
      appBar: AppBar(title: const Text("Error")),
      body: const Center(child: Text('Error page')),
    );
  });
}
