import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/session_manager.dart';
import '../../data/api/api_service.dart';
import '../../data/models/schedule.dart';
import '../../main.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final _apiService = ApiService();
  int? _userId;
  DateTime _selectedDate = DateTime.now();
  List<Schedule> _schedules = [];
  bool _isLoading = true;

  // Thanh cuộn ngang cho ngày
  final ScrollController _scrollController = ScrollController();
  late List<DateTime> _datesList;

  // Set lưu trữ các ID tác vụ đã ghim cục bộ
  final Set<int> _pinnedTaskIds = {};

  @override
  void initState() {
    super.initState();
    _generateDatesList();
    _loadData();
    // Khởi tạo scroll đến ngày hiện tại sau khi build xong
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelectedDate());
  }

  // Tạo list 30 ngày (15 ngày trước, 15 ngày sau)
  void _generateDatesList() {
    final now = DateTime.now();
    _datesList = List.generate(31, (index) => now.subtract(Duration(days: 15 - index)));
  }

  // Cuộn thanh ngang đến ngày đang chọn
  void _scrollToSelectedDate() {
    int index = _datesList.indexWhere((d) =>
    d.year == _selectedDate.year &&
        d.month == _selectedDate.month &&
        d.day == _selectedDate.day);

    if (index != -1 && _scrollController.hasClients) {
      double position = index * 65.0 - (MediaQuery.of(context).size.width / 2) + 30;
      _scrollController.animateTo(
        position.clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _loadData() async {
    _userId = await SessionManager.getUserId();
    if (_userId != null) {
      _fetchSchedules();
    }
  }

  Future<void> _fetchSchedules() async {
    if (_userId == null) return;
    setState(() => _isLoading = true);
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final schedules = await _apiService.getSchedulesByDate(_userId!, dateStr);
      if (mounted) {
        setState(() {
          _schedules = schedules;
          _schedules.sort((a, b) => (a.startTime ?? '').compareTo(b.startTime ?? ''));
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('[Schedule] Fetch error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleSchedule(Schedule schedule) async {
    if (schedule.scheduleId == null) return;
    final newValue = !(schedule.completed ?? false);

    setState(() {
      final index = _schedules.indexWhere((s) => s.scheduleId == schedule.scheduleId);
      if (index != -1) {
        // KHẮC PHỤC LỖI COPYWITH BẰNG CONSTRUCTOR
        _schedules[index] = Schedule(
          scheduleId: schedule.scheduleId,
          userId: schedule.userId,
          date: schedule.date,
          title: schedule.title,
          notes: schedule.notes,
          startTime: schedule.startTime,
          eventType: schedule.eventType,
          completed: newValue,
        );
      }
    });

    try {
      await _apiService.toggleScheduleCompletion(schedule.scheduleId!, newValue);
    } catch (e) {
      setState(() {
        final index = _schedules.indexWhere((s) => s.scheduleId == schedule.scheduleId);
        if (index != -1) {
          _schedules[index] = Schedule(
            scheduleId: schedule.scheduleId,
            userId: schedule.userId,
            date: schedule.date,
            title: schedule.title,
            notes: schedule.notes,
            startTime: schedule.startTime,
            eventType: schedule.eventType,
            completed: !newValue,
          );
        }
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Lỗi khi cập nhật trạng thái.')));
      }
    }
  }

  // Mở DatePicker khi bấm vào tên tháng
  Future<void> _selectDateFromPicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      helpText: 'Chọn ngày xem lịch trình',
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        // Sinh lại list 30 ngày xung quanh ngày vừa chọn
        _datesList = List.generate(31, (index) => picked.subtract(Duration(days: 15 - index)));
      });
      _scrollToSelectedDate();
      _fetchSchedules();
    }
  }

  void _showAddScheduleDialog() {
    String title = '';
    String notes = '';
    TimeOfDay selectedTime = TimeOfDay.now();
    bool setReminder = true; // FIX 1: Bật mặc định tính năng nhắc nhở

    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (context, setDialogState) {
                return AlertDialog(
                  title: const Text('Thêm sự kiện mới', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          decoration: const InputDecoration(labelText: 'Tên sự kiện (VD: Tập gym, Uống thuốc)'),
                          onChanged: (val) => title = val,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          decoration: const InputDecoration(labelText: 'Ghi chú (Tùy chọn)'),
                          onChanged: (val) => notes = val,
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Giờ: ${selectedTime.format(context)}', style: const TextStyle(fontSize: 16)),
                            TextButton(
                              onPressed: () async {
                                final time = await showTimePicker(context: context, initialTime: selectedTime);
                                if (time != null) setDialogState(() => selectedTime = time);
                              },
                              child: const Text('Chọn giờ'),
                            )
                          ],
                        ),
                        // Checkbox nhắc nhở
                        CheckboxListTile(
                          title: const Text('Nhắc nhở tôi bằng chuông'),
                          value: setReminder,
                          onChanged: (bool? value) {
                            setDialogState(() => setReminder = value ?? false);
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                          activeColor: AppColors.blue600,
                        )
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Hủy', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (title.trim().isEmpty || _userId == null) return;
                        Navigator.pop(context); // Đóng Dialog ngay lập tức

                        final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
                        final hourStr = selectedTime.hour.toString().padLeft(2, '0');
                        final minuteStr = selectedTime.minute.toString().padLeft(2, '0');
                        final startTimeStr = '${dateStr}T$hourStr:$minuteStr:00';

                        final newSchedule = Schedule(
                          userId: _userId,
                          date: dateStr,
                          title: title,
                          notes: notes,
                          startTime: startTimeStr,
                          eventType: 'custom',
                          completed: false,
                        );

                        setState(() => _isLoading = true);
                        try {
                          // Lưu vào Database
                          final createdSchedule = await _apiService.createSchedule(newSchedule);
                          await _fetchSchedules();

                          // Đặt hẹn giờ nếu có tick
                          if (setReminder) {
                            int notifId = createdSchedule.scheduleId ?? DateTime.now().millisecond;
                            // Phải có lệnh await ở đây để đảm bảo bắt được lỗi
                            await _scheduleNotification(notifId, title, notes, _selectedDate, selectedTime);

                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Đã lưu & đặt báo thức thành công!'), backgroundColor: Colors.green),
                              );
                            }
                          }
                        } catch (e) {
                          debugPrint('Lỗi: $e');
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Có lỗi xảy ra: $e'), backgroundColor: Colors.red),
                            );
                          }
                        } finally {
                          if (mounted) setState(() => _isLoading = false);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blue600,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Lưu', style: TextStyle(color: AppColors.white)),
                    )
                  ],
                );
              }
          );
        }
    );
  }

  // Cập nhật lại logic chặn thời gian ở quá khứ
  Future<void> _scheduleNotification(int id, String title, String body, DateTime date, TimeOfDay time) async {
    try {
      final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
      tz.TZDateTime scheduledDate = tz.TZDateTime(
        tz.local,
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );

      // FIX 2: Bù trừ hao hụt thao tác tay. Nếu bạn đặt đúng giờ hiện tại mà lỡ lưu chậm
      // làm giờ bị trôi vào quá khứ, app sẽ tự cộng thêm 5 giây thay vì hủy thông báo.
      if (scheduledDate.isBefore(now)) {
        scheduledDate = now.add(const Duration(seconds: 5));
        debugPrint('Giờ hẹn bị trễ, đã tự động dời sang: $scheduledDate');
      }

      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'schedule_channel_v3', // Đổi tên để tránh cached settings trên Android
        'Lịch trình (Nhắc nhở)',
        channelDescription: 'Thông báo sự kiện do người dùng tự tạo',
        importance: Importance.max,
        priority: Priority.high,
      );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidDetails);

      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        'Đến giờ: $title',
        body.isNotEmpty ? body : 'Đã đến giờ thực hiện sự kiện của bạn!',
        scheduledDate,
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'user_schedule',
      );

      debugPrint('THÀNH CÔNG: Đã hẹn giờ báo lúc $scheduledDate');
    } catch (e) {
      debugPrint('LỖI KHI ĐẶT THÔNG BÁO: $e');
      throw Exception('Không thể đặt báo thức, vui lòng kiểm tra quyền hệ thống.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.indigo600, AppColors.blue600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text('Lịch trình của tôi', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: AppColors.white),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddScheduleDialog,
        backgroundColor: AppColors.indigo600,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
      body: Column(
        children: [
          _buildCalendarStrip(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildGroupedTaskList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarStrip() {
    return Container(
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: GestureDetector(
              onTap: _selectDateFromPicker,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    DateFormat('MMMM yyyy', 'vi').format(_selectedDate).toUpperCase(),
                    style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.calendar_today, size: 18, color: AppColors.blue600),
                ],
              ),
            ),
          ),
          SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: _datesList.map((date) {
                final isSelected = date.year == _selectedDate.year &&
                    date.month == _selectedDate.month &&
                    date.day == _selectedDate.day;

                final dayName = DateFormat('E', 'vi').format(date);

                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedDate = date);
                    _scrollToSelectedDate();
                    _fetchSchedules();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.blue600 : Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: isSelected ? [
                        // KHẮC PHỤC CẢNH BÁO withOpacity -> withValues
                        BoxShadow(color: AppColors.blue600.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))
                      ] : [],
                    ),
                    child: Column(
                      children: [
                        Text(
                          dayName,
                          style: TextStyle(
                            color: isSelected ? AppColors.white : AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${date.day}',
                          style: TextStyle(
                            color: isSelected ? AppColors.white : AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, {bool isExpanded = true, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color),
            ),
            const SizedBox(width: 8),
            Icon(isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: Theme.of(context).textTheme.bodyMedium?.color),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupedTaskList() {
    if (_schedules.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: AppColors.gray300),
            SizedBox(height: 16),
            Text('Chưa có sự kiện nào trong ngày.', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
          ],
        ),
      );
    }

    List<Schedule> pinnedTasks = [];
    List<Schedule> openTasks = [];
    List<Schedule> completedTasks = [];

    for (var task in _schedules) {
      if (_pinnedTaskIds.contains(task.scheduleId)) {
        pinnedTasks.add(task);
      } else if (task.completed == true) {
        completedTasks.add(task);
      } else {
        openTasks.add(task);
      }
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 80),
      children: [
        if (pinnedTasks.isNotEmpty) ...[
          _buildSectionHeader('Đã ghim (${pinnedTasks.length})'),
          ...pinnedTasks.map((t) => _buildSlidableTaskItem(t)),
        ],
        if (openTasks.isNotEmpty) ...[
          _buildSectionHeader('Chưa hoàn thành (${openTasks.length})'),
          ...openTasks.map((t) => _buildSlidableTaskItem(t)),
        ],
        if (completedTasks.isNotEmpty) ...[
          _buildSectionHeader('Đã hoàn thành (${completedTasks.length})'),
          ...completedTasks.map((t) => _buildSlidableTaskItem(t)),
        ],
      ],
    );
  }

  void _showEditScheduleDialog(Schedule schedule) {
    String title = schedule.title ?? '';
    String notes = schedule.notes ?? '';

    TimeOfDay selectedTime = TimeOfDay.now();
    if (schedule.startTime != null) {
      try {
        DateTime parsedTime = DateTime.parse(schedule.startTime!);
        selectedTime = TimeOfDay(hour: parsedTime.hour, minute: parsedTime.minute);
      } catch (_) {}
    }

    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (context, setDialogState) {
                return AlertDialog(
                  title: const Text('Sửa sự kiện', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: TextEditingController(text: title),
                          decoration: const InputDecoration(labelText: 'Tên sự kiện'),
                          onChanged: (val) => title = val,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: TextEditingController(text: notes),
                          decoration: const InputDecoration(labelText: 'Ghi chú (Tùy chọn)'),
                          onChanged: (val) => notes = val,
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Giờ: ${selectedTime.format(context)}', style: const TextStyle(fontSize: 16)),
                            TextButton(
                              onPressed: () async {
                                final time = await showTimePicker(context: context, initialTime: selectedTime);
                                if (time != null) setDialogState(() => selectedTime = time);
                              },
                              child: const Text('Chọn giờ'),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Hủy', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (title.trim().isEmpty || schedule.scheduleId == null) return;
                        Navigator.pop(context);

                        final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
                        final hourStr = selectedTime.hour.toString().padLeft(2, '0');
                        final minuteStr = selectedTime.minute.toString().padLeft(2, '0');
                        final startTimeStr = '${dateStr}T$hourStr:$minuteStr:00';

                        // KHẮC PHỤC LỖI COPYWITH BẰNG CONSTRUCTOR
                        final updatedSchedule = Schedule(
                          scheduleId: schedule.scheduleId,
                          userId: schedule.userId,
                          date: schedule.date, // Giữ nguyên ngày cũ
                          title: title,
                          notes: notes,
                          startTime: startTimeStr,
                          eventType: schedule.eventType,
                          completed: schedule.completed,
                        );

                        setState(() => _isLoading = true);
                        try {
                          await _apiService.updateSchedule(schedule.scheduleId!, updatedSchedule);
                          _fetchSchedules(); // Reload lại danh sách sau khi sửa
                        } catch (e) {
                          debugPrint('Lỗi cập nhật: $e');
                          setState(() => _isLoading = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Lỗi khi cập nhật sự kiện.')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blue600,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Lưu', style: TextStyle(color: AppColors.white)),
                    )
                  ],
                );
              }
          );
        }
    );
  }

  Widget _buildSlidableTaskItem(Schedule schedule) {
    final isDone = schedule.completed ?? false;
    final isPinned = _pinnedTaskIds.contains(schedule.scheduleId);

    Color eventColor = AppColors.blue600;
    if (schedule.eventType == 'meal') eventColor = AppColors.orange600;
    if (schedule.eventType == 'water_reminder') eventColor = Colors.lightBlue;
    if (schedule.eventType == 'exercise') eventColor = Colors.green;
    if (schedule.eventType == 'sleep') eventColor = Colors.deepPurple;

    return Slidable(
      key: ValueKey(schedule.scheduleId),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) {
              setState(() {
                if (isPinned) {
                  _pinnedTaskIds.remove(schedule.scheduleId);
                } else {
                  if (schedule.scheduleId != null) {
                    _pinnedTaskIds.add(schedule.scheduleId!);
                  }
                }
              });
            },
            backgroundColor: AppColors.orange600,
            foregroundColor: Colors.white,
            icon: isPinned ? Icons.push_pin_outlined : Icons.push_pin,
            label: isPinned ? 'Bỏ ghim' : 'Ghim',
          ),
          SlidableAction(
            onPressed: (context) => _showEditScheduleDialog(schedule),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Sửa',
          ),
          SlidableAction(
            onPressed: (context) async {
              if (schedule.scheduleId != null) {
                try {
                  setState(() {
                    _schedules.removeWhere((s) => s.scheduleId == schedule.scheduleId);
                    _pinnedTaskIds.remove(schedule.scheduleId);
                  });
                  await _apiService.deleteSchedule(schedule.scheduleId!);
                  await flutterLocalNotificationsPlugin.cancel(schedule.scheduleId!);
                } catch (e) {
                  _fetchSchedules();
                }
              }
            },
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Xóa',
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          // KHẮC PHỤC CẢNH BÁO withOpacity -> withValues
          side: BorderSide(color: isDone ? AppColors.gray200 : eventColor.withValues(alpha: 0.3), width: 1),
        ),
        color: isDone ? Theme.of(context).scaffoldBackgroundColor : Theme.of(context).cardColor,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: InkWell(
            onTap: () => _toggleSchedule(schedule),
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: isDone ? AppColors.gray400 : eventColor, width: 2),
                color: isDone ? AppColors.gray400 : Colors.transparent,
              ),
              child: isDone ? const Icon(Icons.check, size: 16, color: AppColors.white) : null,
            ),
          ),
          title: Text(
            schedule.title ?? 'Sự kiện',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isDone ? AppColors.textSecondary : AppColors.textPrimary,
              decoration: isDone ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: isDone ? AppColors.gray400 : eventColor),
                  const SizedBox(width: 4),
                  Text(
                    schedule.displayTime,
                    style: TextStyle(color: isDone ? AppColors.gray400 : eventColor, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              if (schedule.notes != null && schedule.notes!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(schedule.notes!, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 13)),
              ]
            ],
          ),
          trailing: isDone
              ? null
          // KHẮC PHỤC CẢNH BÁO withOpacity -> withValues
              : Icon(Icons.notifications_active_outlined, color: eventColor.withValues(alpha: 0.5)),
        ),
      ),
    );
  }
}