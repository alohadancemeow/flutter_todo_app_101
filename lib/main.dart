import 'package:flutter/material.dart';
import 'package:flutter_application_1/Todo_Item.dart';
import 'package:flutter_application_1/add_todo_page.dart';
import 'package:flutter_application_1/todo_provider.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        textTheme: GoogleFonts.jetBrainsMonoTextTheme(),
        appBarTheme: const AppBarTheme(foregroundColor: Color(0xFFFFFFFF)),
      ),
      home: const MyHomePage(title: 'My todo app'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TodoProvider todoProvider = TodoProvider.instance;

  // fetch todos
  Future<List<TodoItem>> _fecthTodos() async {
    return await todoProvider.fetchTodos();
  }

  // push to addTodoPage
  void _onFabCliked() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const AddTodoPage()))
        .then((value) => setState(() {}));
  }

  // handle update check
  void _onCheckValueChanged(bool isChecked, TodoItem item) async {
    TodoItem newItem = TodoItem(item.id, item.title, item.notes, isChecked);
    await todoProvider.updateTodo(newItem);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FutureBuilder<List<TodoItem>>(
          future: _fecthTodos(),
          builder:
              (BuildContext context, AsyncSnapshot<List<TodoItem>> snapshot) {
            if (snapshot.hasData) {
              List<TodoItem> items = snapshot.data ?? [];

              return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    var todoItem = items[index];

                    return Dismissible(
                        key: UniqueKey(),
                        direction: DismissDirection.endToStart,
                        background: Container(),
                        secondaryBackground: Container(color: Colors.red),
                        onDismissed: (direction) {
                          setState(() {
                            todoProvider.deleteTodo(todoItem);
                          });
                        },
                        child: ListTile(
                          title: Text(todoItem.title),
                          subtitle: Text(todoItem.notes),
                          leading: Checkbox(
                              value: todoItem.done,
                              onChanged: (value) => _onCheckValueChanged(
                                  value ?? false, todoItem)),
                        ));
                  });
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: _onFabCliked,
        tooltip: 'add todo',
        child: const Icon(Icons.add),
      ),
    );
  }
}
