import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TaskFlowApp());
}

const Color ink = Color(0xFF211B3A);
const Color purple = Color(0xFF7657F6);
const Color lavender = Color(0xFFEDE8FF);
const Color mint = Color(0xFFBFF3D5);
const Color canvas = Color(0xFFF7F5FC);

class TaskItem {
  TaskItem({
    required this.id,
    required this.title,
    required this.dateKey,
    this.done = false,
  });

  final String id;
  final String title;
  final String dateKey;
  bool done;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'dateKey': dateKey,
    'done': done,
  };

  factory TaskItem.fromJson(Map<String, dynamic> json) => TaskItem(
    id: json['id'] as String,
    title: json['title'] as String,
    dateKey: json['dateKey'] as String,
    done: json['done'] as bool? ?? false,
  );
}

String dateKey(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';

class TaskFlowApp extends StatelessWidget {
  const TaskFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaskFlow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: canvas,
        colorScheme: ColorScheme.fromSeed(seedColor: purple),
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: canvas,
          foregroundColor: ink,
          elevation: 0,
        ),
      ),
      home: const AuthScreen(),
    );
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _register = false;
  bool _obscure = true;
  String? _registeredEmail;
  String? _registeredPassword;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    final email = _email.text.trim();
    final password = _password.text;
    if (_register) {
      if (_name.text.trim().isEmpty || email.isEmpty || password.length < 4) {
        _message('Preencha seu nome, e-mail e uma senha com pelo menos 4 caracteres.');
        return;
      }
      _registeredEmail = email;
      _registeredPassword = password;
      setState(() => _register = false);
      _message('Cadastro realizado! Agora entre com seus dados.');
      _password.clear();
      return;
    }
    if (email.isEmpty || password.isEmpty) {
      _message('Informe seu e-mail e sua senha.');
      return;
    }
    // Autenticação demonstrativa, sem servidor ou Firebase.
    if (_registeredEmail != null &&
        (email != _registeredEmail || password != _registeredPassword)) {
      _message('Dados diferentes do cadastro realizado nesta sessão.');
      return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => HomeScreen(userName: _name.text.trim().isEmpty ? 'Você' : _name.text.trim())),
    );
  }

  void _message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  InputDecoration _decoration(String label, IconData icon) => InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon, color: purple),
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide.none,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6D50EF), Color(0xFF9A7BFF), Color(0xFFB6A4FF)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 22),
                    Container(
                      height: 88,
                      width: 88,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.18),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: Colors.white.withOpacity(.35)),
                      ),
                      child: const Icon(Icons.check_rounded, size: 54, color: Colors.white),
                    ),
                    const SizedBox(height: 22),
                    const Text('taskflow', textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.w900, letterSpacing: -1.5)),
                    const SizedBox(height: 8),
                    Text(_register ? 'Crie sua conta e organize seus dias.' : 'Um dia de cada vez. Uma tarefa de cada vez.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white.withOpacity(.9), fontSize: 15)),
                    const SizedBox(height: 34),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: canvas,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [BoxShadow(color: ink.withOpacity(.16), blurRadius: 30, offset: const Offset(0, 16))],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(_register ? 'Criar conta' : 'Bem-vinda de volta!',
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: ink)),
                          const SizedBox(height: 6),
                          Text(_register ? 'É rápido e gratuito.' : 'Entre para acessar seu planejamento.',
                              style: const TextStyle(color: Colors.black54)),
                          const SizedBox(height: 22),
                          if (_register) ...[
                            TextField(controller: _name, decoration: _decoration('Seu nome', Icons.person_outline)),
                            const SizedBox(height: 14),
                          ],
                          TextField(
                            controller: _email,
                            keyboardType: TextInputType.emailAddress,
                            decoration: _decoration('E-mail', Icons.mail_outline),
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: _password,
                            obscureText: _obscure,
                            decoration: _decoration('Senha', Icons.lock_outline).copyWith(
                              suffixIcon: IconButton(
                                onPressed: () => setState(() => _obscure = !_obscure),
                                icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                              ),
                            ),
                          ),
                          const SizedBox(height: 22),
                          FilledButton(
                            onPressed: _submit,
                            style: FilledButton.styleFrom(
                              backgroundColor: purple,
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(54),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
                            ),
                            child: Text(_register ? 'CRIAR MINHA CONTA' : 'ENTRAR',
                                style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: .7)),
                          ),
                          const SizedBox(height: 14),
                          TextButton(
                            onPressed: () => setState(() => _register = !_register),
                            child: Text(_register ? 'Já tenho uma conta · Fazer login' : 'Ainda não tem conta? Cadastre-se',
                                style: const TextStyle(color: purple, fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('ORGANIZE • CONCLUA • CELEBRE',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white.withOpacity(.85), fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.userName});
  final String userName;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _selected = DateTime.now();
  DateTime _visibleMonth = DateTime(DateTime.now().year, DateTime.now().month);
  final List<TaskItem> _tasks = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('taskflow_tasks');
    if (raw != null) {
      try {
        final decoded = jsonDecode(raw) as List<dynamic>;
        _tasks.addAll(decoded.map((e) => TaskItem.fromJson(Map<String, dynamic>.from(e as Map))));
      } catch (_) {
        // Se os dados locais estiverem inválidos, o app inicia com uma lista vazia.
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('taskflow_tasks', jsonEncode(_tasks.map((e) => e.toJson()).toList()));
  }

  List<TaskItem> get _dayTasks {
    final list = _tasks.where((task) => task.dateKey == dateKey(_selected)).toList();
    list.sort((a, b) {
      if (a.done != b.done) return a.done ? 1 : -1;
      return a.title.toLowerCase().compareTo(b.title.toLowerCase());
    });
    return list;
  }

  int _countFor(DateTime day) =>
      _tasks.where((task) => task.dateKey == dateKey(day)).length;

  int _completedFor(DateTime day) =>
      _tasks.where((task) => task.dateKey == dateKey(day) && task.done).length;

  Future<void> _addTask(String title) async {
    setState(() {
      _tasks.add(TaskItem(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: title.trim(),
        dateKey: dateKey(_selected),
      ));
    });
    await _saveTasks();
  }

  Future<void> _toggleTask(TaskItem task, bool? value) async {
    setState(() => task.done = value ?? false);
    await _saveTasks();
  }

  Future<void> _deleteTask(TaskItem task) async {
    setState(() => _tasks.removeWhere((item) => item.id == task.id));
    await _saveTasks();
  }

  Future<void> _showAddDialog() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Nova tarefa', style: TextStyle(fontWeight: FontWeight.w800, color: ink)),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 70,
          decoration: InputDecoration(
            hintText: 'Ex.: Organizar meus estudos',
            filled: true,
            fillColor: canvas,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          ),
          onSubmitted: (value) => Navigator.pop(dialogContext, value),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: purple),
            onPressed: () => Navigator.pop(dialogContext, controller.text),
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
    if (result != null && result.trim().isNotEmpty) await _addTask(result);
    controller.dispose();
  }

  void _changeMonth(int amount) {
    setState(() => _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + amount));
  }

  @override
  Widget build(BuildContext context) {
    final tasks = _dayTasks;
    final pending = tasks.where((task) => !task.done).length;
    final completed = tasks.length - pending;

    return Scaffold(
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: purple))
            : CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 12),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('OLÁ, ${widget.userName.toUpperCase()} 👋',
                            style: const TextStyle(color: purple, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.3)),
                        const SizedBox(height: 5),
                        const Text('Seu dia, do seu jeito.', style: TextStyle(color: ink, fontSize: 25, fontWeight: FontWeight.w900, letterSpacing: -.8)),
                      ]),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: lavender, borderRadius: BorderRadius.circular(17)),
                      child: const Icon(Icons.auto_awesome_rounded, color: purple, size: 25),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(child: _calendarCard()),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(22, 24, 22, 10),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    const Expanded(child: Text('Minhas tarefas', style: TextStyle(fontSize: 22, color: ink, fontWeight: FontWeight.w900))),
                    Text('${tasks.length} no total', style: const TextStyle(color: Colors.black45, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    _statPill('$pending pendentes', const Color(0xFFFFE6B8), const Color(0xFF8A5600)),
                    const SizedBox(width: 8),
                    _statPill('$completed concluídas', mint, const Color(0xFF17623C)),
                  ],
                ),
              ),
            ),
            if (tasks.isEmpty)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(22, 24, 22, 120),
                sliver: SliverToBoxAdapter(child: _emptyState()),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(22, 14, 22, 110),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) => _taskTile(tasks[index]),
                    childCount: tasks.length,
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        backgroundColor: purple,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nova tarefa', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
    );
  }

  Widget _calendarCard() {
    final first = DateTime(_visibleMonth.year, _visibleMonth.month, 1);
    final days = DateTime(_visibleMonth.year, _visibleMonth.month + 1, 0).day;
    final leading = (first.weekday % 7); // Domingo = primeira coluna.
    final cells = ((leading + days + 6) ~/ 7) * 7;
    const weekDays = ['D', 'S', 'T', 'Q', 'Q', 'S', 'S'];

    return Container(
      padding: const EdgeInsets.fromLTRB(17, 17, 17, 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(27),
        boxShadow: [BoxShadow(color: purple.withOpacity(.07), blurRadius: 24, offset: const Offset(0, 9))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(child: Text('CALENDÁRIO', style: TextStyle(color: purple, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5))),
              IconButton(onPressed: () => _changeMonth(-1), icon: const Icon(Icons.chevron_left_rounded), visualDensity: VisualDensity.compact),
              Text('${_monthName(_visibleMonth.month)} ${_visibleMonth.year}',
                  style: const TextStyle(color: ink, fontWeight: FontWeight.w900, fontSize: 15)),
              IconButton(onPressed: () => _changeMonth(1), icon: const Icon(Icons.chevron_right_rounded), visualDensity: VisualDensity.compact),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: weekDays.map((d) => Expanded(
              child: Center(child: Text(d, style: const TextStyle(color: Colors.black38, fontWeight: FontWeight.w800, fontSize: 11))),
            )).toList(),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: cells,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, mainAxisSpacing: 5, crossAxisSpacing: 4),
            itemBuilder: (context, index) {
              final dayNumber = index - leading + 1;
              if (dayNumber < 1 || dayNumber > days) return const SizedBox();
              final day = DateTime(_visibleMonth.year, _visibleMonth.month, dayNumber);
              final selected = dateKey(day) == dateKey(_selected);
              final today = dateKey(day) == dateKey(DateTime.now());
              final count = _countFor(day);
              return InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => setState(() => _selected = day),
                child: Container(
                  decoration: BoxDecoration(
                    color: selected ? purple : (today ? lavender : Colors.transparent),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('$dayNumber', style: TextStyle(
                        color: selected ? Colors.white : ink,
                        fontWeight: selected || today ? FontWeight.w900 : FontWeight.w600,
                        fontSize: 13,
                      )),
                      const SizedBox(height: 3),
                      Container(
                        height: 4,
                        width: 4,
                        decoration: BoxDecoration(
                          color: count == 0 ? Colors.transparent : (selected ? mint : purple),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.circle, size: 7, color: purple),
              const SizedBox(width: 6),
              const Text('Dias com tarefas', style: TextStyle(fontSize: 11, color: Colors.black45)),
              const Spacer(),
              Text('${_selected.day} de ${_monthName(_selected.month)}',
                  style: const TextStyle(fontSize: 11, color: purple, fontWeight: FontWeight.w800)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statPill(String text, Color bg, Color fg) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(30)),
    child: Text(text, style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w800)),
  );

  Widget _taskTile(TaskItem task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: task.done ? mint : const Color(0xFFECE8F7)),
      ),
      child: Row(
        children: [
          Checkbox(
            value: task.done,
            activeColor: const Color(0xFF38A66B),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            onChanged: (value) => _toggleTask(task, value),
          ),
          Expanded(
            child: Text(task.title,
              style: TextStyle(
                color: task.done ? Colors.black38 : ink,
                fontWeight: FontWeight.w700,
                decoration: task.done ? TextDecoration.lineThrough : TextDecoration.none,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Excluir tarefa',
            onPressed: () => _deleteTask(task),
            icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFB4AFC2)),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() => Container(
    padding: const EdgeInsets.all(25),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
    child: Column(
      children: [
        Container(
          padding: const EdgeInsets.all(17),
          decoration: const BoxDecoration(color: lavender, shape: BoxShape.circle),
          child: const Icon(Icons.event_note_rounded, color: purple, size: 32),
        ),
        const SizedBox(height: 12),
        const Text('Tudo pronto para começar?', style: TextStyle(color: ink, fontWeight: FontWeight.w900, fontSize: 16)),
        const SizedBox(height: 5),
        const Text('Adicione uma tarefa para este dia e acompanhe seu progresso por aqui.',
            textAlign: TextAlign.center, style: TextStyle(color: Colors.black45, height: 1.4)),
      ],
    ),
  );

  String _monthName(int month) {
    const names = ['janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho',
      'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro'];
    return names[month - 1];
  }
}
