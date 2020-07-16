import 'dart:async';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';

class PreviewImageClipper extends StatefulWidget {
  final String imgUrl;
  final double offset;
  final double width;
  final double height;

  const PreviewImageClipper(
      {Key key,
      @required this.imgUrl,
      @required this.offset,
      @required this.width,
      @required this.height})
      : super(key: key);

  @override
  _PreviewImageClipperState createState() => _PreviewImageClipperState();
}

class _PreviewImageClipperState extends State<PreviewImageClipper> {
  ImageClipper clipper;
  final double size = 1;

  @override
  void initState() {
    super.initState();
    _clip();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: CustomPaint(
        painter: clipper,
        size: Size(widget.width * size, widget.height * size),
      ),
    );
  }

  void _clip() async {
    ui.Image uiImage = await _loadPreviewImge(widget.imgUrl);
    setState(() {
      clipper = ImageClipper(uiImage,
          width: widget.width, height: widget.height, offset: widget.offset);
    });
  }

  /// 监听图片加载
  Future<ui.Image> _loadPreviewImge(String imgUrl) async {
    ImageStream imageStream =
        CachedNetworkImageProvider(imgUrl).resolve(ImageConfiguration());
    Completer<ui.Image> completer = Completer<ui.Image>();
    void imageListener(ImageInfo info, bool synchronousCall) {
      ui.Image image = info.image;
      completer.complete(image);
      imageStream.removeListener(ImageStreamListener(imageListener));
    }

    imageStream.addListener(ImageStreamListener(imageListener));
    return completer.future;
  }
}

/// 图片裁剪
class ImageClipper extends CustomPainter {
  final ui.Image image;

  final double offset;

  // 宽高
  final double width;
  final double height;

  ImageClipper(this.image, {this.offset = 0, this.width = 0, this.height = 0});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();

    canvas.drawImageRect(image, Rect.fromLTWH(offset, 0, width, height),
        Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

/// 预览图小图裁剪
/// 不满足需求
class PreviewClipper extends CustomClipper<Path> {
  final double offset;

  // 宽高
  final double width;
  final double height;

  /// 构造函数，接收传递过来的宽高
  PreviewClipper(
      {this.offset = 0.0, @required this.width, @required this.height});

  /// 获取剪裁区域的接口
  /// 返回一个矩形 path
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(offset, 0.0);
    path.lineTo(offset + width, 0.0);
    path.lineTo(offset + width, height);
    path.lineTo(offset, height);
    path.close();
    return path;
  }

  /// 接口决定是否重新剪裁
  /// 如果在应用中，剪裁区域始终不会发生变化时应该返回 false，这样就不会触发重新剪裁，避免不必要的性能开销。
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
