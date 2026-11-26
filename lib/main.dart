import 'package:flutter/material.dart';
import 'login.dart';

void main() {
  runApp(const MyApp());
}

String formatTaskDate(DateTime date) {
  String day = date.day < 10 ? '0${date.day}' : '${date.day}';
  String month = date.month < 10 ? '0${date.month}' : '${date.month}';
  String year = '${date.year}';
  return '$day/$month/$year';
}

class TaskList {
  String name;
  DateTime? date;
  bool statusCompleted;

  TaskList({
    required this.name,
    this.date,
    this.statusCompleted = false,
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gerenciador de Tarefas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<TaskList> tasks = [];

  void orderTasks() {
    List<TaskList> pendingTasks = [];
    List<TaskList> completedTasks = [];

    for (int i = 0; i < tasks.length; i++) {
      if (tasks[i].statusCompleted) {
        completedTasks.add(tasks[i]);
      } else {
        pendingTasks.add(tasks[i]);
      }
    }

    tasks = [];
    tasks.addAll(pendingTasks);
    tasks.addAll(completedTasks);
  }

  Widget buildTaskCard(TaskList task) {
    return Card(
      key: ObjectKey(task),
      color: task.statusCompleted ? Colors.grey : Colors.blue[900],
      child: ListTile(
        title: Text(
          task.name,
          style: TextStyle(
            color: Colors.white,
            decoration: task.statusCompleted
                ? TextDecoration.lineThrough
                : TextDecoration.none,
          ),
        ),
        subtitle: task.date != null
            ? Text(
                'Data: ${formatTaskDate(task.date!)}',
                style: const TextStyle(
                  color: Colors.white70,
                ),
              )
            : null,
        trailing: Checkbox(
          value: task.statusCompleted,
          side: const BorderSide(color: Colors.white),
          onChanged: (value) {
            setState(() {
              task.statusCompleted = value!;
              orderTasks();
            });
          },
        ),
      ),
    );
  }

  List<Widget> buildTaskList() {
    List<Widget> items = [];

    for (int i = 0; i < tasks.length; i++) {
      if (!tasks[i].statusCompleted) {
        items.add(buildTaskCard(tasks[i]));
      }
    }

    bool hasCompleted = false;
    for (int i = 0; i < tasks.length; i++) {
      if (tasks[i].statusCompleted) {
        hasCompleted = true;
        break;
      }
    }

    if (hasCompleted) {
      items.add(
        const Padding(
          padding: EdgeInsets.all(8),
          child: Text(
            'Concluídas',
            style: TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );

      for (int i = 0; i < tasks.length; i++) {
        if (tasks[i].statusCompleted) {
          items.add(buildTaskCard(tasks[i]));
        }
      }
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: const Text(
          'Gerenciador de tarefas',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Roboto',
          ),
        ),
        backgroundColor: Colors.blue[900],
        centerTitle: true,
      ),

      body: tasks.isEmpty
          ? const Center(
              child: Text(
                'ADICIONE AS TAREFAS PARA INICIAR',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Roboto',
                ),
              ),
            )
          : ListView(
              children: buildTaskList(),
            ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return InputTask(
                onAddTask: (name, date) {
                  setState(() {
                    tasks.add(
                      TaskList(name: name, date: date),
                    );
                    orderTasks();
                  });
                },
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TaskDateCalendar extends StatefulWidget {
  final DateTime initialDate;
  final Function(DateTime) onDateSelected;

  const TaskDateCalendar({
    super.key,
    required this.initialDate,
    required this.onDateSelected,
  });

  @override
  State<TaskDateCalendar> createState() => _TaskDateCalendarState();
}

class _TaskDateCalendarState extends State<TaskDateCalendar> {
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Data selecionada: ${formatTaskDate(selectedDate)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blue[900],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 300,
          child: CalendarDatePicker(
            initialDate: selectedDate,
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
            onDateChanged: (date) {
              setState(() {
                selectedDate = date;
              });
              widget.onDateSelected(date);
            },
          ),
        ),
      ],
    );
  }
}

class InputTask extends StatefulWidget {
  final Function(String, DateTime) onAddTask;

  const InputTask({
    super.key,
    required this.onAddTask,
  });

  @override
  State<InputTask> createState() => _InputTaskState();
}

class _InputTaskState extends State<InputTask> {
  final TextEditingController controller = TextEditingController();
  DateTime selectedDate = DateTime.now();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: const Text('Nova tarefa'),

      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Digite uma tarefa:',
            ),
          ),
          const SizedBox(height: 16),
          TaskDateCalendar(
            initialDate: selectedDate,
            onDateSelected: (date) {
              setState(() {
                selectedDate = date;
              });
            },
          ),
        ],
      ),

      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancelar'),
        ),

        TextButton(
          onPressed: () {
            String name = controller.text.trim();

            if (name.isNotEmpty) {
              widget.onAddTask(name, selectedDate);
              Navigator.pop(context);
            }
          },
          child: const Text('Adicionar'),
        ),
      ],
    );
  }
}
