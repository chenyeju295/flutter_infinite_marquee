import 'dart:math' as math;

import 'package:flutter/gestures.dart' show DragStartBehavior;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// A marquee component that provides automatic scrolling functionality, scrolling looping text or widgets onto the screen.
/// Optimized to use frame-driven scrolling for smoothness and lifecycle awareness.
class InfiniteMarquee extends StatefulWidget {
  /// Optional controller for imperative control.
  final MarqueeController? controller;

  /// Unified speed in logical pixels per second. Negative value scrolls in reverse.
  final double speed;

  /// Autoplay on mount.
  final bool autoplay;

  /// Item builder function.
  final IndexedWidgetBuilder itemBuilder;

  /// Separator builder function.
  final IndexedWidgetBuilder? separatorBuilder;

  /// Optional total item count. If null, list is unbounded.
  final int? itemCount;

  /// Initial scroll offset when loading.
  final double initialScrollOffset;

  /// The direction of scrolling.
  final Axis scrollDirection;

  /// Optional physics passthrough.
  final ScrollPhysics? physics;

  /// Optional padding passthrough.
  final EdgeInsets? padding;

  /// Optional fixed extent for items to improve performance when applicable.
  final double? itemExtent;

  const InfiniteMarquee({
    super.key,
    required this.itemBuilder,
    this.separatorBuilder,
    this.itemCount,
    this.speed = 48.0,
    this.autoplay = true,
    this.initialScrollOffset = 0.0,
    this.scrollDirection = Axis.horizontal,
    this.physics,
    this.padding,
    this.itemExtent,
    this.controller,
  });

  @override
  State<InfiniteMarquee> createState() => _InfiniteMarqueeState();
}

class _InfiniteMarqueeState extends State<InfiniteMarquee>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final InfiniteScrollController _controller;
  late final Ticker _ticker;

  bool _pausedByUser = false; // pause from user touch
  bool _autoplayActive = false; // internal play state
  Duration? _lastTickElapsed;

  double _currentPps = 0.0;

  double _computeInitialPps() {
    return widget.speed;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = InfiniteScrollController(
      initialScrollOffset: widget.initialScrollOffset,
    );
    _ticker = createTicker(_onTick);
    _currentPps = _computeInitialPps();
    widget.controller?._attach(
      play: _play,
      pause: _pause,
      setSpeed: (v) {
        _currentPps = v;
        if (v == 0) {
          _pause();
        } else if (widget.autoplay && !_pausedByUser) {
          _play();
        }
      },
    );
    if (widget.autoplay) {
      _play();
    }
  }

  @override
  void didUpdateWidget(covariant InfiniteMarquee oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update speed if changed via widget.
    final newPps = _computeInitialPps();
    if (newPps != _currentPps) {
      _currentPps = newPps;
    }
    // Controller instance switched
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._detach();
      widget.controller?._attach(
        play: _play,
        pause: _pause,
        setSpeed: (v) {
          _currentPps = v;
          if (v == 0) {
            _pause();
          } else if (widget.autoplay && !_pausedByUser) {
            _play();
          }
        },
      );
    }
    // If autoplay flag changes, honor it.
    if (oldWidget.autoplay != widget.autoplay) {
      if (widget.autoplay) {
        _play();
      } else {
        _pause();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker.dispose();
    widget.controller?._detach();
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _pause();
    } else if (state == AppLifecycleState.resumed &&
        !_pausedByUser &&
        widget.autoplay) {
      _play();
    }
  }

  void _play() {
    if (_autoplayActive) return;
    _lastTickElapsed = null;
    _autoplayActive = true;
    if (!_ticker.isActive) _ticker.start();
  }

  void _pause() {
    _autoplayActive = false;
    if (_ticker.isActive) _ticker.stop();
  }

  void _onTick(Duration elapsed) {
    if (!_autoplayActive) return;
    if (!mounted) return;
    if (!_controller.hasClients) return;

    final last = _lastTickElapsed;
    _lastTickElapsed = elapsed;
    if (last == null) return; // skip first frame until we have a delta
    final dtSeconds = (elapsed - last).inMicroseconds / 1000000.0;
    final delta = _currentPps * dtSeconds;

    // Direction is encoded in the sign of speed.
    final newOffset = _controller.offset + delta;
    _safeJumpTo(newOffset);

    // Recenter occasionally to avoid large doubles growing over time.
    _recenterIfNeeded();
  }

  void _safeJumpTo(double offset) {
    try {
      _controller.jumpTo(offset);
    } catch (_) {
      // Ignore rare race conditions when the position is not yet attached.
    }
  }

  void _recenterIfNeeded() {
    const double threshold = 1e6; // large threshold to avoid precision drift
    if (_controller.offset.abs() > threshold) {
      // Map back near zero. If itemExtent is available, align to its multiples to avoid visual jumps.
      final extent = widget.itemExtent;
      final period = extent != null && extent > 0 ? extent * 100 : 1000.0;
      final reduced = _controller.offset % period;
      _safeJumpTo(reduced);
    }
  }

  bool _onNotification(ScrollNotification notification) {
    if (notification is UserScrollNotification) {
      // Resume only when idle and not paused by user.
      if (notification.direction == ScrollDirection.idle &&
          !_pausedByUser &&
          widget.autoplay) {
        _play();
      } else {
        _pause();
      }
    } else if (notification is ScrollStartNotification) {
      _pause();
    } else if (notification is ScrollEndNotification) {
      if (!_pausedByUser && widget.autoplay) _play();
    }
    return false;
  }

  void _setUserPaused(bool paused) {
    _pausedByUser = paused;
    if (paused) {
      _pause();
    } else {
      if (widget.autoplay) _play();
    }
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _onNotification,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanDown: (_) => _setUserPaused(true),
        onPanCancel: () => _setUserPaused(false),
        onPanEnd: (_) => _setUserPaused(false),
        child: InfiniteListView.separated(
          scrollDirection: widget.scrollDirection,
          controller: _controller,
          physics: widget.physics,
          padding: widget.padding,
          itemExtent: widget.itemExtent,
          itemCount: widget.itemCount,
          itemBuilder: widget.itemBuilder,
          separatorBuilder: widget.separatorBuilder,
        ),
      ),
    );
  }
}

