import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:barber_gold/features/shared/models/notification_model.dart';
import 'package:barber_gold/features/shared/repositories/notification_repository.dart';

final notificationsListProvider = FutureProvider.autoDispose<List<NotificationModel>>((ref) async {
  final repository = ref.watch(notificationRepositoryProvider);
  return repository.getNotifications();
});

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsListProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('HISTORIAL', style: GoogleFonts.orbitron(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined, color: Colors.redAccent),
            onPressed: () => _confirmClear(context, ref),
          ),
        ],
      ),
      body: notificationsAsync.when(
        data: (list) {
          if (list.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined, size: 64, color: Colors.white10),
                  const SizedBox(height: 16),
                  Text('No tienes notificaciones', style: GoogleFonts.outfit(color: Colors.white24)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final item = list[index];
              return _NotificationTile(notification: item);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: Colors.redAccent)),
        error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.red))),
      ),
    );
  }

  void _confirmClear(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('¿Vaciar historial?', style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
          TextButton(
            onPressed: () async {
              await ref.read(notificationRepositoryProvider).clearAll();
              ref.invalidate(notificationsListProvider);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('VACIAR', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends ConsumerWidget {
  final NotificationModel notification;
  const _NotificationTile({required this.notification});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeStr = DateFormat('dd MMM, HH:mm').format(notification.timestamp);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: notification.isRead ? Colors.white.withOpacity(0.02) : Colors.redAccent.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: notification.isRead ? Colors.white.withOpacity(0.05) : Colors.redAccent.withOpacity(0.2),
        ),
      ),
      child: ListTile(
        onTap: () async {
          await ref.read(notificationRepositoryProvider).markAsRead(notification.id);
          ref.invalidate(notificationsListProvider);
        },
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: notification.isRead ? Colors.grey.withOpacity(0.1) : Colors.redAccent.withOpacity(0.1),
          child: Icon(
            notification.isRead ? Icons.notifications_none : Icons.notifications_active,
            color: notification.isRead ? Colors.grey : Colors.redAccent,
            size: 20,
          ),
        ),
        title: Text(
          notification.title,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
            fontSize: 15,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notification.body,
              style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Text(
              timeStr,
              style: GoogleFonts.outfit(color: Colors.white24, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
