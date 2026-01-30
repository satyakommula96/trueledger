import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueledger/core/services/notification_service.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as fln;
import 'package:trueledger/core/providers/shared_prefs_provider.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final service = NotificationService(prefs);
  ref.onDispose(service.dispose);
  return service;
});

final pendingNotificationsProvider =
    FutureProvider.autoDispose<List<fln.PendingNotificationRequest>>(
        (ref) async {
  final service = ref.watch(notificationServiceProvider);

  // Re-run this provider whenever the service notifies a change
  final subscription = service.onNotificationsChanged.listen((_) {
    ref.invalidateSelf();
  });
  ref.onDispose(subscription.cancel);

  return await service.getPendingNotifications();
});

final pendingNotificationCountProvider = Provider.autoDispose<int>((ref) {
  return ref.watch(pendingNotificationsProvider).value?.length ?? 0;
});