/// Controller for imperative marquee control.
///
/// Expose simple controls to manage marquee playback and speed at runtime.
class MarqueeController {
  VoidCallback? _play;
  VoidCallback? _pause;
  ValueChanged<double>? _setSpeed;

  void _attach(
      {required VoidCallback play,
      required VoidCallback pause,
      required ValueChanged<double> setSpeed}) {
    _play = play;
    _pause = pause;
    _setSpeed = setSpeed;
  }

  void _detach() {
    _play = null;
    _pause = null;
    _setSpeed = null;
  }

  /// Start/resume autoplay if available.
  void play() => _play?.call();

  /// Pause autoplay.
  void pause() => _pause?.call();

  /// Set scrolling speed in logical pixels per second. Negative values scroll in reverse.
  void setSpeed(double pixelsPerSecond) => _setSpeed?.call(pixelsPerSecond);
}

/// Infinite ListView (inlined) and its controller
class InfiniteListView extends StatefulWidget {
  const InfiniteListView.builder({
    super.key,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.controller,
    this.physics,
    this.padding,
    this.itemExtent,
    required this.itemBuilder,
    this.itemCount,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.cacheExtent,
    this.anchor = 0.0,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
  }) : separatorBuilder = null;

  const InfiniteListView.separated({
    super.key,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.controller,
    this.physics,
    this.padding,
    required this.itemBuilder,
    required this.separatorBuilder,
    this.itemCount,
    this.itemExtent,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.cacheExtent,
    this.anchor = 0.0,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
  });

