import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueledger/core/services/notification_service.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});
