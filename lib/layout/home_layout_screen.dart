import 'dart:ffi';

import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:to_do_list/modules/archive_taskes/archive_taskes_screen.dart';
import 'package:to_do_list/modules/done_taskes/done_taskes_screen.dart';
import 'package:to_do_list/modules/new_taskes/new_taskes_screen.dart';
import 'package:to_do_list/shared/components/components.dart';
import 'package:to_do_list/shared/cubit/cubit.dart';
import 'package:to_do_list/shared/cubit/states.dart';

import '../shared/components/constants.dart';



class HomeLayout extends StatelessWidget {


  var scaffoldKey = GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();
  var tittleController= TextEditingController();
  var timeController= TextEditingController();
  var dateController= TextEditingController();
  var emailController= TextEditingController();




  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context)=> AppCubit()..createDatabase(),
      child: BlocConsumer<AppCubit, AppStates>(
        listener: (context, state){
          if(state is AppInsertDatabaseState){
            Navigator.pop(context);
          }
        },
        builder: (context, state){
          AppCubit cubit = AppCubit.get(context);

          return Scaffold(
            key: scaffoldKey,
            appBar: AppBar(
              title: Text(
                cubit.title[cubit.currentIndex],
              ),
            ),
            body: ConditionalBuilder(
              condition: state is! AppGetDatabaseLoadingState,
              builder: (context)=> cubit.screens[cubit.currentIndex],
              fallback: (context)=>Center(child: CircularProgressIndicator()),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                if(cubit.isBottomSheet)
                {
                  if (formKey.currentState.validate())
                  {
                    cubit.insertToDatabase(
                        title: tittleController.text,
                        time: timeController.text,
                        date: dateController.text,
                    );

                    // insertToDatabase(
                    //   date: dateController.text ,
                    //   time: timeController.text,
                    //   title: tittleController.text,
                    // ).then((value) {
                    //   getDataFromDatabase(database).then((value) {
                    //     Navigator.pop(context);
                    //     // setState(() {
                    //     //
                    //     //   isBottomSheet=false;
                    //     //   fabIcon=Icons.edit;
                    //     //   tasks = value;
                    //     // });
                    //
                    //   });
                    //
                    // });

                  }

                }
                else
                {
                  scaffoldKey.currentState.showBottomSheet(
                          (context)=> Container(
                        color: Colors.white,
                        padding: EdgeInsets.all(20.0,),
                        child: Form(
                          key: formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextFormField(

                              ),
                              defaultFormField(
                                controller: tittleController,
                                type: TextInputType.text,
                                validate: (String value)
                                {
                                  if(value.isEmpty)
                                  {
                                    return 'title must not be empty';
                                  }
                                  return null;
                                },
                                label: 'Task Title',
                                prefix: Icons.title,
                              ),
                              const SizedBox(
                                height: 15.0,
                              ),
                              defaultFormField(
                                controller: timeController,
                                type: TextInputType.datetime,
                                onTap: (){
                                  showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.now(),
                                  ).then((value){
                                    timeController.text = value.format(context).toString();
                                  });
                                },
                                validate: (String value){
                                  if( value.isEmpty){
                                    return 'time must not be empty';
                                  }
                                  return null;
                                },
                                label: 'Task Time',
                                prefix: Icons.watch_later_outlined,
                              ),
                              const SizedBox(
                                height: 15.0,
                              ),
                              defaultFormField(
                                controller: dateController,
                                type: TextInputType.datetime,
                                onTap: (){
                                  showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime.parse('2023-09-07'),
                                  ).then((value) {
                                    dateController.text= DateFormat.yMMMd().format(value);
                                  });
                                },
                                validate: (String value){
                                  if( value.isEmpty){
                                    return 'date must not be empty';
                                  }
                                  return null;
                                },
                                label: 'Task Date',
                                prefix: Icons.calendar_today,
                              ),
                            ],
                          ),
                        ),
                      ),
                      elevation: 20.0
                  ).closed.then((value) {
                    cubit.changeBottomSheetState(
                        isShow: false,
                        icon: Icons.edit);
                  });
                  cubit.changeBottomSheetState(
                      isShow: true,
                      icon: Icons.add);
                }
              },
              child: Icon(
                cubit.fabIcon,
              ),
            ),
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: cubit.currentIndex,
              onTap: (index){
                cubit.changeIndex(index);
              },
              items: [
                BottomNavigationBarItem(
                  icon: Icon(
                      Icons.menu
                  ),
                  label: 'Taskes',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                      Icons.check_circle_outline
                  ),
                  label: 'Done',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                      Icons.archive_outlined
                  ),
                  label: 'Archive',
                ),
              ],
            ),
          );
        },

      ),
    );
  }



}


