import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:taskly/models/task.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _HomePage();
  }
}

class _HomePage extends State<HomePage> {
  _HomePage();
  late double _deviceHeight, _deviceWidth;
  String? newTaskContent;
  Box? _box;

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    print('new task content is : $newTaskContent');
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: _deviceHeight * .15,
        title: const Text(
          'Taskly',
          style: TextStyle(fontSize: 25),
        ),
      ),
      body: _tasksView(),
      floatingActionButton: _addTaskButton(),
    );
  }

  Widget _tasksView() {
    return FutureBuilder(
      future: Hive.openBox('boxes'),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          _box = snapshot.data;
          return _taskList();
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _taskList() {
    // Task newTask =
    //     Task(content: "Sleep", timestamp: DateTime.now(), isDone: true);

    // _box?.add(newTask.toMap());
    List tasks = _box!.values.toList();

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: tasks.length,
      itemBuilder: (BuildContext context, int index) {
        var task = Task.fromMap(tasks[index]);
        return ListTile(
          title: Text(
            task.content,
            style: TextStyle(
                decoration: task.isDone ? TextDecoration.lineThrough : null),
          ),
          subtitle: Text(task.timestamp.toString().split('.')[0]),
          trailing: Icon(
            task.isDone
                ? Icons.check_circle_outline
                : Icons.radio_button_unchecked_rounded,
            color: Colors.purple,
          ),
          onTap: () {
            task.isDone = !task.isDone;
            _box?.putAt(index, task.toMap());
            setState(() {});
          },
          onLongPress: () {
            _box?.deleteAt(index);
            setState(() {});
          },
        );
      },
    );

    // return ListView(
    //   children: [
    //     ListTile(
    //       title: const Text(
    //         'Do Luandry!',
    //         style: TextStyle(decoration: TextDecoration.lineThrough),
    //       ),
    //       subtitle: Text(DateTime.now().toString()),
    //       trailing: const Icon(
    //         Icons.check_circle_outline,
    //         color: Colors.purple,
    //       ),
    //     ),
    //   ],
    // );
  }

  Widget _addTaskButton() {
    return FloatingActionButton(
      onPressed: _displayTaskPopup,
      child: const Icon(Icons.add),
    );
  }

  void _displayTaskPopup() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Add New Task!'),
            content: TextField(
              onSubmitted: (_) {
                if (newTaskContent != null) {
                  Task newTask = Task(
                      content: newTaskContent!,
                      timestamp: DateTime.now(),
                      isDone: false);
                  _box!.add(newTask.toMap());
                  setState(() {
                    newTaskContent = null;
                    Navigator.pop(context);
                  });
                }
              },
              onChanged: (value) {
                setState(() {
                  newTaskContent = value;
                });
              },
            ),
          );
        });
  }
}
