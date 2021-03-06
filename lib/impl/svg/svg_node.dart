part of smartcanvas.svg;

abstract class SvgNode extends NodeImpl {
  SVG.SvgElement _element;
  SVG.Matrix _elMatrix = new SVG.SvgSvgElement().createSvgMatrix();

  bool _dragging = false;
  bool _dragStarted = false;
  num _dragOffsetX;
  num _dragOffsetY;

  Set<String> _classNames = new Set<String>();
  Set<String> _registeredDOMEvents = new Set<String>();
  var _dragMoveHandler;
  var _dragEndHandler;

  SvgNode(Node shell) : super(shell) {
    _setClassName();
    _element = _createElement();
    _element.dataset['scNode'] = '${shell.uid}';
    _setElementAttributes();
    _setElementStyles();
    translate();

    if (getAttribute(DRAGGABLE) == true) {
      _startDragHandling();
    }

    if(getAttribute(LISTENING) == true) {
      this.eventListeners.forEach((k, v) {
        _registerDOMEvent(k, v);
      });
    }

    this.shell
    .on('draggableChanged', (oldValue, newValue) {
      if (newValue) {
        _startDragHandling();
      } else {
        _stopDragHandling();
      }
    })
    .on(ANY_CHANGED, _handleAttrChange)
    .on('translateXChanged', (oldValue, newValue) { translate(); })
    .on('translateYChanged', (oldValue, newValue) { translate(); });
  }

  String get type => svg;

  SVG.SvgElement get element => _element;

  SVG.SvgElement _createElement();

  void _setClassName() {
    _classNames.add(_nodeName);
    if (hasAttribute(CLASS)) {
      _classNames.addAll(getAttribute(CLASS).split(SPACE));
    }
    setAttribute(CLASS, _classNames.join(SPACE));
  }

  void _startDragHandling() {
    _element.onMouseDown.listen(dragStart).resume();
  }

  void _stopDragHandling() {
    _element.onMouseDown.listen(dragStart).cancel();
  }

  Set<String> _getElementAttributeNames() {
    return new Set<String>.from([ID, CLASS]);
  }

  List<String> _getStyleNames() {
    return [STROKE, STROKE_WIDTH, STROKE_OPACITY,
            STROKE_LINECAP, STROKE_DASHARRAY,
            FILL, OPACITY, DISPLAY];
  }

  void _setElementAttributes() {
    var attrs = _getElementAttributeNames();
    attrs.forEach(_setElementAttribute);
  }

  void _setElementAttribute(String attr) {
    var value = getAttribute(attr);
    if (value != null) {
      if (!(value is String) || !value.isEmpty) {
        _element.attributes[attr] = '$value';
      }
    }
  }

  void _setElementStyles() {
    _getStyleNames().forEach((name) {
      _setElementStyle(name);
    });
  }

  void _setElementStyle(String name) {
    var value = getAttribute(name);
    if (value != null) {
      if (value is SCPattern) {
        _element.setAttribute(name, 'url(#${value.id})');
        return;
      }
      _element.style.setProperty(name, '${getAttribute(name)}');
    } else {
      _element.style.removeProperty(name);
    }
  }

  void remove() {
    _element.remove();
    if (parent != null) {
      (parent as Container).children.remove(this);
    }
    parent = null;
  }

  void _registerDOMEvent(String event, EventHandlers handler) {
    Function eventHandler = fireEvent(handler);
    switch (event) {
      case MOUSEDOWN:
        _registeredDOMEvents.add(MOUSEDOWN);
        _element.onMouseDown.listen(eventHandler);
        break;
      case MOUSEUP:
        _registeredDOMEvents.add(MOUSEUP);
        _element.onMouseUp.listen(eventHandler);
        break;
      case MOUSEENTER:
        _registeredDOMEvents.add(MOUSEENTER);
        _element.onMouseEnter.listen(eventHandler);
        break;
      case MOUSELEAVE:
        _registeredDOMEvents.add(MOUSELEAVE);
        _element.onMouseLeave.listen(eventHandler);
        break;
      case MOUSEOVER:
        _registeredDOMEvents.add(MOUSEOVER);
        _element.onMouseOver.listen(eventHandler);
        break;
      case MOUSEOUT:
        _registeredDOMEvents.add(MOUSEOUT);
        _element.onMouseOut.listen(eventHandler);
        break;
      case MOUSEMOVE:
        _registeredDOMEvents.add(MOUSEMOVE);
        _element.onMouseMove.listen(_onMouseMove);
        break;
      case CLICK:
        _registeredDOMEvents.add(CLICK);
        _element.onClick.listen(eventHandler);
        break;
      case DBLCLICK:
        _registeredDOMEvents.add(DBLCLICK);
        _element.onDoubleClick.listen(eventHandler);
        break;
     }
  }

