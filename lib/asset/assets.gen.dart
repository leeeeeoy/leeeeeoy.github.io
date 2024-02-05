/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: directives_ordering,unnecessary_import,implicit_dynamic_list_literal,deprecated_member_use

import 'package:flutter/widgets.dart';

class $AssetBppGen {
  const $AssetBppGen();

  /// File path: asset/bpp/icon.png
  AssetGenImage get icon => const AssetGenImage('asset/bpp/icon.png');

  /// File path: asset/bpp/screenshot1.jpg
  AssetGenImage get screenshot1 => const AssetGenImage('asset/bpp/screenshot1.jpg');

  /// File path: asset/bpp/screenshot2.jpg
  AssetGenImage get screenshot2 => const AssetGenImage('asset/bpp/screenshot2.jpg');

  /// File path: asset/bpp/screenshot3.jpg
  AssetGenImage get screenshot3 => const AssetGenImage('asset/bpp/screenshot3.jpg');

  /// File path: asset/bpp/screenshot4.jpg
  AssetGenImage get screenshot4 => const AssetGenImage('asset/bpp/screenshot4.jpg');

  /// File path: asset/bpp/screenshot5.jpg
  AssetGenImage get screenshot5 => const AssetGenImage('asset/bpp/screenshot5.jpg');

  /// File path: asset/bpp/screenshot6.jpg
  AssetGenImage get screenshot6 => const AssetGenImage('asset/bpp/screenshot6.jpg');

  /// List of all assets
  List<AssetGenImage> get values =>
      [icon, screenshot1, screenshot2, screenshot3, screenshot4, screenshot5, screenshot6];
}

class $AssetCafeinGen {
  const $AssetCafeinGen();

  /// File path: asset/cafein/icon.jpg
  AssetGenImage get icon => const AssetGenImage('asset/cafein/icon.jpg');

  /// File path: asset/cafein/screenshot1.jpg
  AssetGenImage get screenshot1 => const AssetGenImage('asset/cafein/screenshot1.jpg');

  /// File path: asset/cafein/screenshot2.jpg
  AssetGenImage get screenshot2 => const AssetGenImage('asset/cafein/screenshot2.jpg');

  /// File path: asset/cafein/screenshot3.jpg
  AssetGenImage get screenshot3 => const AssetGenImage('asset/cafein/screenshot3.jpg');

  /// File path: asset/cafein/screenshot4.jpg
  AssetGenImage get screenshot4 => const AssetGenImage('asset/cafein/screenshot4.jpg');

  /// File path: asset/cafein/screenshot5.jpg
  AssetGenImage get screenshot5 => const AssetGenImage('asset/cafein/screenshot5.jpg');

  /// List of all assets
  List<AssetGenImage> get values => [icon, screenshot1, screenshot2, screenshot3, screenshot4, screenshot5];
}

class $AssetCareerGen {
  const $AssetCareerGen();

  /// File path: asset/career/dozn.png
  AssetGenImage get dozn => const AssetGenImage('asset/career/dozn.png');

  /// List of all assets
  List<AssetGenImage> get values => [dozn];
}

class $AssetProfileGen {
  const $AssetProfileGen();

  /// File path: asset/profile/main.jpg
  AssetGenImage get main => const AssetGenImage('asset/profile/main.jpg');

  /// List of all assets
  List<AssetGenImage> get values => [main];
}

class Assets {
  Assets._();

  static const $AssetBppGen bpp = $AssetBppGen();
  static const $AssetCafeinGen cafein = $AssetCafeinGen();
  static const $AssetCareerGen career = $AssetCareerGen();
  static const $AssetProfileGen profile = $AssetProfileGen();
  static const AssetGenImage splash = AssetGenImage('asset/splash.png');

  /// List of all assets
  static List<AssetGenImage> get values => [splash];
}

class AssetGenImage {
  const AssetGenImage(this._assetName);

  final String _assetName;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = false,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.low,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({
    AssetBundle? bundle,
    String? package,
  }) {
    return AssetImage(
      _assetName,
      bundle: bundle,
      package: package,
    );
  }

  String get path => _assetName;

  String get keyName => _assetName;
}
