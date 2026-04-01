import 'package:flutter/material.dart';

class PantallaLista extends StatelessWidget {
  const PantallaLista({super.key});

  // Paleta
  static const Color moradoOscuro = Color(0xFF5B0F3B);
  static const Color vinotinto = Color(0xFF8E0E3A);
  static const Color rojo = Color(0xFFD9042B);
  static const Color naranja = Color(0xFFFF5733);
  static const Color amarillo = Color(0xFFFFC300);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: moradoOscuro,
      body: SafeArea(
        child: Column(
          children: [
            // Header blanco
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF6F6F6),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(30),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // Saludo
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hi, Cristiano Ronaldo',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Organiza tus tareas',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: naranja,
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Calendario horizontal
                    SizedBox(
                      height: 70,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        children: const [
                          _DiaItem('Mon', '7', false),
                          _DiaItem('Tue', '8', false),
                          _DiaItem('Wed', '9', false),
                          _DiaItem('Thu', '10', true),
                          _DiaItem('Fri', '11', false),
                          _DiaItem('Sat', '12', false),
                          _DiaItem('Sun', '13', false),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Tarjeta principal
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [amarillo, naranja],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Plan del día',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text('Mantente enfocado en tus objetivos'),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Título lista
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Mis tareas',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Lista de tareas
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        children: const [
                          _TareaItem(
                            titulo: 'Estudiar Flutter',
                            estado: 'Pendiente',
                            completada: false,
                          ),
                          _TareaItem(
                            titulo: 'Diseñar pantalla login',
                            estado: 'Completada',
                            completada: true,
                          ),
                          _TareaItem(
                            titulo: 'Preparar presentación',
                            estado: 'Pendiente',
                            completada: false,
                          ),
                          _TareaItem(
                            titulo: 'Revisar base de datos',
                            estado: 'Completada',
                            completada: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom bar visual
            Container(
              height: 70,
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  Icon(Icons.home),
                  Icon(Icons.search),
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: naranja,
                    child: Icon(Icons.add, color: Colors.white),
                  ),
                  Icon(Icons.map),
                  Icon(Icons.person),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Item de día
class _DiaItem extends StatelessWidget {
  final String dia;
  final String numero;
  final bool activo;

  const _DiaItem(this.dia, this.numero, this.activo);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 55,
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        color: activo ? PantallaLista.amarillo : Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(dia, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 4),
          Text(numero, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// Item de tarea
class _TareaItem extends StatelessWidget {
  final String titulo;
  final String estado;
  final bool completada;

  const _TareaItem({
    required this.titulo,
    required this.estado,
    required this.completada,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            completada ? Icons.check_circle : Icons.radio_button_unchecked,
            color: completada ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              titulo,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                decoration: completada ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
          Text(
            estado,
            style: TextStyle(
              color: completada ? Colors.green : Colors.orange,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
