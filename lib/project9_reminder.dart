import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class Reminder {
  final String id;
  String title;
  String description;
  DateTime dateTime;
  bool isActive;

  Reminder({
    required this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    this.isActive = true,
  });
}

class ReminderApp extends StatefulWidget {
  const ReminderApp({super.key});

  @override
  State<ReminderApp> createState() => _ReminderAppState();
}

class _ReminderAppState extends State<ReminderApp> {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();
  final List<Reminder> _reminders = [];

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _initializeTimezone();
  }

  Future<void> _initializeTimezone() async {
    tz.initializeTimeZones();
    // Đảm bảo múi giờ này chính xác với thiết bị của bạn
    // Hoặc bạn có thể dùng tz.local
    tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));
  }

  Future<void> _initializeNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions for iOS
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Request permissions for Android 13+
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Xử lý khi người dùng nhấn vào thông báo
    print('Notification tapped: ${response.payload}');
  }

  Future<void> _scheduleNotification(Reminder reminder) async {
    final scheduledDate = tz.TZDateTime.from(reminder.dateTime, tz.local);

    const androidDetails = AndroidNotificationDetails(
      'reminder_channel',
      'Reminders',
      channelDescription: 'Channel for reminder notifications',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails();

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.zonedSchedule(
      reminder.id.hashCode,
      reminder.title,
      reminder.description,
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,

      // *** LỖI ĐÃ ĐƯỢC SỬA TẠI ĐÂY ***
      // Hai dòng 'uiLocalNotificationDateInterpretation' và
      // 'UILocalNotificationDateInterpretation.absoluteTime'
      // đã bị xóa vì chúng không còn tồn tại trong các phiên bản mới của package.
      // Đối với lịch hẹn một lần (không lặp lại), không cần tham số thay thế.
    );
  }

  Future<void> _cancelNotification(String reminderId) async {
    await _notificationsPlugin.cancel(reminderId.hashCode);
  }

  void _addReminder() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(hours: 1));
    TimeOfDay selectedTime = TimeOfDay.fromDateTime(selectedDate);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Reminder'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.title),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 15),
                ListTile(
                  title: Text(
                    DateFormat('MMM dd, yyyy').format(selectedDate),
                    style: const TextStyle(fontSize: 16),
                  ),
                  leading: const Icon(Icons.calendar_today),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setDialogState(() {
                        selectedDate = DateTime(
                          date.year,
                          date.month,
                          date.day,
                          selectedTime.hour,
                          selectedTime.minute,
                        );
                      });
                    }
                  },
                ),
                const SizedBox(height: 10),
                ListTile(
                  title: Text(
                    selectedTime.format(context),
                    style: const TextStyle(fontSize: 16),
                  ),
                  leading: const Icon(Icons.access_time),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                    );
                    if (time != null) {
                      setDialogState(() {
                        selectedTime = time;
                        selectedDate = DateTime(
                          selectedDate.year,
                          selectedDate.month,
                          selectedDate.day,
                          time.hour,
                          time.minute,
                        );
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a title')),
                  );
                  return;
                }

                if (selectedDate.isBefore(DateTime.now())) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select a future time')),
                  );
                  return;
                }

                final reminder = Reminder(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: titleController.text,
                  description: descController.text,
                  dateTime: selectedDate,
                );

                await _scheduleNotification(reminder);

                setState(() {
                  _reminders.add(reminder);
                  _reminders.sort((a, b) => a.dateTime.compareTo(b.dateTime));
                });

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Reminder scheduled!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white, // Thêm màu chữ cho dễ đọc
              ),
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteReminder(Reminder reminder) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Reminder'),
        content: Text('Delete "${reminder.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _cancelNotification(reminder.id);
              setState(() {
                _reminders.remove(reminder);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Reminder deleted')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white, // Thêm màu chữ cho dễ đọc
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _toggleReminder(Reminder reminder) async {
    setState(() {
      reminder.isActive = !reminder.isActive;
    });

    if (reminder.isActive) {
      await _scheduleNotification(reminder);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reminder activated')),
      );
    } else {
      await _cancelNotification(reminder.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reminder deactivated')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminder App'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white, // Thêm màu chữ cho dễ đọc
      ),
      body: _reminders.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 100,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 20),
            Text(
              'No reminders yet',
              style: TextStyle(
                fontSize: 20,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Tap + to add a reminder',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      )
          : ListView.builder(
        itemCount: _reminders.length,
        itemBuilder: (context, index) {
          final reminder = _reminders[index];
          final isPast = reminder.dateTime.isBefore(DateTime.now());

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 3, // Thêm chút độ nổi
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), // Bo góc
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 16,
              ),
              leading: CircleAvatar(
                backgroundColor: reminder.isActive
                    ? (isPast ? Colors.grey.shade400 : Colors.deepOrange)
                    : Colors.grey,
                child: Icon(
                  isPast ? Icons.history : Icons.notifications,
                  color: Colors.white,
                ),
              ),
              title: Text(
                reminder.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  decoration: (isPast && !reminder.isActive)
                      ? TextDecoration.lineThrough
                      : null,
                  color: (isPast && !reminder.isActive)
                      ? Colors.grey
                      : Colors.black87,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (reminder.description.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        reminder.description,
                        style: TextStyle(
                          color: (isPast && !reminder.isActive)
                              ? Colors.grey
                              : Colors.black54,
                        ),
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('MMM dd, yyyy • hh:mm a')
                        .format(reminder.dateTime),
                    style: TextStyle(
                      color: (isPast && !reminder.isActive)
                          ? Colors.grey
                          : (reminder.isActive
                          ? Colors.deepOrange
                          : Colors.grey),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isPast)
                    Switch(
                      value: reminder.isActive,
                      onChanged: (_) => _toggleReminder(reminder),
                      activeColor: Colors.deepOrange,
                    ),
                  if (isPast) // Hiển thị nút xóa thay vì switch nếu đã qua
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteReminder(reminder),
                    ),
                ],
              ),
              onLongPress: () { // Thêm tính năng xóa bằng cách nhấn giữ
                if (!isPast) _deleteReminder(reminder);
              },
              isThreeLine: reminder.description.isNotEmpty,
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addReminder,
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white, // Thêm màu chữ cho dễ đọc
        child: const Icon(Icons.add),
      ),
    );
  }
}