  final Axis scrollDirection;
  final bool reverse;
  final InfiniteScrollController? controller;
  final ScrollPhysics? physics;
  final EdgeInsets? padding;
  final IndexedWidgetBuilder itemBuilder;
  final IndexedWidgetBuilder? separatorBuilder;
  final int? itemCount;
  final double? itemExtent;
  final double? cacheExtent;
  final double anchor;
  final bool addAutomaticKeepAlives;
  final bool addRepaintBoundaries;
  final bool addSemanticIndexes;
  final DragStartBehavior dragStartBehavior;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;
  final String? restorationId;
  final Clip clipBehavior;

  @override
  State<InfiniteListView> createState() => _InfiniteListViewState();
}

class _InfiniteListViewState extends State<InfiniteListView> {
  InfiniteScrollController? _controller;
  ViewportOffset? _attachedOffset;
  VoidCallback? _attachedOffsetListener;

  InfiniteScrollController get _effectiveController =>
      widget.controller ?? _controller!;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _controller = InfiniteScrollController();
    }
  }

  @override
  void didUpdateWidget(InfiniteListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      if (oldWidget.controller == null && widget.controller != null) {
        // going from internal to external
        _controller?.dispose();
        _controller = null;
      } else if (oldWidget.controller != null && widget.controller == null) {
        // going from external to internal
        _controller = InfiniteScrollController();
      }
    }
  }

  @override
  void dispose() {
    // Remove any attached offset listener to avoid leaks and duplicates
    if (_attachedOffset != null && _attachedOffsetListener != null) {
      _attachedOffset!.removeListener(_attachedOffsetListener!);
    }
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> slivers = _buildSlivers(context, negative: false);
    final List<Widget> negativeSlivers = _buildSlivers(context, negative: true);
    final AxisDirection axisDirection = _getDirection(context);
    final scrollPhysics =
        widget.physics ?? const AlwaysScrollableScrollPhysics();
    return Scrollable(
      axisDirection: axisDirection,
      controller: _effectiveController,
      physics: scrollPhysics,
      viewportBuilder: (BuildContext context, ViewportOffset offset) {
        return Builder(builder: (BuildContext context) {
          final state = Scrollable.of(context);
          final negativeOffset = _InfiniteScrollPosition(
            physics: scrollPhysics,
            context: state,
            initialPixels: -offset.pixels,
            keepScrollOffset: _effectiveController.keepScrollOffset,
            negativeScroll: true,
          );

          // Ensure only one listener is attached for the current offset
          if (!identical(_attachedOffset, offset)) {
            if (_attachedOffset != null && _attachedOffsetListener != null) {
              _attachedOffset!.removeListener(_attachedOffsetListener!);
            }
            _attachedOffset = offset;
            _attachedOffsetListener = () {
              negativeOffset._forceNegativePixels(offset.pixels);
            };
            offset.addListener(_attachedOffsetListener!);
          } else if (_attachedOffsetListener == null) {
            // Recover if listener was lost
            _attachedOffsetListener = () {
              negativeOffset._forceNegativePixels(offset.pixels);
            };
            offset.addListener(_attachedOffsetListener!);
          }

          return Stack(
            children: <Widget>[
              Viewport(
                axisDirection: flipAxisDirection(axisDirection),
                anchor: 1.0 - widget.anchor,
                offset: negativeOffset,
                slivers: negativeSlivers,
                cacheExtent: widget.cacheExtent,
              ),
              Viewport(
                axisDirection: axisDirection,
                anchor: widget.anchor,
                offset: offset,
                slivers: slivers,
                cacheExtent: widget.cacheExtent,
              ),
            ],
          );
        });
      },
    );
  }

  AxisDirection _getDirection(BuildContext context) {
    return getAxisDirectionFromAxisReverseAndDirectionality(
        context, widget.scrollDirection, widget.reverse);
  }

  List<Widget> _buildSlivers(BuildContext context, {bool negative = false}) {
    final itemExtent = widget.itemExtent;
    final padding = widget.padding ?? EdgeInsets.zero;
    return <Widget>[
      SliverPadding(
        padding: negative
            ? padding - EdgeInsets.only(bottom: padding.bottom)
            : padding - EdgeInsets.only(top: padding.top),
        sliver: (itemExtent != null)
            ? SliverFixedExtentList(
                delegate: negative
                    ? negativeChildrenDelegate
                    : positiveChildrenDelegate,
                itemExtent: itemExtent,
              )
            : SliverList(
                delegate: negative
                    ? negativeChildrenDelegate
                    : positiveChildrenDelegate,
              ),
      )
    ];
  }

  SliverChildDelegate get negativeChildrenDelegate {
    final separatorBuilder = widget.separatorBuilder;
    final itemCount = widget.itemCount;
    return SliverChildBuilderDelegate(
      (BuildContext context, int index) {
        if (separatorBuilder != null) {
          final itemIndex = (-1 - index) ~/ 2;
          return index.isOdd
              ? widget.itemBuilder(context, itemIndex)
              : separatorBuilder(context, itemIndex);
        } else {
          return widget.itemBuilder(context, -1 - index);
        }
      },
      childCount: separatorBuilder == null
          ? itemCount
          : (itemCount != null ? math.max(0, itemCount * 2 - 1) : null),
      addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
      addRepaintBoundaries: widget.addRepaintBoundaries,
    );
  }

  SliverChildDelegate get positiveChildrenDelegate {
    final separatorBuilder = widget.separatorBuilder;
    final itemCount = widget.itemCount;
    return SliverChildBuilderDelegate(
      (separatorBuilder != null)
          ? (BuildContext context, int index) {
              final itemIndex = index ~/ 2;
              return index.isEven
                  ? widget.itemBuilder(context, itemIndex)
                  : separatorBuilder(context, itemIndex);
            }
          : widget.itemBuilder,
      childCount: separatorBuilder == null
          ? itemCount
          : (itemCount != null ? math.max(0, itemCount * 2 - 1) : null),
      addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
      addRepaintBoundaries: widget.addRepaintBoundaries,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
        .add(EnumProperty<Axis>('scrollDirection', widget.scrollDirection));
    properties.add(FlagProperty('reverse',
        value: widget.reverse, ifTrue: 'reversed', showName: true));
    properties.add(DiagnosticsProperty<ScrollController>(
        'controller', widget.controller,
        showName: false, defaultValue: null));
    properties.add(DiagnosticsProperty<ScrollPhysics>('physics', widget.physics,
        showName: false, defaultValue: null));
    properties.add(DiagnosticsProperty<EdgeInsetsGeometry>(
        'padding', widget.padding,
        defaultValue: null));
    properties.add(
        DoubleProperty('itemExtent', widget.itemExtent, defaultValue: null));
    properties.add(
        DoubleProperty('cacheExtent', widget.cacheExtent, defaultValue: null));
  }
}

