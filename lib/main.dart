import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ポイントアプリ',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    PointExchangePage(),
    MyPage(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "ホーム"),
          BottomNavigationBarItem(
              icon: Icon(Icons.card_giftcard), label: "ポイント交換"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "マイページ"),
        ],
      ),
    );
  }
}

//
// ホーム画面
//
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int? _selectedLogo; // 選択中の会社
  String _selectedLogoName = "Logo 1"; // 初期は Logo 1
  bool _showPoints = false; // バーコード/ポイント残高
  bool _showPayment = false; // バーコード/決済方法切り替え

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // --- バーコード or ポイント残高 or 決済方法 ---
        GestureDetector(
          onTap: () {
            // タップでポイント残高とバーコードを切り替え（決済表示中は無効）
            if (!_showPayment) {
              setState(() {
                _showPoints = !_showPoints;
              });
            }
          },
          onHorizontalDragEnd: (details) {
            if (_selectedLogo != null) {
              // 右スワイプ → 決済方法
              if (details.primaryVelocity! < 0) {
                setState(() {
                  _showPayment = true;
                });
              }
              // 左スワイプ → バーコード
              else if (details.primaryVelocity! > 0) {
                setState(() {
                  _showPayment = false;
                });
              }
            }
          },
          child: Container(
            height: 140,
            color: Colors.grey[300],
            child: Center(
              child: _showPayment
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text("おすすめの決済方法",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              SizedBox(height: 8),
                              Text("PayPay / 楽天Pay / d払い など（ダミー）"),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _showPayment = false; // ×ボタンでバーコードに戻る
                            });
                          },
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _showPoints
                            ? const Text("ポイント残高: 1200pt",
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold))
                            : const Text("バーコード表示（ダミー）",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                        const SizedBox(width: 16),
                        Text(_selectedLogoName,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // --- クーポン一覧（ロゴ選択中） ---
        if (_selectedLogo != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("クーポン一覧 ($_selectedLogoName)",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.red),
                onPressed: () {
                  setState(() {
                    _selectedLogo = null;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          Column(
            children: List.generate(10, (i) {
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.local_offer, color: Colors.orange),
                  title: Text("クーポン ${i + 1}"),
                  subtitle: Text("$_selectedLogoName 用の割引・特典"),
                ),
              );
            }),
          ),
        ],

        // --- ロゴ一覧（未選択時） ---
        if (_selectedLogo == null) ...[
          const Text("近くの会社",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1,
            ),
            itemCount: 12,
            itemBuilder: (context, i) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedLogo = i + 1;
                    _selectedLogoName = "Logo ${i + 1}";
                    _showPayment = false;
                    _showPoints = false;
                  });
                },
                child: Container(
                  color: Colors.blue[100],
                  child: Center(child: Text("Logo ${i + 1}")),
                ),
              );
            },
          ),
        ],
      ],
    );
  }
}

//
// ポイント交換画面
//
class PointExchangePage extends StatefulWidget {
  @override
  State<PointExchangePage> createState() => _PointExchangePageState();
}

class _PointExchangePageState extends State<PointExchangePage> {
  final List<String> companies =
      List.generate(10, (i) => "企業 ${i + 1}"); // ダミー企業名
  String? fromCompany;
  String? toCompany;
  final TextEditingController _pointController = TextEditingController();

  void _resetSelection() {
    setState(() {
      fromCompany = null;
      toCompany = null;
      _pointController.clear();
    });
  }

  void _exchangePoints() {
    final amount = int.tryParse(_pointController.text);
    if (fromCompany == null || toCompany == null || amount == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("企業とポイント数を正しく入力してください"),
      ));
      return;
    }
    if (fromCompany == toCompany) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("同じ企業間では交換できません"),
      ));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content:
          Text("「$fromCompany」から「$toCompany」に${amount}ポイントを交換しました！"),
    ));
    _resetSelection();
  }

  Future<void> _selectCompany(bool isFrom) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text(isFrom ? "送信元の企業を選択" : "送信先の企業を選択"),
          children: companies
              .map((c) => SimpleDialogOption(
                    onPressed: () => Navigator.pop(context, c),
                    child: Text(c),
                  ))
              .toList(),
        );
      },
    );
    if (result != null) {
      setState(() {
        if (isFrom) {
          fromCompany = result;
        } else {
          toCompany = result;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("ポイント交換")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // 上の企業選択
            GestureDetector(
              onTap: () => _selectCompany(true),
              child: Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  fromCompany ?? "送信元の企業を選択",
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),

            // 矢印と入力欄
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.arrow_downward, size: 32, color: Colors.blue),
                const SizedBox(width: 16),
                SizedBox(
                  width: 120,
                  child: TextField(
                    controller: _pointController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "ポイント数",
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 下の企業選択
            GestureDetector(
              onTap: () => _selectCompany(false),
              child: Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.green),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  toCompany ?? "送信先の企業を選択",
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),

            // 交換ボタン
            ElevatedButton(
              onPressed: _exchangePoints,
              child: const Text("ポイントを交換する"),
            ),
          ],
        ),
      ),
    );
  }
}

//
// マイページ
//
class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("マイページ")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Card(
            child: ListTile(
              title: Text("会員ナンバー: 1234567890"),
            ),
          ),
          Card(
            child: ListTile(
              title: Text("お気に入りの設定"),
            ),
          ),
          Card(
            child: ListTile(
              title: Text("文字サイズ変更"),
            ),
          ),
        ],
      ),
    );
  }
}