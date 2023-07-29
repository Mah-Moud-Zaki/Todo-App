import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:to_do_list/shared/cubit/states.dart';

import '../../modules/archive_taskes/archive_taskes_screen.dart';
import '../../modules/done_taskes/done_taskes_screen.dart';
import '../../modules/new_taskes/new_taskes_screen.dart';

class AppCubit extends Cubit<AppStates>{
  AppCubit() : super(AppInitialState());

  static AppCubit get(context) => BlocProvider.of(context);

  int currentIndex =0;
  List<Widget> screens = [
    NewTaskes(),
    DoneTasks(),
    ArchiveTasks(),
  ];

  List<String> title = [
    'New Tasks',
    'Done Tasks',
    'Archive Tasks',
  ];

  void changeIndex(int index){
    currentIndex = index;
    emit(AppChangeBottomNavBarState());
  }

  Database database;
  List<Map> newTasks =[];
  List<Map> doneTasks =[];
  List<Map> archiveTasks =[];

  void createDatabase()
  {
     openDatabase(
      'todo.db',
      version: 1,
      onCreate: (database, version){
        print('database created');
        database.execute('CREATE TABLE TASKS (id INTEGER PRIMARY KEY, title TEXT, date TEXT, time TEXT, status TEXT)')
            .then((value){
          print('table created');
        }).catchError((error){
          print('error is ${error.toString()}');
        });
      },
      onOpen: (database){
        getDataFromDatabase(database);
        print('open database');
      },
    ).then((value) {
      database = value;
      emit(AppCreateDatabaseState());
     });
  }

   insertToDatabase({
    @required String title,
    @required String time,
    @required String date,
  }) async
  {
    await database.transaction((txn)
    {
      return txn.rawInsert('INSERT INTO TASKS (title, date, time, status) VALUES("$title","$date", "$time", "new")',
      )
          .then((value){
        print('$value insert successfully');
        emit(AppInsertDatabaseState());
        getDataFromDatabase(database);
      }).catchError((error){
        print('error when insert ${error.toString()}');
      });
    });
  }

  void getDataFromDatabase(database){

    newTasks=[];
    doneTasks = [];
    archiveTasks = [];

    emit(AppGetDatabaseLoadingState());
      database.rawQuery('SELECT * FROM TASKS').then((value) {

        value.forEach((element) {
          if(element['status']=='new')
            newTasks.add(element);
          else if(element['status']=='done')
            doneTasks.add(element);
          else archiveTasks.add(element);
        });

        emit(AppGetDatabaseState());
      });

  }

  void updateData({
    @required String status,
    @required int id,
}) async{
     database.rawUpdate(
        'UPDATE TASKS SET status = ? WHERE id = ?',
        ['$status',id]
    ).then((value) {
       getDataFromDatabase(database);
      emit(AppUpdateDatabaseState());
     });

  }

  void deleteData({
    @required int id,
  }) async{
    database.rawDelete('DELETE FROM TASKS WHERE id = ?', [id])
        .then((value) {
      getDataFromDatabase(database);
      emit(AppDeleteDatabaseState());
    });

  }

  bool isBottomSheet= false;
  IconData fabIcon= Icons.edit;

  void changeBottomSheetState({
    @required bool isShow,
    @required IconData icon,
}){
    isBottomSheet = isShow;
    fabIcon = icon;
    emit(AppChangeBottomSheetState());
  }

}