import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: CharacterSelectionPage(),
    );
  }
}

// ✅ 選擇練習字頁面
class CharacterSelectionPage extends StatelessWidget {
  final List<Map<String, String>> characters = [
    {'word': '丁', 'id': '19969'},
    {'word': '二', 'id': '20108'},
    {'word': '三', 'id': '19977'},
    {'word': '大', 'id': '22823'},
    {'word': '小', 'id': '23567'},
    {'word': '體', 'id': '39636'},
    {'word': '鳳', 'id': '40179'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("選擇要練習的字")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.0,
          ),
          itemCount: characters.length,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => HandwritingPage(
                          character: characters[index]['word']!,
                          strokeId: characters[index]['id']!,
                        ),
                  ),
                );
              },
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                color: Colors.lightBlueAccent[100],
                child: Center(
                  child: Text(
                    characters[index]['word']!,
                    style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ✅ 手寫畫布頁面（筆順驗證）
class HandwritingPage extends StatefulWidget {
  final String character;
  final String strokeId;

  HandwritingPage({required this.character, required this.strokeId});

  @override
  _HandwritingPageState createState() => _HandwritingPageState();
}

class _HandwritingPageState extends State<HandwritingPage> {
  InAppWebViewController? _webViewController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("書寫: ${widget.character}")),
      body: Stack(
        children: [
          // ✅ WebView 作為筆順比對工具
          InAppWebView(
            initialFile: "assets/hanzi_writer.html",
            initialOptions: InAppWebViewGroupOptions(
              crossPlatform: InAppWebViewOptions(javaScriptEnabled: true),
            ),
            onWebViewCreated: (controller) {
              _webViewController = controller;
              _webViewController!.addJavaScriptHandler(
                handlerName: "onResult",
                callback: (args) {
                  String result = args[0];
                  _showMessage(result == "correct" ? "筆順正確 ✅" : "筆順錯誤 ❌");
                },
              );
            },
            onLoadStop: (controller, url) {
              _webViewController!.evaluateJavascript(
                source: "loadCharacter('${widget.character}');",
              );
            },
          ),
          // ✅ 按鈕 - 觀看筆順動畫
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => StrokeOrderPage(strokeId: widget.strokeId),
                  ),
                );
              },
              icon: Icon(Icons.play_arrow),
              label: Text("觀看筆順動畫"),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12),
                textStyle: TextStyle(fontSize: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMessage(String message) {
    OverlayEntry overlayEntry = OverlayEntry(
      builder:
          (context) => Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                message,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
    );

    Overlay.of(context).insert(overlayEntry);

    Future.delayed(Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }
}

// ✅ 筆順動畫頁面（WebView - 播放教育部筆順動畫）
class StrokeOrderPage extends StatelessWidget {
  final String strokeId;

  StrokeOrderPage({required this.strokeId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("筆順動畫")),
      body: InAppWebView(
        initialUrlRequest: URLRequest(
          url: WebUri(
            'https://stroke-order.learningweb.moe.edu.tw/dictFrame.jsp?ID=$strokeId',
          ),
        ),
      ),
    );
  }
}
