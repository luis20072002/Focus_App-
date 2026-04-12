import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/task_provider.dart';

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _formKey     = GlobalKey<FormState>();
  final _nameCtrl    = TextEditingController();
  final _descCtrl    = TextEditingController();

  bool      _isUrgent        = false;
  bool      _isRecurrent     = false;
  String    _notifType       = 'push';
  String    _recurrenceType  = 'ninguna';
  DateTime  _scheduledDate   = DateTime.now().add(const Duration(hours: 1));
  DateTime? _recurrenceEnd;
  bool      _loading         = false;

  // Dias seleccionados para recurrencia semanal/personalizada (1=lunes..7=domingo)
  final Set<int> _selectedDays = {};

  final List<String> _notifTypes = ['push', 'email', 'ninguna'];
  final List<Map<String, dynamic>> _recurrenceTypes = [
    {'value': 'ninguna',       'label': 'No repetir'},
    {'value': 'diaria',        'label': 'Todos los dias'},
    {'value': 'semanal',       'label': 'Semanal'},
    {'value': 'personalizada', 'label': 'Personalizada'},
  ];

  final List<String> _dayLabels = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _scheduledDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(colorScheme: const ColorScheme.dark(primary: AppColors.naranja)),
        child: child!,
      ),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_scheduledDate),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(colorScheme: const ColorScheme.dark(primary: AppColors.naranja)),
        child: child!,
      ),
    );
    if (time == null) return;

    setState(() {
      _scheduledDate = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _pickRecurrenceEnd() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(colorScheme: const ColorScheme.dark(primary: AppColors.naranja)),
        child: child!,
      ),
    );
    if (date != null) setState(() => _recurrenceEnd = date);
  }

  String _formatDateTime(DateTime dt) {
    const meses = ['ene','feb','mar','abr','may','jun','jul','ago','sep','oct','nov','dic'];
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${meses[dt.month - 1]} ${dt.year}  $h:$m';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Validar dias si es semanal o personalizada
    if (_isRecurrent &&
        (_recurrenceType == 'semanal' || _recurrenceType == 'personalizada') &&
        _selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona al menos un dia'), backgroundColor: AppColors.error),
      );
      return;
    }

    setState(() => _loading = true);

