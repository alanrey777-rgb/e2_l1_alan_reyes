import 'package:flutter/material.dart';

void main() => runApp(
  MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Panel de hábitos del día',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF23766B)),
      scaffoldBackgroundColor: const Color(0xFFF5F7F4),
      useMaterial3: true,
    ),
    home: const PanelHabitos(),
  ),
);

class PanelHabitos extends StatefulWidget {
  const PanelHabitos({super.key});
  @override
  State<PanelHabitos> createState() => _PanelHabitosState();
}

class _PanelHabitosState extends State<PanelHabitos> {
  static const habitos = <String>[
    'Beber 2 L de agua',
    'Leer 20 minutos',
    'Caminar 30 minutos',
    'Estudiar Flutter',
    'Dormir 8 horas',
  ];
  late List<bool> cumplidos;
  late int meta;
  late bool enfoque;
  late String nota;
  late final TextEditingController notaController;

  @override
  void initState() {
    super.initState();
    cumplidos = List<bool>.filled(habitos.length, false);
    meta = 3;
    enfoque = false;
    nota = '';
    notaController = TextEditingController();
  }

  int get cantidadCumplidos => cumplidos.where((cumplido) => cumplido).length;
  double get progreso => cantidadCumplidos / habitos.length;
  int get porcentaje => (progreso * 100).round();
  bool get metaAlcanzada => cantidadCumplidos >= meta;
  String get mensaje {
    if (porcentaje == 0) return '¡Empecemos!';
    if (porcentaje < 50) return 'Buen inicio';
    if (porcentaje < 100) return '¡Vas muy bien!';
    return '¡Día completado! 🎉';
  }

  void guardarNota() => setState(() => nota = notaController.text.trim());

  void reiniciarDia() {
    setState(() {
      cumplidos = List<bool>.filled(habitos.length, false);
      meta = 3;
      enfoque = false;
      nota = '';
      notaController.clear();
    });
    FocusScope.of(context).unfocus();
  }

  @override
  void dispose() {
    notaController.dispose();
    super.dispose();
  }

  Widget tarjeta(Widget contenido) => Card(
    margin: const EdgeInsets.only(bottom: 16),
    elevation: 0,
    color: Colors.white,
    child: Padding(padding: const EdgeInsets.all(20), child: contenido),
  );

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de hábitos del día'),
        backgroundColor: const Color(0xFFF5F7F4),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'UN PASO A LA VEZ',
                    style: TextStyle(
                      letterSpacing: 2,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF23766B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tu día, tus hábitos',
                    style: textos.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 4, bottom: 20),
                    child: Text('Pequeñas acciones que suman bienestar.'),
                  ),
                  tarjeta(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cumplidos: $cantidadCumplidos / ${habitos.length}',
                          style: textos.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                          value: progreso,
                          minHeight: 10,
                          borderRadius: BorderRadius.circular(8),
                          semanticsLabel: 'Progreso diario',
                          semanticsValue: '$porcentaje%',
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '$porcentaje% · $mensaje',
                          key: const Key('progresoTexto'),
                          style: textos.titleMedium,
                        ),
                        const Divider(height: 28),
                        Text('Meta: $meta hábitos', style: textos.titleMedium),
                        Slider(
                          key: const Key('metaSlider'),
                          value: meta.toDouble(),
                          min: 1,
                          max: 5,
                          divisions: 4,
                          label: '$meta',
                          onChanged: (valor) =>
                              setState(() => meta = valor.round()),
                        ),
                        if (metaAlcanzada)
                          const Chip(
                            avatar: Icon(Icons.check_circle, size: 18),
                            label: Text('Meta alcanzada'),
                          ),
                      ],
                    ),
                  ),
                  tarjeta(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Mis hábitos', style: textos.titleLarge),
                        SwitchListTile(
                          key: const Key('enfoqueSwitch'),
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Modo enfoque'),
                          subtitle: const Text('Mostrar solo los pendientes'),
                          value: enfoque,
                          onChanged: (valor) => setState(() => enfoque = valor),
                        ),
                        const Divider(),
                        // Filtrar la vista conserva el índice original de cada hábito.
                        for (int indice = 0; indice < habitos.length; indice++)
                          if (!enfoque || !cumplidos[indice])
                            CheckboxListTile(
                              key: Key('habito_$indice'),
                              contentPadding: EdgeInsets.zero,
                              controlAffinity: ListTileControlAffinity.leading,
                              title: Text(habitos[indice]),
                              value: cumplidos[indice],
                              onChanged: (valor) => setState(
                                () => cumplidos[indice] = valor ?? false,
                              ),
                            ),
                        if (enfoque && cantidadCumplidos == habitos.length)
                          const Padding(
                            padding: EdgeInsets.all(12),
                            child: Text('¡No quedan hábitos pendientes!'),
                          ),
                      ],
                    ),
                  ),
                  tarjeta(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('Una nota para hoy', style: textos.titleLarge),
                        const SizedBox(height: 16),
                        TextField(
                          key: const Key('notaCampo'),
                          controller: notaController,
                          decoration: const InputDecoration(
                            labelText: 'Nota del día',
                            hintText: '¿Cómo te fue hoy?',
                            border: OutlineInputBorder(),
                          ),
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => guardarNota(),
                        ),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          key: const Key('guardarNota'),
                          onPressed: guardarNota,
                          icon: const Icon(Icons.save_outlined),
                          label: const Text('Guardar nota'),
                        ),
                        const SizedBox(height: 12),
                        Card.filled(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              nota.isEmpty ? 'Sin nota' : nota,
                              key: const Key('notaGuardada'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton.icon(
                    key: const Key('reiniciar'),
                    onPressed: reiniciarDia,
                    icon: const Icon(Icons.restart_alt),
                    label: const Text('Reiniciar día'),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
