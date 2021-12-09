import 'package:flutter/material.dart';
import 'package:kantin_pesat/ui/style/color.dart';
import 'package:kantin_pesat/ui/style/distance.dart';
import 'package:kantin_pesat/ui/style/style.dart';
import 'package:kantin_pesat/ui/widgets/button_widget.dart';
import 'package:kantin_pesat/ui/widgets/text_field_widget.dart';
import 'package:kantin_pesat/viewmodels/login_view_model.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:stacked/stacked.dart';

class LoginView extends StatelessWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return ViewModelBuilder<LoginViewModel>.reactive(
      viewModelBuilder: () => LoginViewModel(),
      builder: (context, viewModel, child) => Scaffold(
        body: LoadingOverlay(
          isLoading: viewModel.busy,
          child: SafeArea(
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  children: [
                    verticalSpaceMedium,
                    const Text(
                      "Kantin Pesat",
                      style: titleTextStyle,
                    ),
                    verticalSpaceLarge,
                    Image.asset(
                      'assets/logo.png',
                      width: size.width * 0.3,
                      height: size.width * 0.3,
                    ),
                    verticalSpaceMedium,
                    TextFieldWidget(
                        hintText: 'E-Mail',
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                        isPassword: false,
                        textFieldController: viewModel.emailController,
                        colorIcon: colorMain),
                    verticalSpaceSmall,
                    TextFieldWidget(
                        hintText: 'Password',
                        icon: Icons.lock,
                        keyboardType: TextInputType.emailAddress,
                        isPassword: true,
                        textFieldController: viewModel.passwordController,
                        colorIcon: colorMain),
                    verticalSpaceLarge,
                    ButtonWidget(
                        title: 'MASUK',
                        onPressedFunction: () {
                          viewModel.logginAccount(context);
                        },
                        bgColor: colorMain),
                    verticalSpaceSmall,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Tidak punya akun? '),
                        InkWell(
                          onTap: () {},
                          child: const Text(
                            'DAFTAR',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.none,
                              color: colorMain,
                            ),
                          ),
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
    );
  }
}
