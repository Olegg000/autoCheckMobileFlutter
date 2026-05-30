import 'dart:convert';

import 'package:flutter/foundation.dart';

class AppLogger {
  const AppLogger._();

  static void debug(String component, String event, [Object? details]) {
    _write('DEBUG', component, event, details);
  }

  static void info(String component, String event, [Object? details]) {
    _write('INFO', component, event, details);
  }

  static void error(String component, String event, [Object? details]) {
    _write('ERROR', component, event, details);
  }

  static void _write(
    String level,
    String component,
    String event,
    Object? details,
  ) {
    final suffix = _normalize(details);
    debugPrint('[$component]: $level $event - $suffix');
  }

  static String _normalize(Object? details) {
    if (details == null) return 'No details';
    if (details is Map || details is List) {
      try {
        return jsonEncode(details);
      } catch (_) {
        return details.toString();
      }
    }
    return details.toString();
  }
}
