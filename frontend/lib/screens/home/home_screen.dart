import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/task_provider.dart';
import 'widgets/task_card.dart';
import 'widgets/ranking_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().loadTodayTasks();
    });
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Buenos dias';
    if (hour < 18) return 'Buenas tardes';
    return 'Buenas noches';
  }

  String _todayFormatted() {
    const meses = ['enero','febrero','marzo','abril','mayo','junio','julio','agosto','septiembre','octubre','noviembre','diciembre'];
    const dias  = ['lunes','martes','miercoles','jueves','viernes','sabado','domingo'];
    final now = DateTime.now();
    return '${dias[now.weekday - 1]}, ${now.day} de ${meses[now.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final auth      = context.watch<AuthProvider>();
    final taskProv  = context.watch<TaskProvider>();
    final user      = auth.user;

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            // ── Pantalla Inicio ──────────────────────────────────────────
            RefreshIndicator(
              color: AppColors.naranja,
              onRefresh: () => taskProv.loadTodayTasks(),
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _greeting(),
                                    style: const TextStyle(color: AppColors.grisTexto, fontSize: 14),
                                  ),
                                  Text(
                                    user?.name ?? '',
                                    style: const TextStyle(
                                      color: AppColors.blanco,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: () => setState(() => _selectedIndex = 2),
                                child: CircleAvatar(
                                  radius: 22,
                                  backgroundColor: AppColors.vinotinto,
                                  child: Text(
                                    user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : '?',
                                    style: const TextStyle(color: AppColors.blanco, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),
                          Text(
                            _todayFormatted(),
                            style: const TextStyle(color: AppColors.grisTexto, fontSize: 13),
                          ),

                          const SizedBox(height: 24),

                          // Ranking
                          if (user != null) RankingWidget(user: user),

                          const SizedBox(height: 28),

                          // Titulo tareas
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Tareas de hoy',
                                style: TextStyle(
                                  color: AppColors.blanco,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${taskProv.todayTasks.where((t) => t.isDone).length}/${taskProv.todayTasks.length}',
                                style: const TextStyle(color: AppColors.grisTexto, fontSize: 13),
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
                      child: Center(child: CircularProgressIndicator(color: AppColors.naranja)),
                    )
                  else if (taskProv.todayTasks.isEmpty)
                    SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_circle_outline, color: AppColors.grisTexto, size: 64),
                            const SizedBox(height: 16),
                            const Text('Sin tareas para hoy', style: TextStyle(color: AppColors.blanco, fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            const Text('Agrega una tarea para comenzar', style: TextStyle(color: AppColors.grisTexto)),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () => context.go('/create-task'),
                              icon: const Icon(Icons.add),
                              label: const Text('Nueva tarea'),
                              style: ElevatedButton.styleFrom(minimumSize: const Size(180, 48)),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (_, i) => TaskCard(task: taskProv.todayTasks[i]),
                          childCount: taskProv.todayTasks.length,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ── Placeholder Calendario ───────────────────────────────────
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_month_rounded, color: AppColors.grisTexto, size: 64),
                  SizedBox(height: 16),
                  Text('Calendario', style: TextStyle(color: AppColors.blanco, fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('Proximamente', style: TextStyle(color: AppColors.grisTexto)),
                ],
              ),
            ),

            // ── Perfil ───────────────────────────────────────────────────
            _ProfileTab(onLogout: () async {
              await context.read<AuthProvider>().logout();
              if (context.mounted) context.go('/login');
            }),
          ],
        ),
      ),

      // FAB para crear tarea
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () => context.go('/create-task'),
              backgroundColor: AppColors.naranja,
              child: const Icon(Icons.add, color: AppColors.blanco),
            )
          : null,

      // Bottom nav
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        backgroundColor: AppColors.tarjeta,
        selectedItemColor: AppColors.naranja,
        unselectedItemColor: AppColors.grisTexto,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded),       label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month),     label: 'Calendario'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline),     label: 'Perfil'),
        ],
      ),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  final VoidCallback onLogout;
  const _ProfileTab({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    if (user == null) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 24),
          CircleAvatar(
            radius: 48,
            backgroundColor: AppColors.vinotinto,
            child: Text(
              user.name[0].toUpperCase(),
              style: const TextStyle(color: AppColors.blanco, fontSize: 40, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          Text(user.fullName, style: const TextStyle(color: AppColors.blanco, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('@${user.username}', style: const TextStyle(color: AppColors.grisTexto, fontSize: 14)),
          if (user.email != null) ...[
            const SizedBox(height: 4),
            Text(user.email!, style: const TextStyle(color: AppColors.grisTexto, fontSize: 13)),
          ],
          const SizedBox(height: 32),
          // Foints
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _Stat(label: 'Foints temporada', value: '${user.fointsSeason}'),
              _Stat(label: 'Foints totales',   value: '${user.fointsTotal}'),
            ],
          ),
          const Spacer(),
          OutlinedButton.icon(
            onPressed: onLogout,
            icon: const Icon(Icons.logout, color: AppColors.error),
            label: const Text('Cerrar sesion', style: TextStyle(color: AppColors.error)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.error),
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: AppColors.amarillo, fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: AppColors.grisTexto, fontSize: 12)),
      ],
    );
  }
}