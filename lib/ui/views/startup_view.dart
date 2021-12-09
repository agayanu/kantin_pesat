import 'package:flutter/material.dart';
import 'package:kantin_pesat/ui/style/distance.dart';
import 'package:kantin_pesat/viewmodels/startup_view_model.dart';
import 'package:stacked/stacked.dart';

class StartUpView extends StatelessWidget {
  const StartUpView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<StartUpViewModel>.reactive(
      viewModelBuilder: () => StartUpViewModel(),
      onModelReady: (model) => model.startUpTimer(),
      builder: (context, model, child) => Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              verticalSpaceMedium,
              SizedBox(
                width: 300,
                height: 100,
                child: Image.asset('assets/logo.png'),
              ),
              verticalSpaceSmall,
              const Text(
                'KANTIN PESAT',
                style: TextStyle(
                  fontSize: 28.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
