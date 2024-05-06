import 'dart:async';

import 'package:flutter/material.dart';
import 'infinite_list_view.dart';

/// A marquee component that provides automatic scrolling functionality, scrolling looping text or widgets onto the screen.
/// It offers customizations for scroll direction, step length, frequency, and supports both click and swipe interactions.
class InfiniteMarquee extends StatefulWidget {
  /// The distance of each step, default value is 1.
  /// When it is a negative number, the movement is in the reverse direction.
  final double stepOffset;

  /// The frequency of auto scrolling, default value is 20 milliseconds.
  /// Works in conjunction with [stepOffset].
  final Duration frequency;

  /// Item builder function.
  final IndexedWidgetBuilder itemBuilder;

  /// Separator builder function.
  final IndexedWidgetBuilder? separatorBuilder;

  /// Initial scroll offset when loading.
  final double initialScrollOffset;

  /// The direction of scrolling.
  final Axis scrollDirection;

  /// create
  const InfiniteMarquee({
    super.key,
    required this.itemBuilder,
    this.stepOffset = 1,
    this.initialScrollOffset = 0.0,
    this.scrollDirection = Axis.horizontal,
    this.frequency = const Duration(milliseconds: 10),
    this.separatorBuilder,
  });

  @override
  State<InfiniteMarquee> createState() => _InfiniteMarqueeState();
}

class _InfiniteMarqueeState extends State<InfiniteMarquee> {
  /// InfiniteScrollController
  late InfiniteScrollController _controller;

  /// 自动滚动定时器
  late Timer _timer;

  /// 是否停止滚动
  bool stopScroll = false;

  @override
  void initState() {
    super.initState();
    _controller = InfiniteScrollController(
        initialScrollOffset: widget.initialScrollOffset);
    _startScrollTimer();
  }

  /// 启动自动滚动定时器
  _startScrollTimer() {
    _timer = Timer.periodic(widget.frequency, (timer) {
      if (stopScroll == false) {
        _controller.jumpTo(_controller.offset + widget.stepOffset);
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _controller.dispose();
    super.dispose();
  }

  /// 处理滚动事件
  bool _onNotification(ScrollNotification notification) {
    if (notification is ScrollStartNotification) {
      _timer.cancel();
    } else if (notification is ScrollUpdateNotification) {
      _timer.cancel();
    } else if (notification is ScrollEndNotification) {
      _startScrollTimer();
    }
    return false;
  }

  /// 停止滚动
  _stopScroll(bool value) {
    stopScroll = value;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener(
      onNotification: _onNotification,
      child: Listener(
        onPointerDown: (_) => _stopScroll(true),
        onPointerMove: (_) => _stopScroll(true),
        onPointerUp: (_) => _stopScroll(false),
        onPointerCancel: (_) => _stopScroll(false),
        child: InfiniteListView.separated(
          scrollDirection: widget.scrollDirection,
          controller: _controller,
          itemBuilder: widget.itemBuilder,
          separatorBuilder: widget.separatorBuilder,
        ),
      ),
    );
  }
}
