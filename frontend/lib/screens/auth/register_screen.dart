import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey      = GlobalKey<FormState>();
  final _nameCtrl     = TextEditingController();
  final _lastnameCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _phoneCtrl    = TextEditingController();
  final _passCtrl     = TextEditingController();
  final _passConfCtrl = TextEditingController();
  DateTime? _birthDate;
  bool _obscurePass     = true;
  bool _obscureConfirm  = true;
  bool _loading         = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _lastnameCtrl.dispose();
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    _passConfCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1920),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 13)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(primary: AppColors.naranja),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona tu fecha de nacimiento'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    final email = _emailCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    if (email.isEmpty && phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes ingresar al menos un correo o telefono'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _loading = true);
    final auth = context.read<AuthProvider>();
    final ok = await auth.register(
      name:      _nameCtrl.text.trim(),
      lastname:  _lastnameCtrl.text.trim(),
      username:  _usernameCtrl.text.trim(),
      password:  _passCtrl.text,
      email:     email.isEmpty ? null : email,
      phone:     phone.isEmpty ? null : phone,
      birthDate: _birthDate!.toIso8601String().split('T').first,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (ok) {
      context.go('/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? 'Error al registrarse'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscure = false,
    VoidCallback? toggleObscure,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.blanco, fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          style: const TextStyle(color: AppColors.blanco),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.grisTexto),
            suffixIcon: toggleObscure != null
                ? IconButton(
                    icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, color: AppColors.grisTexto),
                    onPressed: toggleObscure,
                  )
                : null,
          ),
          validator: validator,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.blanco),
          onPressed: () => context.go('/login'),
        ),
        title: const Text('Crear cuenta', style: TextStyle(color: AppColors.blanco)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildField(
                  controller: _nameCtrl,
                  label: 'Nombre',
                  hint: 'Juan',
                  icon: Icons.badge_outlined,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Campo obligatorio' : null,
                ),
                _buildField(
                  controller: _lastnameCtrl,
                  label: 'Apellido',
                  hint: 'Perez',
                  icon: Icons.badge_outlined,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Campo obligatorio' : null,
                ),
                _buildField(
                  controller: _usernameCtrl,
                  label: 'Nombre de usuario',
                  hint: '@juanp',
                  icon: Icons.alternate_email,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Campo obligatorio';
                    if (v.trim().length < 3) return 'Minimo 3 caracteres';
                    return null;
                  },
                ),
                _buildField(
                  controller: _emailCtrl,
                  label: 'Correo (opcional si pones telefono)',
                  hint: 'juan@gmail.com',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v != null && v.isNotEmpty) {
                      final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
                      if (!emailRegex.hasMatch(v)) return 'Correo invalido';
                    }
                    return null;
                  },
                ),
                _buildField(
                  controller: _phoneCtrl,
                  label: 'Telefono (opcional si pones correo)',
                  hint: '+573001234567',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),

                // Fecha de nacimiento
                const Text('Fecha de nacimiento', style: TextStyle(color: AppColors.blanco, fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.tarjeta,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, color: AppColors.grisTexto, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          _birthDate == null
                              ? 'Seleccionar fecha'
                              : '${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}',
                          style: TextStyle(
                            color: _birthDate == null ? AppColors.grisTexto : AppColors.blanco,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                _buildField(
                  controller: _passCtrl,
                  label: 'Contraseña',
                  hint: '••••••••',
                  icon: Icons.lock_outline,
                  obscure: _obscurePass,
                  toggleObscure: () => setState(() => _obscurePass = !_obscurePass),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Campo obligatorio';
                    if (v.length < 6) return 'Minimo 6 caracteres';
                    return null;
                  },
                ),
                _buildField(
                  controller: _passConfCtrl,
                  label: 'Confirmar contraseña',
                  hint: '••••••••',
                  icon: Icons.lock_outline,
                  obscure: _obscureConfirm,
                  toggleObscure: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  validator: (v) {
                    if (v != _passCtrl.text) return 'Las contraseñas no coinciden';
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                _loading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.naranja))
                    : ElevatedButton(
                        onPressed: _submit,
                        child: const Text('Crear cuenta', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),

                const SizedBox(height: 20),
                Center(
                  child: GestureDetector(
                    onTap: () => context.go('/login'),
                    child: const Text.rich(
                      TextSpan(
                        text: '¿Ya tienes cuenta? ',
                        style: TextStyle(color: AppColors.grisTexto),
                        children: [
                          TextSpan(
                            text: 'Inicia sesion',
                            style: TextStyle(color: AppColors.naranja, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}