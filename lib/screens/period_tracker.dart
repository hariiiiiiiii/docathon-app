import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PeriodTrackerScreen extends StatefulWidget {
  const PeriodTrackerScreen({Key? key}) : super(key: key);

  @override
  State<PeriodTrackerScreen> createState() => _PeriodTrackerScreenState();
}

class _PeriodTrackerScreenState extends State<PeriodTrackerScreen> {
  // Data State
  DateTime _lastPeriodStart = DateTime.now().subtract(const Duration(days: 28));
  int _cycleLength = 28;
  int _periodLength = 5;
  bool _isLoading = true;

  // Calendar State
  late PageController _pageController;
  final int _initialPage = 1000; // Starting index for "infinite" scroll
  DateTime _focusedMonth = DateTime.now();
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Initialize controller to the middle
    _pageController = PageController(initialPage: _initialPage);
    
    // Normalize selected date to remove time components (midnight)
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    
    _loadData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // --- Data Persistence ---

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      final lastPeriodMillis = prefs.getInt('lastPeriodStart');
      if (lastPeriodMillis != null) {
        _lastPeriodStart = DateTime.fromMillisecondsSinceEpoch(lastPeriodMillis);
      } else {
        // Default: 28 days ago if no data
        _lastPeriodStart = DateTime.now().subtract(const Duration(days: 28));
      }
      
