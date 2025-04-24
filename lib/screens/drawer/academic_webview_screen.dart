import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../components/my_app_bar.dart';

class AcademicWebViewScreen extends StatefulWidget {
  final String url;
  final String title;

  const AcademicWebViewScreen({
    super.key,
    this.url = 'https://www.aiet.edu.eg/default.asp',
    this.title = 'AIET',
  });

  @override
  State<AcademicWebViewScreen> createState() => _AcademicWebViewScreenState();
}

class _AcademicWebViewScreenState extends State<AcademicWebViewScreen> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebView error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: widget.title,
        onpressed: () => Navigator.pop(context),
      ),
      body: WebViewWidget(controller: controller),
    );
  }
}
