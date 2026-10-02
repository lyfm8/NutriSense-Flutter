import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/session_manager.dart';

import '../../data/api/api_service.dart';
import '../../data/models/schedule.dart';
import 'package:intl/intl.dart';

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

  @override
  void initState() {
    super.initState();
    _loadData();
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
          // Sắp xếp theo thời gian
          _schedules.sort((a, b) => (a.startTime ?? '').compareTo(b.startTime ?? ''));
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('[Schedule] Fetch error: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _toggleSchedule(Schedule schedule) async {
    if (schedule.scheduleId == null) return;
    final newValue = !(schedule.completed ?? false);
    
    // Optimistic update
    setState(() {
      final index = _schedules.indexWhere((s) => s.scheduleId == schedule.scheduleId);
      if (index != -1) {
        _schedules[index] = schedule.copyWith(completed: newValue);
      }
    });

    try {
      await _apiService.toggleScheduleCompletion(schedule.scheduleId!, newValue);
    } catch (e) {
      // Revert if error
      setState(() {
        final index = _schedules.indexWhere((s) => s.scheduleId == schedule.scheduleId);
        if (index != -1) {
          _schedules[index] = schedule.copyWith(completed: !newValue);
        }
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lỗi khi cập nhật trạng thái.')));
      }
    }
  }

  void _showAddScheduleDialog() {
    String title = '';
    String notes = '';
    TimeOfDay selectedTime = TimeOfDay.now();

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
                            if (time != null) {
                              setDialogState(() => selectedTime = time);
                            }
                          },
                          child: const Text('Chọn giờ'),
                        )
                      ],
                    )
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hủy', style: TextStyle(color: AppColors.textSecondary)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (title.trim().isEmpty || _userId == null) return;
                    Navigator.pop(context);
                    
                    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
                    // Format time: yyyy-MM-ddTHH:mm:00
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
                      await _apiService.createSchedule(newSchedule);
                      _fetchSchedules(); // reload
                    } catch (e) {
                      debugPrint('[Schedule] Create error: $e');
                      setState(() => _isLoading = false);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blue50,
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
                : _buildScheduleList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarStrip() {
    final now = DateTime.now();
    // Tạo list 14 ngày: từ 7 ngày trước đến 7 ngày sau
    final dates = List.generate(15, (index) => now.subtract(Duration(days: 7 - index)));

    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              DateFormat('MMMM yyyy', 'vi').format(_selectedDate).toUpperCase(),
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: dates.map((date) {
                final isSelected = date.year == _selectedDate.year &&
                                   date.month == _selectedDate.month &&
                                   date.day == _selectedDate.day;
                
                final dayName = DateFormat('E', 'vi').format(date);

                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedDate = date);
                    _fetchSchedules();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.blue600 : AppColors.gray50,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: isSelected ? [
                        BoxShadow(color: AppColors.blue600.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))
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

  Widget _buildScheduleList() {
    if (_schedules.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: AppColors.gray300),
            SizedBox(height: 16),
            Text('Chưa có sự kiện nào trong ngày.', style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _schedules.length,
      itemBuilder: (context, index) {
        final schedule = _schedules[index];
        final isDone = schedule.completed ?? false;
        
        // Define colors based on event type
        Color eventColor = AppColors.blue600;
        if (schedule.eventType == 'meal') eventColor = AppColors.orange600;
        if (schedule.eventType == 'water_reminder') eventColor = Colors.lightBlue;
        if (schedule.eventType == 'exercise') eventColor = Colors.green;
        if (schedule.eventType == 'sleep') eventColor = Colors.deepPurple;

        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: isDone ? AppColors.gray200 : eventColor.withOpacity(0.3), width: 1),
          ),
          color: isDone ? AppColors.gray50 : AppColors.white,
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
                  Text(schedule.notes!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                ]
              ],
            ),
            trailing: isDone 
              ? null 
              : Icon(Icons.notifications_active_outlined, color: eventColor.withOpacity(0.5)),
          ),
        );
      },
    );
  }
}