      _cycleLength = prefs.getInt('cycleLength') ?? 28;
      _periodLength = prefs.getInt('periodLength') ?? 5;
      _isLoading = false;
    });
  }

  Future<void> _logPeriodStart() async {
    final prefs = await SharedPreferences.getInstance();
    
    setState(() {
      _lastPeriodStart = _selectedDate;
    });

    await prefs.setInt('lastPeriodStart', _selectedDate.millisecondsSinceEpoch);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Cycle started on ${_formatDate(_selectedDate)}", style: GoogleFonts.poppins(color: const Color(0xFF001219), fontWeight: FontWeight.bold)),
          backgroundColor: const Color(0xFF00E5FF), // Cyan Accent
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  // --- Logic Helpers ---

  DateTime get _nextPeriodStart => _lastPeriodStart.add(Duration(days: _cycleLength));
  
  int get _daysUntilNext {
    final now = DateTime.now();
    // Reset time components for accurate day difference
    final today = DateTime(now.year, now.month, now.day);
    final next = DateTime(_nextPeriodStart.year, _nextPeriodStart.month, _nextPeriodStart.day);
    
    final diff = next.difference(today).inDays;
    return diff; 
  }

  double get _cycleProgress {
    final now = DateTime.now();
    final totalDays = _cycleLength;
    final daysSinceStart = now.difference(_lastPeriodStart).inDays;
    
    if (daysSinceStart < 0) return 0.0;
    if (daysSinceStart > totalDays) return 1.0;
    return daysSinceStart / totalDays;
  }

  String _formatDate(DateTime date) {
    const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    return "${months[date.month - 1]} ${date.day}";
  }

  String _getMonthName(int monthIndex) {
    const months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
    return months[monthIndex - 1];
  }
  
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // --- Calendar Logic ---
  
  bool _isPeriodDay(DateTime date) {
    // Checks if the date falls within the *last confirmed* period window
    final diff = date.difference(_lastPeriodStart).inDays;
    return diff >= 0 && diff < _periodLength;
  }

  bool _isPredictedDay(DateTime date) {
    // Start calculating predictions from the first day of the NEXT cycle
    final firstPredictedStart = _lastPeriodStart.add(Duration(days: _cycleLength));

    // If the date is before the first predicted cycle, return false 
    // (This prevents overlap with the current period which is handled by _isPeriodDay)
    if (date.isBefore(firstPredictedStart)) return false;

    // Calculate days passed since the anchor point (last confirmed period)
    final daysSinceAnchor = date.difference(_lastPeriodStart).inDays;

    // Use modulo arithmetic to repeat prediction for future months indefinitely
    return (daysSinceAnchor % _cycleLength) < _periodLength;
  }

  void _onPageChanged(int index) {
    final now = DateTime.now();
    final monthOffset = index - _initialPage;
    setState(() {
      _focusedMonth = DateTime(now.year, now.month + monthOffset, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Enhanced Theme Colors (Teal/Blue Theme)
    const bgDark = Color(0xFF001219); // Deep dark teal/blue
    const cardSurface = Color(0xFF003545); // Dark teal surface
    const primaryAccent = Color(0xFF00E5FF); // Electric Cyan
    const secondaryAccent = Color(0xFF64FFDA); // Soft Teal
    
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: bgDark,
        body: Center(child: CircularProgressIndicator(color: primaryAccent)),
      );
    }

    final daysUntil = _daysUntilNext;
    final displayDays = daysUntil < 0 ? 0 : daysUntil;
    final statusText = daysUntil < 0 
        ? "Period is ${daysUntil.abs()} days late" 
        : "until next period";

    return Scaffold(
      backgroundColor: bgDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. App Header
              Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                   Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                   ),
                 ]
               ),

              const SizedBox(height: 40),

              // 2. Circular Dashboard
              Stack(
                alignment: Alignment.center,
                children: [
                  // Glow effect
                  Container(
                    width: 200, height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: primaryAccent.withOpacity(0.15), blurRadius: 40, spreadRadius: 10),
                      ]
                    ),
                  ),
                  SizedBox(
                    width: 220, height: 220,
                    child: CircularProgressIndicator(
                      value: _cycleProgress,
                      strokeWidth: 18,
                      backgroundColor: Colors.white.withOpacity(0.05),
                      valueColor: const AlwaysStoppedAnimation<Color>(primaryAccent),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.water_drop_rounded, color: primaryAccent, size: 32),
                      const SizedBox(height: 8),
                      Text(
                        "$displayDays", 
                        style: GoogleFonts.poppins(fontSize: 56, fontWeight: FontWeight.bold, color: Colors.white, height: 1)
                      ),
                      Text(
                        "Days Left", 
                        style: GoogleFonts.poppins(fontSize: 14, color: Colors.white54, letterSpacing: 1, fontWeight: FontWeight.w500)
                      ),
                    ],
                  )
                ]
              ),

              const SizedBox(height: 16),
              
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: daysUntil < 0 ? primaryAccent.withOpacity(0.2) : Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: daysUntil < 0 ? primaryAccent.withOpacity(0.5) : Colors.transparent)
                ),
                child: Text(
                  statusText, 
                  style: GoogleFonts.poppins(color: daysUntil < 0 ? primaryAccent : Colors.white70, fontSize: 13)
                ),
              ),

              const SizedBox(height: 40),

              // 3. Main Action Button (Dynamic Label)
              Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [primaryAccent, secondaryAccent]),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(color: primaryAccent.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))
                  ]
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _logPeriodStart,
                    borderRadius: BorderRadius.circular(30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.edit_calendar_rounded, color: Color(0xFF001219)), // Dark icon for contrast
                        const SizedBox(width: 12),
                        Text(
                          _isSameDay(_selectedDate, DateTime.now()) 
                              ? "Period Started Today" 
                              : "Log Period: ${_formatDate(_selectedDate)}",
                          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF001219)) // Dark text
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // 4. Calendar Card (Scrollable)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cardSurface,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10))
                  ]
                ),
                child: Column(
                  children: [
                    // Calendar Header with Navigation
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left, color: Colors.white54),
                          onPressed: () {
                            _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                          },
                        ),
                        Column(
                          children: [
                            Text(
                              _getMonthName(_focusedMonth.month), 
                              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)
                            ),
                            Text(
                              _focusedMonth.year.toString(), 
                              style: GoogleFonts.poppins(fontSize: 14, color: Colors.white38)
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right, color: Colors.white54),
                          onPressed: () {
                            _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // The Scrollable Grid
                    SizedBox(
                      height: 300, // Fixed height for calendar area
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: _onPageChanged,
                        itemBuilder: (context, index) {
                          // Calculate month for this page
                          final now = DateTime.now();
                          final monthOffset = index - _initialPage;
                          final pageMonth = DateTime(now.year, now.month + monthOffset, 1);
                          return _buildCalendarGrid(pageMonth, primaryAccent);
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Legend
                    Divider(color: Colors.white.withOpacity(0.05)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildLegendItem(primaryAccent.withOpacity(0.8), "Period"),
                        const SizedBox(width: 24),
                        _buildLegendItem(primaryAccent.withOpacity(0.2), "Predicted"),
                        const SizedBox(width: 24),
                        _buildLegendItem(Colors.transparent, "Selected", border: true),
                      ],
                    )
                  ],
                ),
              ),

              const SizedBox(height: 100), // Space for FAB
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label, {bool border = false}) {
    return Row(
      children: [
        Container(
          width: 8, height: 8,
          decoration: BoxDecoration(
            color: color, 
            shape: BoxShape.circle,
            border: border ? Border.all(color: Colors.white, width: 1) : null
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12)),
      ],
    );
  }

  Widget _buildCalendarGrid(DateTime monthDate, Color accentColor) {
    final daysInMonth = DateTime(monthDate.year, monthDate.month + 1, 0).day;
    final firstWeekday = DateTime(monthDate.year, monthDate.month, 1).weekday;
    final emptySlots = firstWeekday == 7 ? 0 : firstWeekday; 

    return Column(
      children: [
        // Weekday Headers
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: ["S","M","T","W","T","F","S"].map((day) => 
            SizedBox(
              width: 32, 
              child: Center(
                child: Text(day, style: GoogleFonts.poppins(color: Colors.white30, fontSize: 12, fontWeight: FontWeight.w600))
              )
            )
          ).toList(),
        ),
        const SizedBox(height: 16),
        
        // Days Grid
        Expanded(
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(), // Scroll is handled by PageView
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            itemCount: daysInMonth + emptySlots,
            itemBuilder: (context, index) {
              if (index < emptySlots) return const SizedBox();
              
              final dayNum = index - emptySlots + 1;
              final date = DateTime(monthDate.year, monthDate.month, dayNum);
              final isToday = _isSameDay(date, DateTime.now());
              final isSelected = _isSameDay(date, _selectedDate);
              
              final isPeriod = _isPeriodDay(date);
              final isPredicted = _isPredictedDay(date);

              Color? bgColor;
              Color textColor = Colors.white70;
              BoxBorder? border;

              if (isSelected) {
                bgColor = Colors.white;
                textColor = Colors.black;
              } else if (isPeriod) {
                bgColor = accentColor.withOpacity(0.8);
                textColor = Colors.black; // Dark text on period days for better contrast
              } else if (isPredicted) {
                bgColor = accentColor.withOpacity(0.15);
                textColor = accentColor;
              } else if (isToday) {
                bgColor = Colors.transparent;
                border = Border.all(color: Colors.white30, width: 1);
                textColor = Colors.white;
              }

              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedDate = date;
                  });
                },
                customBorder: const CircleBorder(),
                child: Container(
                  decoration: BoxDecoration(
                    color: bgColor,
                    shape: BoxShape.circle,
                    border: border
                  ),
                  child: Center(
                    child: Text(
                      "$dayNum",
                      style: GoogleFonts.poppins(
                        color: textColor,
                        fontSize: 13,
                        fontWeight: (isPeriod || isSelected) ? FontWeight.bold : FontWeight.normal
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}