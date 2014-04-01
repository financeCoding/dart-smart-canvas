part of smartcanvas.svg;

class SvgLayer extends SvgNode implements LayerImpl {
  List<SvgNode> _children = new List<SvgNode>();

  SvgLayer(shell): super(shell) {
    shell
      .on('widthChanged', _onWidthChanged)
      .on('heightChanged', _onHeightChanged)
      .on('opacityChanged', _onOpacityChanged)
      .on('scaleChanged', _onScaleChanged);
  }

  DOM.Element _createElement() {
    return new SVG.SvgSvgElement();
  }

  Set<String> _getElementAttributeNames() {
    return new Set<String>.from([ID, CLASS]);
  }

  void _setElementAttributes() {
    super._setElementAttributes();
  }

  void _setElementStyles() {
    super._setElementStyles();
    _element.style.setProperty(POSITION, ABSOLUTE);
    _element.style.setProperty(TOP, ZERO);
    _element.style.setProperty(LEFT, ZERO);
    _element.style.setProperty(MARGIN, ZERO);
    _element.style.setProperty(PADDING, ZERO);
  }

  void add(SvgNode child) {
    _children.add(child);
    child.parent = this;
    this._element.append(child._element);
  }

  void removeChild(SvgNode node) {
    node.parent = null;
    node.remove();
  }

  void removeChildren() {
    _children.forEach((child) => child.remove());
  }

  void insert(int index, SvgNode node) {
    node.parent = this;
    _children.insert(index, node);
    this._element.nodes.insert(index, node._element);
  }

  void resume() {}
  void suspend() {}

  void _onWidthChanged(oldValue, newValue) {
    _element.style.width = '$newValue';
  }

  void _onHeightChanged(oldValue, newValue) {
    _element.style.height = '$newValue';
  }

  void _onOpacityChanged(int oldValue, int newValue) {
    _element.style.opacity = '$newValue';
  }

  void _onScaleChanged(int oldValue, int newValue) {

  }

  List<SvgNode> get children => _children;

  String get _nodeName => SC_LAYER;

  num get absolutePosition => 0;
}