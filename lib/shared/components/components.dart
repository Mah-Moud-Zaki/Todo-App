import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:to_do_list/shared/cubit/cubit.dart';

Widget defaultFormField(
        {@required TextEditingController controller,
        @required TextInputType type,
        Function onSubmit,
        Function onChange,
        Function onTap,
        bool isPassword = false,
        @required Function validate,
        @required String label,
        @required IconData prefix,
        IconData suffix,
        Function suffixPressed,
        bool isClickable = true}) =>
    TextFormField(
      controller: controller,
      keyboardType: type,
      onFieldSubmitted: (s) {
        onSubmit(s);
      },
      obscureText: isPassword,
      onChanged: (s) {
        onChange(s);
      },
      validator: validate,
      enabled: isClickable,
      onTap: () {
        onTap();
      },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          prefix,
        ),
        suffixIcon: suffix != null ? Icon(suffix) : null,
        border: OutlineInputBorder(),
      ),
    );

Widget buildTaskItem(Map model, context) => Dismissible(
  key: Key(model['id'].toString()),
  child:   Padding(

        padding: const EdgeInsets.all(20.0),

        child: Row(

          children: [

            CircleAvatar(

              radius: 35.5,

              child: Text(

                '${model['time']}',

              ),

            ),

            SizedBox(

              width: 20.0,

            ),

            Expanded(

              child: Column(

                mainAxisSize: MainAxisSize.min,

                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  Text(

                    '${model['title']}',

                    style: TextStyle(

                      fontSize: 18.0,

                      fontWeight: FontWeight.bold,

                    ),

                  ),

                  Text(

                    '${model['date']}',

                    style: TextStyle(color: Colors.grey),

                  ),

                ],

              ),

            ),

            SizedBox(

              width: 20.0,

            ),

            IconButton(

              onPressed: () {

                AppCubit.get(context).updateData(

                    status: 'done',

                    id: model['id'],

                );

              },

              icon: Icon(

                Icons.check_box,

                color: Colors.green,

              ),

            ),

            IconButton(

              onPressed: () {

                AppCubit.get(context).updateData(

                  status: 'archive',

                  id: model['id'],

                );

              },

              icon: Icon(

                Icons.archive,

                color: Colors.black45,

              ),

            ),

          ],

        ),

      ),
  onDismissed: (direction){
    AppCubit.get(context).deleteData(id: model['id'],);
  },
);

Widget tasksBuilder({
  @required List<Map> tasks,
}) => ConditionalBuilder(
  condition: tasks.length > 0,
  builder: (context)=>ListView.separated(
    itemBuilder: (context, index)=> buildTaskItem(tasks[index], context),
    separatorBuilder: (context, index)=> Container(
      width: double.infinity,
      height: 1.0,
      color: Colors.grey[300],
    ),
    itemCount: tasks.length,
  ),
  fallback: (context)=>Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.menu,
          size: 100.0,
          color: Colors.grey,
        ),
        Text(
          'No Tasks Yet, Please Add Some Tasks',
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
      ],
    ),
  ),
);
