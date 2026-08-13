String timeAgo(DateTime time, {DateTime? now}) {
  final current = now ?? DateTime.now();
  final diff = current.difference(time);
  if (diff.inSeconds < 60) return 'الآن';
  if (diff.inMinutes < 60) {
    return 'منذ ${diff.inMinutes} ${diff.inMinutes == 1 ? 'دقيقة' : 'دقيقة'}';
  }
  if (diff.inHours < 24) {
    return 'منذ ${diff.inHours} ${diff.inHours == 1 ? 'ساعة' : 'ساعة'}';
  }
  if (diff.inDays < 30) {
    return 'منذ ${diff.inDays} ${diff.inDays == 1 ? 'يوم' : 'أيام'}';
  }
  return '${time.year}/${time.month}/${time.day}';
}

String formatMoney(double value) {
  final isNegative = value < 0;
  final absolute = value.abs().round().toString();
  final buffer = StringBuffer();
  for (int i = 0; i < absolute.length; i++) {
    if (i > 0 && (absolute.length - i) % 3 == 0) buffer.write(',');
    buffer.write(absolute[i]);
  }
  return '${isNegative ? '-' : ''}${buffer.toString()} ج.م';
}

String formatLength(double meters) {
  if (meters >= 1) return '${meters.toStringAsFixed(2)} م';
  return '${(meters * 100).toStringAsFixed(0)} سم';
}