final recurrenceDays = _selectedDays.isNotEmpty
    ? (_selectedDays.toList()..sort())
    : null;

    final ok = await context.read<TaskProvider>().createTask(
      name:              _nameCtrl.text.trim(),
      description:       _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      isUrgent:          _isUrgent,
      scheduledDate:     _scheduledDate.toIso8601String(),
      notificationType:  _notifType,
      isRecurrent:       _isRecurrent,
      recurrenceType:    _isRecurrent ? _recurrenceType : 'ninguna',
      recurrenceDays:    recurrenceDays?.join(','),
      recurrenceEndDate: _recurrenceEnd?.toIso8601String().split('T').first,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (ok) {
      context.go('/home');
    } else {
      final error = context.read<TaskProvider>().error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? 'Error al crear la tarea'), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.blanco),
          onPressed: () => context.go('/home'),
        ),
        title: const Text('Nueva tarea', style: TextStyle(color: AppColors.blanco)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nombre
              _label('Nombre de la tarea'),
              TextFormField(
                controller: _nameCtrl,
                style: const TextStyle(color: AppColors.blanco),
                decoration: const InputDecoration(hintText: 'Ej: Ir al gimnasio'),
                validator: (v) => v == null || v.trim().isEmpty ? 'El nombre es obligatorio' : null,
              ),

              const SizedBox(height: 20),

              // Descripcion
              _label('Descripcion (opcional)'),
              TextFormField(
                controller: _descCtrl,
                style: const TextStyle(color: AppColors.blanco),
                maxLines: 3,
                decoration: const InputDecoration(hintText: 'Agrega detalles...'),
              ),

              const SizedBox(height: 20),

              // Fecha y hora
              _label('Fecha y hora'),
              GestureDetector(
                onTap: _pickDateTime,
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
                      Text(_formatDateTime(_scheduledDate), style: const TextStyle(color: AppColors.blanco)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Notificaciones
              _label('Tipo de notificacion'),
              DropdownButtonFormField<String>(
                initialValue: _notifType,
                dropdownColor: AppColors.tarjeta,
                style: const TextStyle(color: AppColors.blanco),
                decoration: const InputDecoration(),
                items: _notifTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) => setState(() => _notifType = v!),
              ),

              const SizedBox(height: 20),

              // Urgente
              Container(
                decoration: BoxDecoration(
                  color: AppColors.tarjeta,
                  borderRadius: BorderRadius.circular(12),
                  border: _isUrgent ? Border.all(color: AppColors.rojo.withOpacity(0.5)) : null,
                ),
                child: SwitchListTile(
                  title: const Text('Tarea urgente', style: TextStyle(color: AppColors.blanco)),
                  subtitle: const Text('No puede obtener Foints ni ser recurrente', style: TextStyle(color: AppColors.grisTexto, fontSize: 12)),
                  value: _isUrgent,
                  activeThumbColor: AppColors.rojo,
                  onChanged: (v) => setState(() {
                    _isUrgent = v;
                    if (v) _isRecurrent = false;
                  }),
                ),
              ),

              const SizedBox(height: 12),

              // Recurrente
              if (!_isUrgent) ...[
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.tarjeta,
                    borderRadius: BorderRadius.circular(12),
                    border: _isRecurrent ? Border.all(color: AppColors.naranja.withOpacity(0.5)) : null,
                  ),
                  child: SwitchListTile(
                    title: const Text('Tarea recurrente', style: TextStyle(color: AppColors.blanco)),
                    subtitle: const Text('Se repetira segun la frecuencia elegida', style: TextStyle(color: AppColors.grisTexto, fontSize: 12)),
                    value: _isRecurrent,
                    activeThumbColor: AppColors.naranja,
                    onChanged: (v) => setState(() {
                      _isRecurrent = v;
                      if (!v) {
                        _recurrenceType = 'ninguna';
                        _selectedDays.clear();
                        _recurrenceEnd = null;
                      } else {
                        _recurrenceType = 'diaria';
                      }
                    }),
                  ),
                ),

                if (_isRecurrent) ...[
                  const SizedBox(height: 16),

                  // Tipo de recurrencia
                  _label('Frecuencia'),
                  ...(_recurrenceTypes.where((r) => r['value'] != 'ninguna').map((r) => RadioListTile<String>(
                    value: r['value'],
                    groupValue: _recurrenceType,
                    activeColor: AppColors.naranja,
                    title: Text(r['label'], style: const TextStyle(color: AppColors.blanco)),
                    onChanged: (v) => setState(() {
                      _recurrenceType = v!;
                      _selectedDays.clear();
                    }),
                  ))),

                  // Selector de dias
                  if (_recurrenceType == 'semanal' || _recurrenceType == 'personalizada') ...[
                    const SizedBox(height: 8),
                    _label('Dias'),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(7, (i) {
                        final day = i + 1;
                        final selected = _selectedDays.contains(day);
                        return GestureDetector(
                          onTap: () => setState(() {
                            selected ? _selectedDays.remove(day) : _selectedDays.add(day);
                          }),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: selected ? AppColors.naranja : AppColors.tarjeta,
                              border: Border.all(
                                color: selected ? AppColors.naranja : AppColors.grisTexto.withOpacity(0.3),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _dayLabels[i],
                              style: TextStyle(
                                color: selected ? AppColors.blanco : AppColors.grisTexto,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Fecha fin de recurrencia
                  _label('Fecha de fin (opcional)'),
                  GestureDetector(
                    onTap: _pickRecurrenceEnd,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColors.tarjeta,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.event_outlined, color: AppColors.grisTexto, size: 20),
                          const SizedBox(width: 12),
                          Text(
                            _recurrenceEnd == null
                                ? 'Sin fecha de fin'
                                : '${_recurrenceEnd!.day}/${_recurrenceEnd!.month}/${_recurrenceEnd!.year}',
                            style: TextStyle(
                              color: _recurrenceEnd == null ? AppColors.grisTexto : AppColors.blanco,
                            ),
                          ),
                          if (_recurrenceEnd != null) ...[
                            const Spacer(),
                            GestureDetector(
                              onTap: () => setState(() => _recurrenceEnd = null),
                              child: const Icon(Icons.close, color: AppColors.grisTexto, size: 18),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ],

              const SizedBox(height: 32),

              _loading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.naranja))
                  : ElevatedButton(
                      onPressed: _submit,
                      child: const Text('Crear tarea', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: const TextStyle(color: AppColors.blanco, fontSize: 13, fontWeight: FontWeight.w500)),
  );
}