# [flutter_infinite_marquee](https://pub.dev/packages/flutter_infinite_marquee)

基于帧驱动且支持生命周期感知的跑马灯组件，统一以 `speed`（像素/秒）控制滚动速度，支持点击与拖拽交互，滚动更平滑。

## 安装

要使用此包，请在`pubspec.yaml`文件中将`flutter_infinite_marquee`添加为依赖项。

```yaml
dependencies:
  flutter_infinite_marquee: last_version
```

## 用法

在你的Dart文件中导入该包。

```dart
import 'package:flutter_infinite_marquee/flutter_infinite_marquee.dart';
```
在你的Flutter应用程序中使用`InfiniteMarquee`组件。

```dart
SizedBox(
  height: 50,
  child: InfiniteMarquee(
    speed: 60, // 像素/秒；负值反向
    itemBuilder: (BuildContext context, int index) {
      return Text('Hello, world! $index');
    },
    separatorBuilder: (context, index) => const SizedBox(width: 12),
  ),
)
```

## 参数

- `speed`：逻辑像素/秒（必填），负值代表反向滚动。
- `autoplay`：是否自动开始（默认 true）。
- `controller`：`MarqueeController`，提供 `play()`、`pause()`、`setSpeed()`。
- `scrollDirection`：`Axis.horizontal` 或 `Axis.vertical`。
- `itemBuilder`：构建每个条目的组件。
- `separatorBuilder`：构建分隔符的组件（可选）。
- `itemCount`：可选，指定有限条目数；为空则无限。
- `itemExtent`：可选，固定尺寸以提升性能。
- `physics`、`padding`、`initialScrollOffset`。


## 示例图
![sample_diagram.gif](sample_diagram.gif)

请随意定制组件以满足你的应用程序需求。
如果遇到任何问题或有改进建议，请随时在[GitHub issues](https://github.com/chenyeju295/flutter_infinite_marquee/issues)上创建问题。感谢使用！
