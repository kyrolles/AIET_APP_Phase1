import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:graduation_project/screens/home_screen.dart';
// import 'package:graduation_project/screens/home_screen.dart';
import 'package:graduation_project/screens/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.isUserLoggedIn});
  final bool isUserLoggedIn;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    Future.delayed(const Duration(seconds: 2), () {
      if (widget.isUserLoggedIn) {
        // ignore: use_build_context_synchronously
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        // ignore: use_build_context_synchronously
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const LoginScreen(),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0XFF3DB2FF),
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: SvgPicture.asset('assets/images/LogoSplash3.svg'),
            ),
            Center(
              child: Image.asset(
                'assets/images/smalllogo.png',
                height: 190,
                width: 190,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
