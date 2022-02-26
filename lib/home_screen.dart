import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo/add_todo.dart';
import 'package:todo/auth_screen.dart';
import 'package:todo/task_card.dart';
import 'package:todo/todo_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  // Sending request to get data from Firebase server
  @override
  void didChangeDependencies() {
    Provider.of<TodoListsProvider>(context).getTodoCards(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    // get data From list of TodoCards in local by using Provider
    final todoCards = Provider.of<TodoListsProvider>(context).alltasks;
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: const Text('TODO APP'),
        actions: [
          IconButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const AuthScreen()),
                    (route) => false);
              },
              icon: const Icon(Icons.logout))
        ],
      ),
      // To create Todocard and to add new Todos
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const AddTodo()));
        },
      ),
      body: todoCards.isEmpty
          ? const Center(
              child: Text('Add Todos'),
            )
          : Column(
              children: todoCards.map((todoCard) {
                return TodoCard(
                  todoCardId: todoCard.todoCardId, taskDate: todoCard.date,
                );
              }).toList(),
            ),
    );
  }
}
