import 'package:flutter/material.dart';

class PantallaRegistroTarea extends StatelessWidget {
  const PantallaRegistroTarea({super.key});

  // Paleta
  static const Color moradoOscuro = Color(0xFF5B0F3B);
  static const Color vinotinto = Color(0xFF8E0E3A);
  static const Color rojo = Color(0xFFD9042B);
  static const Color naranja = Color(0xFFFF5733);
  static const Color amarillo = Color(0xFFFFC300);
  static const Color blanco = Color(0xFFFFFFFF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo degradado
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [moradoOscuro, vinotinto],
              ),
            ),
          ),

          // Onda superior
          //Positioned(
            //top: -80,
            //right: -60,
            //child: Container(
              //width: 220,
              //height: 220,
              //decoration: const BoxDecoration(
                //gradient: LinearGradient(colors: [naranja, amarillo]),
                //borderRadius: BorderRadius.only(
                  //bottomLeft: Radius.circular(200),
                //),
              //),
            //),
          //),

          // Contenido
          SafeArea(
            child: Center(
              child: Container(
                width: 400,
                padding: const EdgeInsets.all(50),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título app
                      const Center(
                        child: Text(
                          'Focus up',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w600,
                            color: Colors.deepOrange,
                            letterSpacing: 1,
                          ),
                        ),
                      ),

                      const SizedBox(height: 50),

                      const Text(
                        'Nueva tarea',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        'Organiza lo que debes hacer',
                        style: TextStyle(color: Colors.grey),
                      ),

                      const SizedBox(height: 25),

                      // Campo título
                      _CampoTexto(
                        hint: 'Título de la tarea',
                        icono: Icons.task_alt,
                      ),

                      const SizedBox(height: 15),

                      // Campo descripción
                      _CampoTexto(
                        hint: 'Descripción',
                        icono: Icons.description,
                        maxLines: 3,
                      ),

                      const SizedBox(height: 20),

                      // Prioridad
                      const Text(
                        'Prioridad',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 10),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          _ChipPrioridad('Alta', rojo),
                          _ChipPrioridad('Media', naranja),
                          _ChipPrioridad('Baja', amarillo),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Fecha
                      const Text(
                        'Fecha límite',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 10),

                      _CampoTexto(
                        hint: 'Seleccionar fecha',
                        icono: Icons.calendar_month,
                      ),

                      const SizedBox(height: 30),

                      // Botón guardar
                      Container(
                        width: double.infinity,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [rojo, naranja, amarillo],
                          ),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Center(
                          child: Text(
                            'Guardar tarea',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Campo reutilizable
class _CampoTexto extends StatelessWidget {
  final String hint;
  final IconData icono;
  final int maxLines;

  const _CampoTexto({
    required this.hint,
    required this.icono,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icono),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

// Chip prioridad
class _ChipPrioridad extends StatelessWidget {
  final String texto;
  final Color color;

  const _ChipPrioridad(this.texto, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        texto,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}
