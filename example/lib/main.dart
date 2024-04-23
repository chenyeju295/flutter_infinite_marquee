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
    '风流倜傥',
    '卧虎藏龙',
    '披荆斩棘',
    '出类拔萃',
    '潜移默化',
    '悬壶问道',
    '指鹿为马',
    '画龙点睛'
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
      body: Center(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 50,
              child: InfiniteMarquee(
                itemBuilder: (BuildContext context, int index) {
                  return Text('Hello, world! $index');
                },
              ),
            ),
            Container(
                height: 50,
                margin: const EdgeInsets.only(top: 20),
                child: InfiniteMarquee(
                  stepOffset: -1,
                  itemBuilder: (BuildContext context, int index) {
                    String item = _items[index % _items.length];
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
                    return const Center(child: Text(' - '));
                  },
                )),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                    margin: const EdgeInsets.only(top: 20),
                    width: 50,
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
                    width: 50,
                    height: 400,
                    child: InfiniteMarquee(
                      stepOffset: -1,
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
