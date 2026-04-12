import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey        = GlobalKey<FormState>();
  final _identifierCtrl = TextEditingController();
  final _passwordCtrl   = TextEditingController();

  bool _obscurePassword = true;
  bool _loading         = false;
  bool _identifierFocused = false;
  bool _passwordFocused   = false;

  late final AnimationController _eyeController;
  late final Animation<double>   _eyeAnimation;

  final FocusNode _identifierFocus = FocusNode();
  final FocusNode _passwordFocus   = FocusNode();

  @override
  void initState() {
    super.initState();

    _eyeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _eyeAnimation = CurvedAnimation(
      parent: _eyeController,
      curve: Curves.easeInOut,
    );

    _identifierFocus.addListener(() {
      setState(() => _identifierFocused = _identifierFocus.hasFocus);
    });
    _passwordFocus.addListener(() {
      setState(() => _passwordFocused = _passwordFocus.hasFocus);
    });
  }

  @override
  void dispose() {
    _identifierCtrl.dispose();
    _passwordCtrl.dispose();
    _eyeController.dispose();
    _identifierFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _toggleObscure() {
    setState(() => _obscurePassword = !_obscurePassword);
    if (_obscurePassword) {
      _eyeController.reverse();
    } else {
      _eyeController.forward();
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final auth = context.read<AuthProvider>();
    final ok   = await auth.login(
      _identifierCtrl.text.trim(),
      _passwordCtrl.text,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (ok) {
      context.go('/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            auth.error ?? 'Error al iniciar sesion',
            style: GoogleFonts.nunito(color: Colors.white),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Header decorativo ──────────────────────────────────────
            _Header(height: size.height * 0.32),

            // ── Formulario ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Titulo
                    Text(
                      'Bienvenido',
                      style: GoogleFonts.nunito(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: AppColors.midnight,
                        letterSpacing: -0.5,
                      ),
                    )
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.2, end: 0, duration: 400.ms),

                    const SizedBox(height: 4),

                    Text(
                      'Inicia sesión para continuar',
                      style: GoogleFonts.nunito(
                        fontSize: 15,
                        color: AppColors.grisTexto,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                    .animate()
                    .fadeIn(delay: 100.ms, duration: 400.ms),

                    const SizedBox(height: 32),

                    // Campo identificador
                    _FieldLabel(text: 'Correo, teléfono o usuario')
                    .animate()
                    .fadeIn(delay: 150.ms, duration: 400.ms),

                    const SizedBox(height: 8),

                    _AnimatedField(
                      controller: _identifierCtrl,
                      focusNode: _identifierFocus,
                      isFocused: _identifierFocused,
                      hintText: 'tucorreo@gmail.com',
                      prefixIcon: Icons.person_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Este campo es obligatorio';
                        }
                        return null;
                      },
                    )
                    .animate()
                    .fadeIn(delay: 200.ms, duration: 400.ms)
                    .slideX(begin: -0.05, end: 0, duration: 400.ms),

                    const SizedBox(height: 20),

                    // Campo contraseña
                    _FieldLabel(text: 'Contraseña')
                    .animate()
                    .fadeIn(delay: 250.ms, duration: 400.ms),

                    const SizedBox(height: 8),

                    _AnimatedField(
                      controller: _passwordCtrl,
                      focusNode: _passwordFocus,
                      isFocused: _passwordFocused,
                      hintText: '••••••••',
                      prefixIcon: Icons.lock_outline_rounded,
                      obscureText: _obscurePassword,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Ingresa tu contraseña';
                        if (v.length < 6) return 'Mínimo 6 caracteres';
                        return null;
                      },
                      suffix: _EyeButton(
                        animation: _eyeAnimation,
                        obscure: _obscurePassword,
                        onTap: _toggleObscure,
                      ),
                    )
                    .animate()
                    .fadeIn(delay: 300.ms, duration: 400.ms)
                    .slideX(begin: -0.05, end: 0, duration: 400.ms),

                    // Olvidaste tu contraseña
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => context.go('/forgot-password'),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 8),
                        ),
                        child: Text(
                          '¿Olvidaste tu contraseña?',
                          style: GoogleFonts.nunito(
                            color: AppColors.blueberry,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    )
                    .animate()
                    .fadeIn(delay: 350.ms, duration: 400.ms),

                    const SizedBox(height: 8),

                    // Botón login
                    _loading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.midnight,
                              strokeWidth: 2.5,
                            ),
                          )
                        : SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.midnight,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Text(
                                'Iniciar sesión',
                                style: GoogleFonts.nunito(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          )
                        .animate()
                        .fadeIn(delay: 400.ms, duration: 400.ms)
                        .slideY(begin: 0.1, end: 0, duration: 400.ms),

                    const SizedBox(height: 28),

                    // Ir a registro
                    Center(
                      child: GestureDetector(
                        onTap: () => context.go('/register'),
                        child: Text.rich(
                          TextSpan(
                            text: '¿No tienes cuenta? ',
                            style: GoogleFonts.nunito(
                              color: AppColors.grisTexto,
                              fontSize: 14,
                            ),
                            children: [
                              TextSpan(
                                text: 'Regístrate',
                                style: GoogleFonts.nunito(
                                  color: AppColors.midnight,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    .animate()
                    .fadeIn(delay: 450.ms, duration: 400.ms),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Header decorativo ──────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final double height;
  const _Header({required this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        children: [
          // Fondo con forma de ola
          ClipPath(
            clipper: _WaveClipper(),
            child: Container(
              height: height,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.blueberry, AppColors.midnight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),

          // Círculos decorativos
          Positioned(
            top: -20,
            right: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          Positioned(
            top: 30,
            right: 60,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.gum.withOpacity(0.25),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.lightBlue.withOpacity(0.15),
              ),
            ),
          ),

          // Icono central
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.bolt_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                )
                .animate()
                .scale(
                  begin: const Offset(0.5, 0.5),
                  end: const Offset(1, 1),
                  duration: 600.ms,
                  curve: Curves.elasticOut,
                ),

                const SizedBox(height: 12),

                Text(
                  'Focus App',
                  style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                )
                .animate()
                .fadeIn(delay: 200.ms, duration: 500.ms)
                .slideY(begin: 0.3, end: 0, duration: 500.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Wave clipper ───────────────────────────────────────────────────────────

class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(
      size.width * 0.25, size.height,
      size.width * 0.5,  size.height - 20,
    );
    path.quadraticBezierTo(
      size.width * 0.75, size.height - 40,
      size.width,        size.height - 10,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_WaveClipper oldClipper) => false;
}

// ── Campo animado ──────────────────────────────────────────────────────────

class _AnimatedField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isFocused;
  final String hintText;
  final IconData prefixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final Widget? suffix;

  const _AnimatedField({
    required this.controller,
    required this.focusNode,
    required this.isFocused,
    required this.hintText,
    required this.prefixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isFocused
              ? AppColors.blueberry
              : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: isFocused
            ? [
                BoxShadow(
                  color: AppColors.blueberry.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: GoogleFonts.nunito(
          color: AppColors.midnight,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.nunito(
            color: AppColors.grisTexto.withOpacity(0.6),
            fontSize: 15,
          ),
          prefixIcon: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              prefixIcon,
              color: isFocused ? AppColors.blueberry : AppColors.grisTexto,
              size: 20,
            ),
          ),
          suffixIcon: suffix,
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          errorStyle: GoogleFonts.nunito(
            color: AppColors.error,
            fontSize: 12,
          ),
        ),
        validator: validator,
      ),
    );
  }
}

// ── Label de campo ─────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.nunito(
        color: AppColors.midnight,
        fontSize: 13,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
      ),
    );
  }
}

// ── Botón del ojito ────────────────────────────────────────────────────────

class _EyeButton extends StatelessWidget {
  final Animation<double> animation;
  final bool obscure;
  final VoidCallback onTap;

  const _EyeButton({
    required this.animation,
    required this.obscure,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                // Ojo abierto — aparece cuando se muestra la contraseña
                Opacity(
                  opacity: animation.value,
                  child: Transform.scale(
                    scale: 0.8 + (animation.value * 0.2),
                    child: const Icon(
                      Icons.visibility_outlined,
                      color: AppColors.blueberry,
                      size: 22,
                    ),
                  ),
                ),
                // Ojo cerrado — aparece cuando está oculta
                Opacity(
                  opacity: 1 - animation.value,
                  child: Transform.scale(
                    scale: 0.8 + ((1 - animation.value) * 0.2),
                    child: Icon(
                      Icons.visibility_off_outlined,
                      color: AppColors.grisTexto.withOpacity(0.6),
                      size: 22,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}