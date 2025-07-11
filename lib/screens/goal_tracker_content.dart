import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import '../services/login_history_service.dart';
import '../services/auth_service.dart';

class GoalTrackerContent extends StatefulWidget {
  const GoalTrackerContent({super.key});

  @override
  State<GoalTrackerContent> createState() => _GoalTrackerContentState();
}

class _GoalTrackerContentState extends State<GoalTrackerContent> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  
  final LoginHistoryService _loginHistoryService = LoginHistoryService();
  final AuthService _authService = AuthService();
  
  Set<DateTime> _loginDays = {};
  Map<String, int> _loginStats = {
    'totalDays': 0,
    'thisWeek': 0,
    'streak': 0,
  };
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLoginHistory();
  }
  
  Future<void> _loadLoginHistory() async {
    final userId = _authService.currentUserId;
    if (userId == null) return;
    
    try {
      final loginDays = await _loginHistoryService.getLoginDays(userId);
      final loginStats = await _loginHistoryService.getLoginStats(userId);
      
      if (mounted) {
        setState(() {
          _loginDays = loginDays;
          _loginStats = loginStats;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Failed to load login history: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0A0A0A),
            Color(0xFF1A1A1A),
            Color(0xFF0F0F0F),
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text(
                  'Your Login History',
                  style: GoogleFonts.crimsonText(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Track your consistency and progress',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 30),
                
                // Statistics Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1A1A1A), Color(0xFF0F0F0F)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF4ECDC4).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatItem(
                        title: 'Total Days',
                        value: _isLoading ? '-' : '${_loginStats['totalDays']}',
                        color: const Color(0xFF4ECDC4),
                      ),
                      _StatItem(
                        title: 'This Week',
                        value: _isLoading ? '-' : '${_loginStats['thisWeek']}',
                        color: const Color(0xFF6BCF7F),
                      ),
                      _StatItem(
                        title: 'Streak',
                        value: _isLoading ? '-' : '${_loginStats['streak']}',
                        color: const Color(0xFFFF6B35),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Calendar
                _isLoading
                  ? Container(
                      height: 400,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1A1A1A), Color(0xFF0F0F0F)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF4ECDC4).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF4ECDC4),
                        ),
                      ),
                    )
                  : Container(
                      height: 400,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1A1A1A), Color(0xFF0F0F0F)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF4ECDC4).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                  child: TableCalendar<DateTime>(
                      firstDay: DateTime.utc(2024, 1, 1),
                      lastDay: DateTime.utc(2030, 12, 31),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                      calendarFormat: CalendarFormat.month,
                      eventLoader: (day) {
                        return _loginDays.where((loginDay) => 
                          isSameDay(loginDay, day)).toList();
                      },
                      startingDayOfWeek: StartingDayOfWeek.monday,
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                      },
                      onPageChanged: (focusedDay) {
                        _focusedDay = focusedDay;
                      },
                      calendarStyle: CalendarStyle(
                        outsideDaysVisible: false,
                        weekendTextStyle: const TextStyle(color: Colors.white70),
                        defaultTextStyle: const TextStyle(color: Colors.white),
                        todayTextStyle: const TextStyle(color: Colors.white),
                        selectedTextStyle: const TextStyle(color: Colors.white),
                        todayDecoration: BoxDecoration(
                          color: const Color(0xFF4ECDC4).withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: const BoxDecoration(
                          color: Color(0xFF4ECDC4),
                          shape: BoxShape.circle,
                        ),
                        markerDecoration: const BoxDecoration(
                          color: Color(0xFF6BCF7F),
                          shape: BoxShape.circle,
                        ),
                      ),
                      headerStyle: HeaderStyle(
                        titleTextStyle: GoogleFonts.crimsonText(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        formatButtonVisible: false,
                        leftChevronIcon: const Icon(
                          Icons.chevron_left,
                          color: Colors.white,
                        ),
                        rightChevronIcon: const Icon(
                          Icons.chevron_right,
                          color: Colors.white,
                        ),
                      ),
                      daysOfWeekStyle: const DaysOfWeekStyle(
                        weekdayStyle: TextStyle(color: Colors.white70),
                        weekendStyle: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

}

class _StatItem extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _StatItem({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.crimsonText(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 12,
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }
}