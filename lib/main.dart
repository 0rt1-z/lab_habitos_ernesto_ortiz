import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab 2 - Hábitos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.green, useMaterial3: true),
      home: const PanelHabitos(),
    );
  }
}

class PanelHabitos extends StatefulWidget {
  const PanelHabitos({super.key});

  @override
  State<PanelHabitos> createState() => _PanelHabitosState();
}

class _PanelHabitosState extends State<PanelHabitos> {
  // --- Datos fijos ---
  final List<String> _habitos = const [
    'Beber 2 L de agua',
    'Leer 20 minutos',
    'Caminar 30 minutos',
    'Estudiar Flutter',
    'Dormir 8 horas',
  ];

  static const int _metaInicial = 3;

  // --- Estado ---
  late List<bool> _cumplidos;
  int _meta = _metaInicial;
  bool _enfoque = false;
  String _nota = '';
  final List<int> _historial = [];
  final TextEditingController _notaCtrl = TextEditingController();

  // --- Ciclo de vida ---
  @override
  void initState() {
    super.initState();
    _cumplidos = List<bool>.filled(_habitos.length, false);
    _notaCtrl.addListener(_alCambiarTextoNota);
  }

  @override
  void dispose() {
    _notaCtrl.removeListener(_alCambiarTextoNota);
    _notaCtrl.dispose();
    super.dispose();
  }

  // --- Getters derivados ---
  int get _totalCumplidos => _cumplidos.where((c) => c).length;

  double get _progreso =>
      _habitos.isEmpty ? 0 : _totalCumplidos / _habitos.length;

  int get _porcentaje => (_progreso * 100).round();

  bool get _metaAlcanzada => _totalCumplidos >= _meta;

  String get _mensaje {
    final p = _porcentaje;
    if (p == 0) return '¡Empecemos!';
    if (p < 50) return 'Buen inicio';
    if (p < 100) return '¡Vas muy bien!';
    return '¡Día completado! 🎉';
  }

  Color get _colorProgreso {
    if (_porcentaje < 50) return Colors.red;
    if (_porcentaje < 100) return Colors.amber;
    return Colors.green;
  }

  List<int> get _indicesVisibles => [
    for (int i = 0; i < _habitos.length; i++)
      if (!(_enfoque && _cumplidos[i])) i,
  ];

  bool get _campoNotaVacio => _notaCtrl.text.trim().isEmpty;

  String get _textoHistorial => _historial.isEmpty
      ? 'Días anteriores: ninguno'
      : 'Días anteriores: ${_historial.join(', ')}';

  // --- Acciones ---
  void _alternarHabito(int index) {
    setState(() {
      _cumplidos[index] = !_cumplidos[index];
    });
  }

  void _cambiarMeta(double valor) {
    setState(() {
      _meta = valor.round();
    });
  }

  void _alternarEnfoque(bool valor) {
    setState(() {
      _enfoque = valor;
    });
  }

  void _guardarNota() {
    setState(() {
      _nota = _notaCtrl.text.trim();
    });
    FocusScope.of(context).unfocus();
  }

  void _reiniciarDia() {
    setState(() {
      _historial.add(_totalCumplidos);
      _cumplidos = List<bool>.filled(_habitos.length, false);
      _meta = _metaInicial;
      _enfoque = false;
      _nota = '';
    });
    _notaCtrl.clear();
  }

  void _alCambiarTextoNota() {
    if (!mounted) return;
    setState(() {});
  }

  // --- UI ---
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Hábitos — Cumplidos: $_totalCumplidos / ${_habitos.length}',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _construirProgreso(textTheme),
          const SizedBox(height: 12),
          _construirMeta(textTheme),
          const SizedBox(height: 12),
          SwitchListTile(
            title: const Text('Modo enfoque'),
            subtitle: const Text('Oculta los hábitos ya cumplidos'),
            value: _enfoque,
            onChanged: _alternarEnfoque,
          ),
          const Divider(),
          ..._construirListaHabitos(),
          const Divider(height: 32),
          _construirNota(),
          const SizedBox(height: 24),
          _construirReinicio(),
        ],
      ),
    );
  }

  Widget _construirProgreso(TextTheme textTheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _mensaje,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: _progreso,
                minHeight: 12,
                color: _colorProgreso,
                backgroundColor: Colors.grey.shade300,
              ),
            ),
            const SizedBox(height: 8),
            Text('Progreso: $_porcentaje %'),
          ],
        ),
      ),
    );
  }

  Widget _construirMeta(TextTheme textTheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Meta del día', style: textTheme.titleMedium),
            Slider(
              value: _meta.toDouble(),
              min: 1,
              max: _habitos.length.toDouble(),
              divisions: _habitos.length - 1,
              label: '$_meta',
              onChanged: _cambiarMeta,
            ),
            Row(
              children: [
                Text('Meta: $_meta hábitos'),
                const Spacer(),
                if (_metaAlcanzada)
                  const Chip(
                    avatar: Icon(Icons.emoji_events, color: Colors.amber),
                    label: Text('Meta alcanzada'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _construirListaHabitos() {
    final visibles = _indicesVisibles;

    if (visibles.isEmpty) {
      return const [
        ListTile(
          leading: Icon(Icons.celebration),
          title: Text('¡Todos los hábitos están cumplidos!'),
        ),
      ];
    }

    return [
      for (final i in visibles)
        CheckboxListTile(
          value: _cumplidos[i],
          onChanged: (_) => _alternarHabito(i),
          controlAffinity: ListTileControlAffinity.leading,
          title: Text(
            _habitos[i],
            style: _cumplidos[i]
                ? const TextStyle(decoration: TextDecoration.lineThrough)
                : null,
          ),
        ),
    ];
  }

  Widget _construirNota() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _notaCtrl,
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(
            labelText: 'Nota del día',
            hintText: 'Ej.: Día productivo',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (_) => _guardarNota(),
        ),
        const SizedBox(height: 8),
        FilledButton.icon(
          onPressed: _campoNotaVacio ? null : _guardarNota,
          icon: const Icon(Icons.save),
          label: const Text('Guardar nota'),
        ),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: const Icon(Icons.sticky_note_2_outlined),
            title: Text(_nota.isEmpty ? 'Sin nota' : _nota),
          ),
        ),
      ],
    );
  }

  Widget _construirReinicio() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: _reiniciarDia,
          icon: const Icon(Icons.restart_alt),
          label: const Text('Reiniciar día'),
        ),
        const SizedBox(height: 8),
        Text(_textoHistorial, textAlign: TextAlign.center),
      ],
    );
  }
}
