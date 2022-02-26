import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Todo model
class TODO {
  String id;
  String todoCardId;
  String title;
  String time;
  bool isCompleted;

  TODO({
    required this.id,
    required this.todoCardId,
    required this.title,
    required this.time,
    required this.isCompleted,
  });
}
// Todocard model
class TODOcard {
  String userId;
  String todoCardId;
  DateTime date;
  TODOcard({
    required this.userId,
    required this.todoCardId,
    required this.date,
  });
}

class TodoListsProvider with ChangeNotifier {
  // Todos lists
  List<TODO> todos = [];
  List<TODO> get alltodos {
    return [...todos];
  }
  // Todocard lists
  List<TODOcard> tasks = [];
  List<TODOcard> get alltasks {
    return [...tasks];
  }

  List<TODO> todosByTodoCardId(String todoCardId) {
    return alltodos.where((todo) => todo.todoCardId == todoCardId).toList();
  }
  // Creating Todo card and adding Todos to Firebase server
  Future<void> createTodoCard(
      List<TODO> todoLists, BuildContext context, TODOcard todoCard) async {
    try {
      await FirebaseFirestore.instance
          .collection('TODOcards')
          .doc(todoCard.todoCardId)
          .set({
        'userId': todoCard.userId,
        'todoCardId': todoCard.todoCardId,
        'date': todoCard.date
      }).then((value) {
        int i = 1;
        for (var todo in todoLists) {
          // ignore: void_checks
          value = i / todoLists.length;
          FirebaseFirestore.instance.collection('TODOcards').doc(todoCard.todoCardId).collection('TODOs').doc(todo.id).set({
            'id': todo.id,
            'todoCardId': todo.todoCardId,
            'title': todo.title,
            'time': todo.time,
            'isCompleted': todo.isCompleted
          });
          i++;
        }
      });
    } on PlatformException catch (error) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar(reason: SnackBarClosedReason.remove)
        ..showSnackBar(SnackBar(
          content: Text(error.code),
          backgroundColor: Theme.of(context).errorColor,
        ));
      return;
    } on FirebaseException catch (error) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar(reason: SnackBarClosedReason.remove)
        ..showSnackBar(SnackBar(
          content: Text(error.code),
          backgroundColor: Theme.of(context).errorColor,
        ));
      return;
    }
    notifyListeners();
  }
  // Getting Todo cards and Todos based on todocard id from Firebase Server
  Future<void> getTodoCards(BuildContext context) async {
    try {
      final List<TODOcard> myTodoCards = [];
      final List<TODO> myTodos = [];
  await FirebaseFirestore.instance
          .collection('TODOcards')
          .get()
          .then(
              // ignore: avoid_function_literals_in_foreach_calls
              (QuerySnapshot taskSnapshot) => taskSnapshot.docs.forEach((data) {
                    return myTodoCards.add(TODOcard(
                        userId: data['userId'],
                        todoCardId: data['todoCardId'],
                        date: DateTime.fromMillisecondsSinceEpoch(
                            data['date'].seconds * 1000)));
                  }))
          .then((value) async {
        int i = 1;
        for (var todoCard in myTodoCards) {
          // ignore: void_checks
          value = i / myTodoCards.length;
          await FirebaseFirestore.instance
          .collection('TODOcards').doc(todoCard.todoCardId)
              .collection('TODOs')
              .get()
              .then((QuerySnapshot todoSnapshot) =>
                  // ignore: avoid_function_literals_in_foreach_calls
                  todoSnapshot.docs.forEach((data) {
                    return myTodos.add(TODO(
                        id: data['id'],
                        todoCardId: data['todoCardId'],
                        title: data['title'],
                        time: data['time'],
                        isCompleted: data['isCompleted']));
                  }));
          i++;
        }
      });
      tasks = myTodoCards;
      todos = myTodos;
    } on FirebaseException catch (error) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar(reason: SnackBarClosedReason.remove)
        ..showSnackBar(SnackBar(
          content: Text(error.code),
          backgroundColor: Theme.of(context).errorColor,
        ));
      return;
    }
    notifyListeners();
  }

  Future<void> deleteTodos(BuildContext context, String todoCardId) async {
    try {
      await FirebaseFirestore.instance
          .collection('TODOcards')
          .doc(todoCardId)
          .delete();
    } on FirebaseException catch (error) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar(reason: SnackBarClosedReason.remove)
        ..showSnackBar(SnackBar(
          content: Text(error.code),
          backgroundColor: Theme.of(context).errorColor,
        ));
      return;
    }
    notifyListeners();
  }
}
