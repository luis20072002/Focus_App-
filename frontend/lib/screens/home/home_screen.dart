import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/task_provider.dart';
import 'widgets/task_card.dart';

// ════════════════════════════════════════════════════════════════════════════
// UBICACIÓN: lib/screens/home/home_screen.dart
// REEMPLAZA: el home_screen.dart original
// CAMBIOS:
//   - Se eliminó la importación de CalendarScreen (causaba pantalla en blanco
//     por ruta incorrecta y Scaffold anidado en IndexedStack)
//   - CalendarScreen ahora se embebe como widget puro (sin Scaffold propio)
//     usando _EmbeddedCalendar definido al final de este archivo
//   - Se usan colores de AppColors sin hardcodear
// ════════════════════════════════════════════════════════════════════════════

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _showCompleted = true;
  late TabController _rankingTabController;

  // Datos mock de ranking
  final List<Map<String, dynamic>> _globalRanking = [
    {
      'name': 'María García',
      'foints': 1240,
      'initials': 'MG',
      'color': 0xFFEA88B9,
    },
    {
      'name': 'Carlos López',
      'foints': 1180,
      'initials': 'CL',
      'color': 0xFF5A4EDB,
    },
    {
      'name': 'Ana Martínez',
      'foints': 1050,
      'initials': 'AM',
      'color': 0xFFBCBBF2,
    },
    {
      'name': 'Juan Pérez',
      'foints': 980,
      'initials': 'JP',
      'color': 0xFFE4AAA2,
    },
    {
      'name': 'Sofía Ruiz',
      'foints': 920,
      'initials': 'SR',
      'color': 0xFF0F2C98,
    },
  ];

  @override
  void initState() {
    super.initState();
    _rankingTabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().loadTodayTasks();
    });
  }

  @override
  void dispose() {
    _rankingTabController.dispose();
    super.dispose();
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Buenos días';
    if (hour < 18) return 'Buenas tardes';
    return 'Buenas noches';
  }

  String _todayFormatted() {
    const meses = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];
    const dias = [
      'lunes',
      'martes',
      'miércoles',
      'jueves',
      'viernes',
      'sábado',
      'domingo',
    ];
    final now = DateTime.now();
    return '${dias[now.weekday - 1]}, ${now.day} de ${meses[now.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final taskProv = context.watch<TaskProvider>();
    final user = auth.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            // ── Tab 0: Inicio ─────────────────────────────────────────────
            _buildHomeTab(user, taskProv),

            // ── Tab 1: Calendario (widget embebido, sin Scaffold propio) ──
            // CORRECCIÓN CLAVE: Se usa _EmbeddedCalendar en lugar de importar
            // CalendarScreen con su Scaffold completo, ya que un Scaffold
            // dentro de IndexedStack causa que el body colapse a altura 0.
            const _EmbeddedCalendar(),

            // ── Tab 2: Perfil ─────────────────────────────────────────────
            _ProfileTab(
              onLogout: () async {
                await context.read<AuthProvider>().logout();
                if (context.mounted) context.go('/login');
              },
            ),
          ],
        ),
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () => context.go('/create-task'),
              backgroundColor: AppColors.blueberry,
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: const Text(
                'Nueva tarea',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          : null,
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ── Tab Inicio ─────────────────────────────────────────────────────────────

  Widget _buildHomeTab(dynamic user, TaskProvider taskProv) {
    final allTasks = taskProv.todayTasks;
    final pendingTasks = allTasks.where((t) => !t.isDone).toList();
    final doneTasks = allTasks.where((t) => t.isDone).toList();
    final visibleTasks = _showCompleted ? allTasks : pendingTasks;
    final completedCount = doneTasks.length;
    final totalCount = allTasks.length;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;

    return RefreshIndicator(
      color: AppColors.blueberry,
      backgroundColor: AppColors.surface,
      onRefresh: () => taskProv.loadTodayTasks(),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _greeting(),
                            style: const TextStyle(
                              color: AppColors.grisTexto,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user?.name ?? '',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            _todayFormatted(),
                            style: const TextStyle(
                              color: AppColors.grisTexto,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _selectedIndex = 2),
                        child: Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: AppColors.blueberry,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.blueberry.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              user?.name?.isNotEmpty == true
                                  ? user!.name[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Foints banner
                  _FointsBanner(user: user),

                  const SizedBox(height: 20),

                  // Progreso del día
                  _DayProgressCard(
                    completed: completedCount,
                    total: totalCount,
                    progress: progress,
                  ),

                  const SizedBox(height: 24),

                  // Ranking
                  _RankingSection(
                    tabController: _rankingTabController,
                    globalRanking: _globalRanking,
                    currentUserFoints: user?.fointsSeason ?? 0,
                  ),

                  const SizedBox(height: 24),

                  // Título tareas
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tareas de hoy',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            '$completedCount de $totalCount completadas',
                            style: const TextStyle(
                              color: AppColors.grisTexto,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () =>
                            setState(() => _showCompleted = !_showCompleted),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _showCompleted
                                ? AppColors.blueberry.withOpacity(0.1)
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _showCompleted
                                  ? AppColors.blueberry.withOpacity(0.3)
                                  : AppColors.grisTexto.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _showCompleted
                                    ? Icons.visibility_rounded
                                    : Icons.visibility_off_rounded,
                                size: 14,
                                color: _showCompleted
                                    ? AppColors.blueberry
                                    : AppColors.grisTexto,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _showCompleted ? 'Todas' : 'Pendientes',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _showCompleted
                                      ? AppColors.blueberry
                                      : AppColors.grisTexto,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // Lista de tareas
          if (taskProv.loading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: AppColors.blueberry),
              ),
            )
          else if (visibleTasks.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.blueberry.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle_outline,
                        color: AppColors.blueberry,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _showCompleted
                          ? '¡Sin tareas para hoy!'
                          : '¡Todo completado!',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _showCompleted
                          ? 'Agrega una tarea para comenzar'
                          : 'Has completado todas tus tareas del día',
                      style: const TextStyle(
                        color: AppColors.grisTexto,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (_showCompleted) ...[
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => context.go('/create-task'),
                        icon: const Icon(Icons.add),
                        label: const Text('Nueva tarea'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blueberry,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(180, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => TaskCard(task: visibleTasks[i]),
                  childCount: visibleTasks.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Bottom Nav ─────────────────────────────────────────────────────────────

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                label: 'Inicio',
                selected: _selectedIndex == 0,
                onTap: () => setState(() => _selectedIndex = 0),
              ),
              _NavItem(
                icon: Icons.calendar_month_rounded,
                label: 'Calendario',
                selected: _selectedIndex == 1,
                onTap: () => setState(() => _selectedIndex = 1),
              ),
              _NavItem(
                icon: Icons.person_outline_rounded,
                label: 'Perfil',
                selected: _selectedIndex == 2,
                onTap: () => setState(() => _selectedIndex = 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// _EmbeddedCalendar
// Widget de calendario SIN Scaffold propio — diseñado para vivir dentro
// del IndexedStack de HomeScreen. Replica la funcionalidad de CalendarScreen
// pero sin el Scaffold que causaba la pantalla en blanco.
// ════════════════════════════════════════════════════════════════════════════

class _EmbeddedCalendar extends StatefulWidget {
  const _EmbeddedCalendar();

  @override
  State<_EmbeddedCalendar> createState() => _EmbeddedCalendarState();
}

class _EmbeddedCalendarState extends State<_EmbeddedCalendar>
    with SingleTickerProviderStateMixin {
  DateTime _focusedMonth = DateTime.now();
  DateTime? _selectedDay;
  late TabController _tabController;

  final Set<int> _completedDays = {2, 3, 5, 8, 9, 10};
  final Set<int> _failedDays = {4, 6, 11};
  final Set<int> _scheduledDays = {18, 20, 21, 22, 25, 27};

  final Map<int, List<Map<String, dynamic>>> _tasksByDay = {
    5: [
      {
        'name': 'Ir al gimnasio',
        'time': '07:00',
        'done': true,
        'foints': true,
        'color': 0xFF5A4EDB,
      },
      {
        'name': 'Leer 30 minutos',
        'time': '21:00',
        'done': true,
        'foints': false,
        'color': 0xFFEA88B9,
      },
    ],
    8: [
      {
        'name': 'Meditación matutina',
        'time': '06:30',
        'done': true,
        'foints': true,
        'color': 0xFF5A4EDB,
      },
      {
        'name': 'Estudiar inglés',
        'time': '19:00',
        'done': true,
        'foints': true,
        'color': 0xFFBCBBF2,
      },
    ],
    18: [
      {
        'name': 'Correr 5km',
        'time': '07:00',
        'done': false,
        'foints': true,
        'color': 0xFF5A4EDB,
      },
      {
        'name': 'Llamar a mamá',
        'time': '18:00',
        'done': false,
        'foints': false,
        'color': 0xFFEA88B9,
      },
      {
        'name': 'Beber 2L de agua',
        'time': '12:00',
        'done': false,
        'foints': true,
        'color': 0xFFBCBBF2,
      },
    ],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedDay = DateTime.now();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<DateTime> _daysInMonth(DateTime month) {
    final lastDay = DateTime(month.year, month.month + 1, 0);
    return List.generate(
      lastDay.day,
      (i) => DateTime(month.year, month.month, i + 1),
    );
  }

  int _firstWeekdayOfMonth(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    return (firstDay.weekday - 1) % 7;
  }

  String _monthName(DateTime date) {
    const months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    return months[date.month - 1];
  }

  @override
  Widget build(BuildContext context) {
    // Sin Scaffold — devuelve directamente el contenido
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Calendario',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.lightBlue.withOpacity(0.3),
                  ),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: AppColors.blueberry,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.grisTexto,
                  labelStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                  tabs: const [
                    Tab(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.calendar_view_month_rounded, size: 16),
                            SizedBox(width: 4),
                            Text('Mes'),
                          ],
                        ),
                      ),
                    ),
                    Tab(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.view_agenda_rounded, size: 16),
                            SizedBox(width: 4),
                            Text('Agenda'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Leyenda
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              _LegendDot(color: AppColors.blueberry, label: 'Completado'),
              const SizedBox(width: 16),
              _LegendDot(color: AppColors.error, label: 'Sin completar'),
              const SizedBox(width: 16),
              _LegendDot(color: AppColors.grisTexto, label: 'Programado'),
            ],
          ),
        ),

        const SizedBox(height: 12),

        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [_buildMonthView(), _buildAgendaView()],
          ),
        ),
      ],
    );
  }

  Widget _buildMonthView() {
    final days = _daysInMonth(_focusedMonth);
    final offset = _firstWeekdayOfMonth(_focusedMonth);
    final today = DateTime.now();
    final isCurrentMonth =
        _focusedMonth.year == today.year && _focusedMonth.month == today.month;

    return Column(
      children: [
        // Navegación mes
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => setState(() {
                  _focusedMonth = DateTime(
                    _focusedMonth.year,
                    _focusedMonth.month - 1,
                    1,
                  );
                }),
                icon: const Icon(Icons.chevron_left_rounded),
                color: AppColors.textPrimary,
              ),
              Text(
                '${_monthName(_focusedMonth)} ${_focusedMonth.year}',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              IconButton(
                onPressed: () => setState(() {
                  _focusedMonth = DateTime(
                    _focusedMonth.year,
                    _focusedMonth.month + 1,
                    1,
                  );
                }),
                icon: const Icon(Icons.chevron_right_rounded),
                color: AppColors.textPrimary,
              ),
            ],
          ),
        ),

        // Días de la semana
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: ['L', 'M', 'X', 'J', 'V', 'S', 'D']
                .map(
                  (d) => Expanded(
                    child: Center(
                      child: Text(
                        d,
                        style: const TextStyle(
                          color: AppColors.grisTexto,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),

        const SizedBox(height: 8),

        // Grid de días
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
            ),
            itemCount: days.length + offset,
            itemBuilder: (_, index) {
              if (index < offset) return const SizedBox();
              final day = days[index - offset];
              final dayNum = day.day;
              final isToday = isCurrentMonth && dayNum == today.day;
              final isSelected =
                  _selectedDay != null &&
                  _selectedDay!.day == dayNum &&
                  _selectedDay!.month == _focusedMonth.month &&
                  _selectedDay!.year == _focusedMonth.year;
              final isCompleted = _completedDays.contains(dayNum);
              final isFailed = _failedDays.contains(dayNum);
              final isScheduled = _scheduledDays.contains(dayNum);

              Color? dotColor;
              if (isCompleted) dotColor = AppColors.blueberry;
              if (isFailed) dotColor = AppColors.error;
              if (isScheduled) dotColor = AppColors.grisTexto;

              return GestureDetector(
                onTap: () => setState(() => _selectedDay = day),
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.blueberry
                        : isToday
                        ? AppColors.blueberry.withOpacity(0.12)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$dayNum',
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : isToday
                              ? AppColors.blueberry
                              : AppColors.textPrimary,
                          fontWeight: (isToday || isSelected)
                              ? FontWeight.w800
                              : FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                      if (dotColor != null)
                        Container(
                          width: 4,
                          height: 4,
                          margin: const EdgeInsets.only(top: 2),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white70 : dotColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 16),

        // Panel tareas del día seleccionado
        if (_selectedDay != null)
          Expanded(
            child: _DayTasksPanel(
              day: _selectedDay!,
              tasks: _tasksByDay[_selectedDay!.day] ?? [],
            ),
          ),
      ],
    );
  }

  Widget _buildAgendaView() {
    // Reúne todos los días con tareas para mostrarlos en lista
    final allEntries = _tasksByDay.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    if (allEntries.isEmpty) {
      return const Center(
        child: Text(
          'Sin tareas programadas',
          style: TextStyle(color: AppColors.grisTexto),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
      itemCount: allEntries.length,
      itemBuilder: (_, i) {
        final entry = allEntries[i];
        final dayNum = entry.key;
        final tasks = entry.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.blueberry,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        '$dayNum',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${_monthName(_focusedMonth)} ${_focusedMonth.year}',
                    style: const TextStyle(
                      color: AppColors.grisTexto,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            ...tasks.map((t) => _AgendaTaskTile(task: t)),
          ],
        );
      },
    );
  }
}

// ── Day Tasks Panel ───────────────────────────────────────────────────────────

class _DayTasksPanel extends StatelessWidget {
  final DateTime day;
  final List<Map<String, dynamic>> tasks;

  const _DayTasksPanel({required this.day, required this.tasks});

  String _dayLabel(DateTime d) {
    const meses = [
      'ene',
      'feb',
      'mar',
      'abr',
      'may',
      'jun',
      'jul',
      'ago',
      'sep',
      'oct',
      'nov',
      'dic',
    ];
    return '${d.day} ${meses[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        border: Border.all(color: AppColors.lightBlue.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(top: 10, bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.lightBlue.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _dayLabel(day),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.blueberry.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${tasks.length} tarea${tasks.length == 1 ? '' : 's'}',
                    style: const TextStyle(
                      color: AppColors.blueberry,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (tasks.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'No hay tareas para este día',
                style: TextStyle(color: AppColors.grisTexto, fontSize: 14),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                itemCount: tasks.length,
                itemBuilder: (_, i) => _DayTaskTile(task: tasks[i]),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Day Task Tile ─────────────────────────────────────────────────────────────

class _DayTaskTile extends StatelessWidget {
  final Map<String, dynamic> task;
  const _DayTaskTile({required this.task});

  @override
  Widget build(BuildContext context) {
    final done = task['done'] as bool;
    final color = Color(task['color'] as int);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: done ? color.withOpacity(0.05) : AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: done
              ? color.withOpacity(0.2)
              : AppColors.lightBlue.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 40,
            decoration: BoxDecoration(
              color: done ? color : AppColors.grisTexto.withOpacity(0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task['name'] as String,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    decoration: done ? TextDecoration.lineThrough : null,
                    decorationColor: AppColors.grisTexto,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(
                      Icons.schedule,
                      size: 11,
                      color: AppColors.grisTexto,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      task['time'] as String,
                      style: const TextStyle(
                        color: AppColors.grisTexto,
                        fontSize: 11,
                      ),
                    ),
                    if (task['foints'] == true) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.blueberry.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          '⚡ Foints',
                          style: TextStyle(
                            color: AppColors.blueberry,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Icon(
            done
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            color: done ? color : AppColors.grisTexto.withOpacity(0.4),
            size: 22,
          ),
        ],
      ),
    );
  }
}

// ── Agenda Task Tile ──────────────────────────────────────────────────────────

class _AgendaTaskTile extends StatelessWidget {
  final Map<String, dynamic> task;
  const _AgendaTaskTile({required this.task});

  @override
  Widget build(BuildContext context) {
    final color = Color(task['color'] as int);
    final done = task['done'] as bool;

    return Container(
      margin: const EdgeInsets.only(left: 0, bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 34,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task['name'] as String,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    decoration: done ? TextDecoration.lineThrough : null,
                  ),
                ),
                Text(
                  task['time'] as String,
                  style: const TextStyle(
                    color: AppColors.grisTexto,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          if (task['foints'] == true)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.blueberry.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text('⚡', style: TextStyle(fontSize: 12)),
            ),
        ],
      ),
    );
  }
}

// ── Legend Dot ────────────────────────────────────────────────────────────────

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(color: AppColors.grisTexto, fontSize: 11),
        ),
      ],
    );
  }
}

// ── Foints Banner ─────────────────────────────────────────────────────────────

class _FointsBanner extends StatelessWidget {
  final dynamic user;
  const _FointsBanner({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.blueberry, AppColors.midnight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.blueberry.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Foints esta temporada',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${user?.fointsSeason ?? 0}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Totales',
                style: TextStyle(color: Colors.white60, fontSize: 11),
              ),
              const SizedBox(height: 2),
              Text(
                '${user?.fointsTotal ?? 0}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.emoji_events_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Ver ranking',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Day Progress Card ─────────────────────────────────────────────────────────

class _DayProgressCard extends StatelessWidget {
  final int completed;
  final int total;
  final double progress;

  const _DayProgressCard({
    required this.completed,
    required this.total,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightBlue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Progreso del día',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              Text(
                '$completed / $total tareas',
                style: const TextStyle(
                  color: AppColors.grisTexto,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.lightBlue.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.blueberry,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            progress == 1.0
                ? '🎉 ¡Completaste todas tus tareas!'
                : total == 0
                ? 'Sin tareas programadas'
                : '${(progress * 100).toInt()}% completado',
            style: TextStyle(
              color: progress == 1.0
                  ? AppColors.blueberry
                  : AppColors.grisTexto,
              fontSize: 12,
              fontWeight: progress == 1.0 ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Ranking Section ───────────────────────────────────────────────────────────

class _RankingSection extends StatelessWidget {
  final TabController tabController;
  final List<Map<String, dynamic>> globalRanking;
  final int currentUserFoints;

  const _RankingSection({
    required this.tabController,
    required this.globalRanking,
    required this.currentUserFoints,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.lightBlue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Ranking',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TabBar(
                    controller: tabController,
                    indicator: BoxDecoration(
                      color: AppColors.blueberry,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelColor: Colors.white,
                    unselectedLabelColor: AppColors.grisTexto,
                    labelStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                    tabs: const [
                      Tab(text: 'Global'),
                      Tab(text: 'Amigos'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 260,
            child: TabBarView(
              controller: tabController,
              children: [
                _RankingList(
                  items: globalRanking,
                  currentUserFoints: currentUserFoints,
                ),
                _RankingList(
                  items: globalRanking.take(3).toList(),
                  currentUserFoints: currentUserFoints,
                  isFriends: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RankingList extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final int currentUserFoints;
  final bool isFriends;

  const _RankingList({
    required this.items,
    required this.currentUserFoints,
    this.isFriends = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isFriends && items.isEmpty) {
      return const Center(
        child: Text(
          'Aún no sigues a nadie',
          style: TextStyle(color: AppColors.grisTexto),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final item = items[i];
        final rank = i + 1;
        final isTop3 = rank <= 3;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isTop3
                ? Color(item['color'] as int).withOpacity(0.06)
                : AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: isTop3
                ? Border.all(
                    color: Color(item['color'] as int).withOpacity(0.2),
                  )
                : null,
          ),
          child: Row(
            children: [
              SizedBox(
                width: 32,
                child: isTop3
                    ? Text(
                        rank == 1
                            ? '🥇'
                            : rank == 2
                            ? '🥈'
                            : '🥉',
                        style: const TextStyle(fontSize: 20),
                      )
                    : Text(
                        '#$rank',
                        style: const TextStyle(
                          color: AppColors.grisTexto,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Color(item['color'] as int).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    item['initials'] as String,
                    style: TextStyle(
                      color: Color(item['color'] as int),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item['name'] as String,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.blueberry.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${item['foints']} F',
                  style: const TextStyle(
                    color: AppColors.blueberry,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Nav Item ──────────────────────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.blueberry.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: selected ? AppColors.blueberry : AppColors.grisTexto,
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: selected ? AppColors.blueberry : AppColors.grisTexto,
                fontSize: 11,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Profile Tab ───────────────────────────────────────────────────────────────

class _ProfileTab extends StatelessWidget {
  final VoidCallback onLogout;
  const _ProfileTab({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    if (user == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.blueberry),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 24),
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.blueberry, AppColors.midnight],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.blueberry.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: Text(
                user.name[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user.fullName,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '@${user.username}',
            style: const TextStyle(color: AppColors.grisTexto, fontSize: 14),
          ),
          if (user.email != null) ...[
            const SizedBox(height: 4),
            Text(
              user.email!,
              style: const TextStyle(color: AppColors.grisTexto, fontSize: 13),
            ),
          ],
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatCard(
                label: 'Foints\ntemporada',
                value: '${user.fointsSeason}',
              ),
              _StatCard(label: 'Foints\ntotales', value: '${user.fointsTotal}'),
            ],
          ),
          const SizedBox(height: 32),
          OutlinedButton.icon(
            onPressed: onLogout,
            icon: const Icon(Icons.logout, color: AppColors.error),
            label: const Text(
              'Cerrar sesión',
              style: TextStyle(color: AppColors.error),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.error),
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 145,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightBlue.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: AppColors.blueberry,
              fontSize: 30,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(color: AppColors.grisTexto, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
