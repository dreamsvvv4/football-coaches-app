import 'package:flutter/material.dart';

class TimeFormat {
  static String compactDate(DateTime dt) {
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    return '$day/$month';
  }

  static String hourMinute(BuildContext context, DateTime dt) {
    return TimeOfDay.fromDateTime(dt).format(context);
  }

  static String relativeDayLabel(DateTime date) {
    final now = DateTime.now();
    final diff = date.difference(now);
    if (diff.inDays == 0) return 'Hoy';
    if (diff.inDays == 1) return 'Mañana';
    if (diff.inDays < 7) return 'En ${diff.inDays} días';
    const months = ['Ene','Feb','Mar','Abr','May','Jun','Jul','Ago','Sep','Oct','Nov','Dic'];
    return '${date.day} ${months[date.month - 1]}';
  }

  static String weekdayShort(DateTime date) {
    const days = ['Lun','Mar','Mié','Jue','Vie','Sáb','Dom'];
    // Dart weekday: Monday=1..Sunday=7
    return days[date.weekday - 1];
  }

  static String monthName(DateTime date) {
    const months = [
      'Enero','Febrero','Marzo','Abril','Mayo','Junio',
      'Julio','Agosto','Septiembre','Octubre','Noviembre','Diciembre'
    ];
    return months[date.month - 1];
  }
}