  Function fireEvent(EventHandlers handlers) {
    return (e) => handlers(e);
  }

  void dragStart(DOM.MouseEvent e) {
    if (e.button != 0 ||
        !DOM.window.navigator.userAgent.contains('Mac OS') ||
        e.ctrlKey ||
        stage.dragging) {
      return;
    }

    e.preventDefault();
    e.stopPropagation();
    this._dragging = true;

    var pointerPosition = this.stage.pointerPosition;
    var m = (_element as SVG.GraphicsElement).getCtm();

    this._dragOffsetX = pointerPosition.x - m.e / m.a + stage.tx; //* stage.scaleX;
    this._dragOffsetY = pointerPosition.y - m.f / m.d + stage.ty; // * stage.scaleY;

    if (_dragMoveHandler == null) {
      _dragMoveHandler = this.stage.element.onMouseMove.listen(_dragMove);
    }
    _dragMoveHandler.resume();

    if (_dragEndHandler == null) {
      _dragEndHandler = this.stage.element.onMouseUp.listen(_dragEnd);
    }
    _dragEndHandler.resume();
  }

  void _dragMove(DOM.MouseEvent e) {
    if (_dragging) {
      e.preventDefault();
      e.stopPropagation();

      if (!_dragStarted) {
        fire('dragstart', e);
        _dragStarted = true;
      }
      var pointerPosition = this.stage.pointerPosition;
      var m = (_element as SVG.GraphicsElement).getCtm();

      transformMatrix.tx = (pointerPosition.x - this._dragOffsetX);
      transformMatrix.ty = (pointerPosition.y - this._dragOffsetY);

      translate();
      fire(DRAGMOVE, e);
    }
  }

  void _dragEnd(DOM.MouseEvent e) {
    e.preventDefault();
    e.stopPropagation();
    _dragging = false;

    if (stage != null) {
      _dragMoveHandler.pause();
      _dragEndHandler.pause();
    }
  }

  void _onMouseMove(DOM.MouseEvent e) {
    if (!_dragging) {
      fire(MOUSEMOVE, e);
    }
  }

  NodeBase on(String event, Function handler, [String id]) {
    super.on(event, handler, id);
    if(getAttribute(LISTENING) == true) {
      if (!_registeredDOMEvents.contains(event)) {
        _registerDOMEvent(event, eventListeners[event]);
      }
    }
    return this;
  }

  void _handleAttrChange(String attr, oldValue, newValue) {
    if (_isStyle(attr)) {
      _setElementStyle(attr);
    } else {
      // apply attribute change to svg element
      var elementAttr = _mapToElementAttr(attr);
      if (elementAttr != null) {
        _setElementAttribute(elementAttr);
      }
    }
  }

  bool _isStyle(String attr) {
    return _getStyleNames().contains(attr);
  }

  String _mapToElementAttr(String attr) {
    if (_getElementAttributeNames().contains(attr)) {
      return attr;
    }
    return null;
  }

  void scale() {
    _elMatrix.a = transformMatrix.sx;
    _elMatrix.d = transformMatrix.sy;
    _setTransform();
  }

  void translate() {
    _elMatrix.e = transformMatrix.tx;
    _elMatrix.f = transformMatrix.ty;
    _setTransform();
  }

  void _setTransform() {
    try {
      SVG.GraphicsElement el = _element as SVG.GraphicsElement;
      SVG.Transform tr = el.transform.baseVal.createSvgTransformFromMatrix(_elMatrix);
      if (el.transform.baseVal.length == 0) {
        el.transform.baseVal.appendItem(tr);
      } else {
        el.transform.baseVal.replaceItem(tr, 0);
      }
    } catch(e) {}
  }

  String get _nodeName;

  bool get isDragging => _dragging;

  Position get absolutePosition => new Position();
}