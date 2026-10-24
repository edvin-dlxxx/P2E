import 'package:flutter/widgets.dart';

/// Owns only objects it creates; listener updates do not replace editing values.
class InputLease {
  InputLease(
    TextEditingController? controller,
    FocusNode? focus,
    VoidCallback onChange,
  ) : _externalController = controller,
      _externalFocus = focus,
      changed = onChange {
    this.controller = controller ?? TextEditingController();
    this.focus = focus ?? FocusNode();
    _listen();
  }
  late TextEditingController controller;
  late FocusNode focus;
  TextEditingController? _externalController;
  FocusNode? _externalFocus;
  final VoidCallback changed;
  void _listen() {
    controller.addListener(changed);
    focus.addListener(changed);
  }

  void update(TextEditingController? nextController, FocusNode? nextFocus) {
    if (nextController != _externalController) {
      final value = controller.value;
      controller.removeListener(changed);
      if (_externalController == null) controller.dispose();
      controller = nextController ?? TextEditingController.fromValue(value);
      _externalController = nextController;
      controller.addListener(changed);
    }
    if (nextFocus != _externalFocus) {
      focus.removeListener(changed);
      if (_externalFocus == null) focus.dispose();
      focus = nextFocus ?? FocusNode();
      _externalFocus = nextFocus;
      focus.addListener(changed);
    }
  }

  void dispose() {
    controller.removeListener(changed);
    focus.removeListener(changed);
    if (_externalController == null) controller.dispose();
    if (_externalFocus == null) focus.dispose();
  }
}
