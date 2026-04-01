import 'package:flutter/material.dart';
// Importar todas sus pantallas
//import 'screens/pantalla_login.dart';
//import 'screens/pantalla_lista.dart';
import 'screens/pantalla_detalle.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Focus up',
      // === CAMBIAR AQUI PARA VER CADA PANTALLA ===
      //home: const PantallaInicio(),
      //home: const PantallaLista(),
      home: const PantallaRegistroTarea(),
    );
  }
}
