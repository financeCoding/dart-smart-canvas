part of smartcanvas;

class Text extends Node {
  static TextMeasure s_textMeasure = new TextMeasure();
  static const String PX_SPACE = 'px ';

  Text(Map<String, dynamic> config): super(config) {}

  NodeImpl _createSvgImpl() {
    return new SvgText(this);
  }

  NodeImpl _createCanvasImpl() {
    throw ExpNotImplemented;
  }

  static num measureText(String font, String text) {
    return s_textMeasure.measureText(font, text);
  }

  void set text(String value) => setAttribute(TEXT, value);
  String get text => getAttribute(TEXT);

  /**
   * set/get font family. 'Arial' is default.
   */
  void set fontFamily(String value) => setAttribute(FONT_FAMILY, value);
  String get fontFamily => getAttribute(FONT_FAMILY, 'Arial');

//  /**
//   * set/get font variant. Can be 'normal' or 'small-caps'.  'normal' is the default.
//   */
//  void set fontVariant(String value) => setAttribute('font-variant', value);
//  String get fontVariant => getAttribute('font-variant', 'normal');
//
//  /**
//   *  set/get font style. Can be 'normal', 'italic' or 'bold'. 'normal' is default.
//   */
//  void set fontStyle(String value) => setAttribute('font-style', value);
//  String get fontStyle => getAttribute('font-style', 'normal');

  /**
   * set/get font size. 12 is default.
   */
  void set fontSize(num value) => setAttribute(FONT_SIZE, value);
  num get fontSize => getAttribute(FONT_SIZE, 12);

  /**
   * get font.
   */
  String get font {
    return '$fontSize' + PX_SPACE + fontFamily;
  }

  /**
   * set/get padding
   */
  void set padding (num value) => setAttribute(PADDING, value);
  num get padding => getAttribute(PADDING, 0);

  num get width {
    if (_impl != null) {
      return _impl.width;
    } else {
      return s_textMeasure.measureText(font, text);
    }
  }

  void set textAnchor(String value) => setAttribute(TEXT_ANCHOR, value);
  String get textAnchor => getAttribute(TEXT_ANCHOR);

  num get height => fontSize;
}