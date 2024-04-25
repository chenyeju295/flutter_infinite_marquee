import 'package:flutter/material.dart';
import 'package:flutter_infinite_marquee/flutter_infinite_marquee.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Marquee',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Marquee'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<String> _items = [
    '三字经',
    '水到渠成',
    '如鱼',
    '潜移默化',
    '帅',
    '人生苦短',
    '我用Flutter',
    '黑云压城城欲摧',
    '悬壶问道，月光转照'
  ];

  void _showToast(String item) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(content: Text(item));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              margin: const EdgeInsets.all(30),
              height: 200,
              child: InfiniteMarquee(
                scrollDirection: Axis.vertical,
                stepOffset: 50,
                duration: const Duration(milliseconds: 1000),
                itemBuilder: (BuildContext context, int index) {
                  String item = '${_items[index % _items.length]}  $index';
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                        height: 34,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                            color: Colors.greenAccent,
                            borderRadius: BorderRadius.circular(10)),
                        child: Text(item)),
                  );
                },
              ),
            ),
            SizedBox(
                height: 50,
                child: InfiniteMarquee(
                  stepOffset: -1,
                  itemBuilder: (BuildContext context, int index) {
                    String item = '${_items[index % _items.length]}  $index';
                    return GestureDetector(
                      onTap: () {
                        _showToast(item);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        color:
                            Colors.primaries[index % Colors.primaries.length],
                        child: Center(
                            child: Text(item,
                                style: const TextStyle(
                                    fontSize: 20, color: Colors.white))),
                      ),
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return Center(
                        child: Icon(Icons.hail_sharp,
                            color: Colors
                                .primaries[index % Colors.primaries.length]));
                  },
                )),
            Container(
                height: 50,
                margin: const EdgeInsets.only(top: 20),
                child: InfiniteMarquee(
                  itemBuilder: (BuildContext context, int index) {
                    String item = '${_items[index % _items.length]}  $index';
                    return GestureDetector(
                      onTap: () {
                        _showToast(item);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        color:
                            Colors.primaries[index % Colors.primaries.length],
                        child: Center(
                            child: Text(item,
                                style: const TextStyle(
                                    fontSize: 20, color: Colors.white))),
                      ),
                    );
                  },
                )),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                    margin: const EdgeInsets.only(top: 20),
                    width: 40,
                    height: 400,
                    child: InfiniteMarquee(
                      scrollDirection: Axis.vertical,
                      itemBuilder: (BuildContext context, int index) {
                        String item = _items[index % _items.length];
                        return GestureDetector(
                          onTap: () {
                            _showToast(item);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            color: Colors
                                .primaries[index % Colors.primaries.length],
                            child: Center(
                                child: Text(item,
                                    style: const TextStyle(
                                        fontSize: 20, color: Colors.white))),
                          ),
                        );
                      },
                    )),
                Container(
                    margin: const EdgeInsets.only(top: 20),
                    width: 40,
                    height: 400,
                    child: InfiniteMarquee(
                      stepOffset: -2,
                      scrollDirection: Axis.vertical,
                      itemBuilder: (BuildContext context, int index) {
                        String item = _items[index % _items.length];
                        return GestureDetector(
                          onTap: () {
                            _showToast(item);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            color: Colors
                                .primaries[index % Colors.primaries.length],
                            child: Center(
                                child: Text(item,
                                    style: const TextStyle(
                                        fontSize: 20, color: Colors.white))),
                          ),
                        );
                      },
                    )),
              ],
            )
          ],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
