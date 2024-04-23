import 'dart:async';

import 'package:flutter/material.dart';

import 'infinite_list_view.dart';

class FlutterInfiniteMarquee extends StatefulWidget {
  /// 每次移动步长,默认0.5,越大越快
  final double stepOffset;

  /// 自定义内容
  final IndexedWidgetBuilder itemBuilder;

  const FlutterInfiniteMarquee({
    super.key,
    this.stepOffset = 0.5,
    required this.itemBuilder,
  });

  @override
  State<FlutterInfiniteMarquee> createState() => _FlutterInfiniteMarqueeState();
}

class _FlutterInfiniteMarqueeState extends State<FlutterInfiniteMarquee> {
  // 执行动画的controller
  late InfiniteScrollController _controller;
  // 定时器timer
  late Timer _timer;
  // 定时器时间
  Duration duration = const Duration(milliseconds: 30);
  // 手势打断定时器
  bool timerStop = false;
  // 执行位移开始的偏移量
  double _offset = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = InfiniteScrollController(initialScrollOffset: _offset);
    _startScrollTimer();
  }

  /// 开启定时器
  _startScrollTimer() {
    _timer = Timer.periodic(duration, (timer) {
      _autoScroll();
    });
  }

  ///停止定时器
  _stopScrollTimer() {
    _timer.cancel();
  }

  /// 自动滚动
  _autoScroll() {
    double newOffset = _controller.offset + widget.stepOffset;
    if (timerStop == false) {
      _offset = newOffset;
      _controller.jumpTo(_offset);
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// 监听滚动
    return NotificationListener(
      onNotification: (ScrollNotification notification) {
        if (notification is ScrollStartNotification) {
          _stopScrollTimer();
        } else if (notification is ScrollUpdateNotification) {
          _stopScrollTimer();
        } else if (notification is ScrollEndNotification) {
          _startScrollTimer();
        }
        return false;
      },

      /// 监听手势
      child: Listener(
        onPointerDown: (detail) => setState(() {
          timerStop = true;
        }),
        onPointerMove: (detail) => setState(() {
          timerStop = true;
        }),
        onPointerUp: (detail) => setState(() {
          timerStop = false;
        }),
        onPointerCancel: (detail) => setState(() {
          timerStop = false;
        }),

        /// 无限滚动列表
        child: InfiniteListView.separated(
          scrollDirection: Axis.horizontal,
          controller: _controller,
          itemBuilder: widget.itemBuilder,
          separatorBuilder: (BuildContext context, int index) => const Divider(height: 0.0),
          anchor: 0.5,
        ),
      ),
    );
  }
}
