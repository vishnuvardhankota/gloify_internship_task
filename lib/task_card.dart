import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:todo/todo_provider.dart';

class TodoCard extends StatefulWidget {
  final String todoCardId;
  final DateTime taskDate;
  const TodoCard({Key? key, required this.todoCardId, required this.taskDate})
      : super(key: key);

  @override
  State<TodoCard> createState() => _TodoCardState();
}

class _TodoCardState extends State<TodoCard> {
  @override
  Widget build(BuildContext context) {
    // converting datetime to Text
    String date = DateFormat.yMMMd().format(widget.taskDate);
    // get data From list of Todos in local by using Provider
    final todos = Provider.of<TodoListsProvider>(context)
        .todosByTodoCardId(widget.todoCardId);
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 3),
      padding: const EdgeInsets.only(top: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Text(
              date,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
          Card(
            elevation: 5,
            child: Dismissible(
              key: ValueKey(widget.todoCardId),
              background: Container(
                color: Theme.of(context).errorColor,
                child: const Icon(
                  Icons.delete,
                  color: Colors.white,
                  size: 40,
                ),
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.all(20),
              ),
              direction: DismissDirection.endToStart,
              confirmDismiss: (direction) {
                return showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                          title: const Text('Are You Sure'),
                          content: const Text('Do you want to Delete Note?'),
                          actions: [
                            TextButton(
                              child: const Text('No'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                                child: const Text('Yes'),
                                onPressed: () {
                                  Provider.of<TodoListsProvider>(context,
                                          listen: false)
                                      .deleteTodos(context, widget.todoCardId);
                                  Navigator.of(context).pop();
                                }),
                          ],
                        ));
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.only(left: 8),
                child: Column(
                  children: todos.map((todo) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            todo.title,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 16,
                            ),
                            overflow: TextOverflow.fade,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              todo.time,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.fade,
                            ),
                            Checkbox(
                                value: todo.isCompleted,
                                onChanged: (value) {
                                  FirebaseFirestore.instance
                                      .collection('TODOcards')
                                      .doc(widget.todoCardId)
                                      .collection('TODOs')
                                      .doc(todo.id)
                                      .update({'isCompleted': value});
                                }),
                          ],
                        )
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
