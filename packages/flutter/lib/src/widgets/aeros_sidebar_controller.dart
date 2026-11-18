import 'dart:async';

import 'package:flutter/foundation.dart';

/// Holds whether the sidebar is collapsed to the icon rail on wide windows
/// (from the `lg` breakpoint up), and remembers it.
///
/// Give one to `AerosScaffold.sidebarController` and the scaffold owns the
/// rail: its top bar button, Cmd/Ctrl+B and [toggle] all go through here.
///
/// The package has no storage of its own. Plug yours into [load] and [save]:
///
/// ```dart
/// final sidebar = AerosSidebarController(
///   load: () => prefs.getBool('sidebar.collapsed'),
///   save: (collapsed) => prefs.setBool('sidebar.collapsed', collapsed),
/// );
/// ```
///
/// Only the wide-window choice is stored. Between `md` and `lg` the sidebar
/// always starts as a rail, and below `md` it is a closed drawer.
class AerosSidebarController extends ChangeNotifier {
  AerosSidebarController({bool collapsed = false, this.load, this.save}) : _collapsed = collapsed {
    if (load != null) unawaited(restore());
  }

  /// Reads the remembered choice; null when nothing was saved.
  final FutureOr<bool?> Function()? load;

  /// Stores the choice whenever the user changes it.
  final FutureOr<void> Function(bool collapsed)? save;

  bool _collapsed;
  bool _changedByUser = false;
  bool _disposed = false;

  /// The sidebar is the icon rail (on a wide window).
  bool get collapsed => _collapsed;
  set collapsed(bool value) {
    if (value == _collapsed) return;
    _collapsed = value;
    _changedByUser = true;
    notifyListeners();
    final save = this.save;
    if (save != null) unawaited(Future<void>.sync(() => save(value)));
  }

  /// Collapses an expanded sidebar and expands a collapsed one.
  void toggle() => collapsed = !collapsed;

  /// Applies what [load] returns. Runs once on creation; a choice the user
  /// made in the meantime wins.
  Future<void> restore() async {
    final saved = await load?.call();
    if (_disposed || _changedByUser || saved == null || saved == _collapsed) return;
    _collapsed = saved;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