/// Same as a [ScrollController] except it provides [ScrollPosition] objects with infinite bounds.
class InfiniteScrollController extends ScrollController {
  InfiniteScrollController({
    super.initialScrollOffset,
    super.keepScrollOffset,
    super.debugLabel,
  });

  @override
  ScrollPosition createScrollPosition(ScrollPhysics physics,
      ScrollContext context, ScrollPosition? oldPosition) {
    return _InfiniteScrollPosition(
      physics: physics,
      context: context,
      initialPixels: initialScrollOffset,
      keepScrollOffset: keepScrollOffset,
      oldPosition: oldPosition,
      debugLabel: debugLabel,
    );
  }
}

class _InfiniteScrollPosition extends ScrollPositionWithSingleContext {
  _InfiniteScrollPosition({
    required super.physics,
    required super.context,
    super.initialPixels,
    super.keepScrollOffset,
    super.oldPosition,
    super.debugLabel,
    this.negativeScroll = false,
  });

  final bool negativeScroll;

  void _forceNegativePixels(double value) {
    super.forcePixels(-value);
  }

  @override
  void saveScrollOffset() {
    if (!negativeScroll) {
      super.saveScrollOffset();
    }
  }

  @override
  void restoreScrollOffset() {
    if (!negativeScroll) {
      super.restoreScrollOffset();
    }
  }

  @override
  double get minScrollExtent => double.negativeInfinity;

  @override
  double get maxScrollExtent => double.infinity;
}
