import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:todo/todo_provider.dart';

class AddTodo extends StatefulWidget {
  const AddTodo({Key? key}) : super(key: key);

  @override
  _AddTodoState createState() => _AddTodoState();
}

class _AddTodoState extends State<AddTodo> {
  bool isButtonActive = false;
  String? todoCardId;
  String? time;

  @override
  void initState() {
    super.initState();
    todoCardId = DateTime.now().toString();
    title = TextEditingController();
    // To make unclickeble button when title is empty in form
    title.addListener(() {
      final isButtonActive = title.text.isNotEmpty;
      setState(() {
        this.isButtonActive = isButtonActive;
      });
    });
  }

  DateTime? dateOfTodoCard;
  // Todocard datepicker
  todoCardDatePicker() async {
    final date = await showDatePicker(
        context: context,
        initialDate: dateOfTodoCard ?? DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 30)));
    if (date == null) return;
    setState(() {
      dateOfTodoCard = date;
    });
  }

  // Todo timepicker
  timePicker() async {
    TimeOfDay? newtime =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (newtime == null) {
      return;
    } else {
      setState(() {
        time =
            '${newtime.hourOfPeriod}:${newtime.minute} ${newtime.period.name}';
      });
    }
  }

  TextEditingController title = TextEditingController();
  List<TODO> todos = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: const Text('Add Todo'),
        actions: [
          // ElevatedButton used to Create TodoCard
          ElevatedButton.icon(
              onPressed: () {
                if (dateOfTodoCard == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Pick Date of TodoCard Please...')));
                  return;
                }
                if (todos.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Please add atleast 1 TODO...')));
                  return;
                }
                // Passing Data using Provider
                Provider.of<TodoListsProvider>(context, listen: false)
                    .createTodoCard(
                        todos,
                        context,
                        TODOcard(
                            userId: FirebaseAuth.instance.currentUser!.uid,
                            todoCardId: todoCardId!,
                            date: dateOfTodoCard!));
                Navigator.pop(context);
              },
              icon: const Icon(Icons.check),
              label: const Text('CREATE'))
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(dateOfTodoCard == null
                      ? 'Select Date of TodoCard'
                      : DateFormat.yMMMd().format(dateOfTodoCard!)),
                  ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.blue),
                      ),
                      onPressed: todoCardDatePicker,
                      child: const Text('Pick Date'))
                ],
              ),
            ),
            ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: todos.map((TODO todo) {
                  return Container(
                      padding: const EdgeInsets.fromLTRB(3, 3, 0, 3),
                      margin: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(15)),
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              todo.title,
                              style: const TextStyle(
                                  color: Colors.blue,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                              overflow: TextOverflow.fade,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                todo.time,
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.fade,
                              ),
                              Checkbox(
                                  value: todo.isCompleted,
                                  onChanged: (value) {
                                    setState(() {
                                      todo.isCompleted = value!;
                                    });
                                  }),
                            ],
                          )
                        ],
                      ));
                }).followedBy([
                  // to make Todos length limit is to 5
                  if (todos.length < 5) 
                  Container(
                    padding: const EdgeInsets.all(5),
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Flexible(
                                child: TextField(
                              maxLength: 35,
                              decoration: const InputDecoration(
                                  label: Text('Title'),
                                  labelStyle: TextStyle(fontSize: 22)),
                              controller: title,
                            )),
                            ElevatedButton.icon(
                                icon: const Icon(Icons.timer),
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all(Colors.blue),
                                ),
                                onPressed: timePicker,
                                label: Text(time == null ? 'PickTime' : time!)),
                          ],
                        ),
                        ElevatedButton(
                            onPressed: isButtonActive
                                ? () {
                                    if (time == null) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content:
                                                  Text('Pick Time Please...')));
                                      return;
                                    }
                                    todos.add(TODO(
                                        id: DateTime.now().toString(),
                                        todoCardId: todoCardId!,
                                        title: title.text,
                                        time: time!,
                                        isCompleted: false));
                                    setState(() {
                                      time = null;
                                      title.clear();
                                      isButtonActive = false;
                                    });
                                  }
                                : null,
                            child: const Text('Add Todo'))
                      ],
                    ),
                  )
                ]).toList()),
          ],
        ),
      ),
    );
  }
}
