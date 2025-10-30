# [flutter_infinite_marquee](https://pub.dev/packages/flutter_infinite_marquee)

[中文文档](README-CN.md)

Frame-driven, lifecycle-aware marquee with unified speed control.
Smooth automatic scrolling of looping text or widgets with click/drag interaction support.


## Installation
To use this package, add flutter_infinite_marquee as a dependency in the pubspec.yaml file.
```yaml
dependencies:
  flutter_infinite_marquee: last_version
```

## Usage
Import the package in your Dart file.

```dart
import 'package:flutter_infinite_marquee/flutter_infinite_marquee.dart';
```

```dart
SizedBox(
  height: 50,
  child: InfiniteMarquee(
    speed: 60, // pixels per second; negative for reverse
    itemBuilder: (BuildContext context, int index) {
      return Text('Hello, world! $index');
    },
    separatorBuilder: (context, index) => const SizedBox(width: 12),
  ),
)
```

## Parameters
- `speed`: logical pixels per second (double, required). Negative scrolls in reverse.
- `autoplay`: start automatically (default true).
- `controller`: `MarqueeController` for `play()`, `pause()`, `setSpeed()`.
- `scrollDirection`: `Axis.horizontal` or `Axis.vertical`.
- `itemBuilder`: builder for item at index.
- `separatorBuilder`: optional builder between items.
- `itemCount`: optional finite items; `null` means unbounded.
- `itemExtent`: optional fixed extent to improve performance.
- `physics`, `padding`, `initialScrollOffset`.

## Sample diagram
![sample_diagram.gif](sample_diagram.gif)


If you encounter any problems or have suggestions, please create an issue on [GitHub issues](https://github.com/chenyeju295/flutter_infinite_marquee/issues). Thank you for using!
