import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';

// Esta pantalla se usa si en algun momento se navega a /profile directamente.
// El perfil embebido en home esta en home_screen.dart como _ProfileTab.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.naranja)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.blanco),
          onPressed: () => context.go('/home'),
        ),
        title: const Text('Mi perfil', style: TextStyle(color: AppColors.blanco)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            CircleAvatar(
              radius: 52,
              backgroundColor: AppColors.vinotinto,
              child: Text(
                user.name[0].toUpperCase(),
                style: const TextStyle(color: AppColors.blanco, fontSize: 44, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            Text(user.fullName, style: const TextStyle(color: AppColors.blanco, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('@${user.username}', style: const TextStyle(color: AppColors.grisTexto, fontSize: 15)),
            if (user.email != null) ...[
              const SizedBox(height: 4),
              Text(user.email!, style: const TextStyle(color: AppColors.grisTexto, fontSize: 13)),
            ],
            if (user.description != null && user.description!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(user.description!, style: const TextStyle(color: AppColors.grisTexto, fontSize: 14), textAlign: TextAlign.center),
            ],
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatCard(label: 'Foints\ntemporada', value: '${user.fointsSeason}'),
                _StatCard(label: 'Foints\ntotales',   value: '${user.fointsTotal}'),
              ],
            ),
            const Spacer(),
            OutlinedButton.icon(
              onPressed: () async {
                await context.read<AuthProvider>().logout();
                if (context.mounted) context.go('/login');
              },
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
      width: 140,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.tarjeta,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(value, style: const TextStyle(color: AppColors.amarillo, fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(color: AppColors.grisTexto, fontSize: 12), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}