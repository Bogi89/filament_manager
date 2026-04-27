import 'package:flutter/material.dart';

class AddItemDialog extends StatefulWidget {

  final String title;
  final String label;

  const AddItemDialog({
    super.key,
    required this.title,
    required this.label,
  });

  @override
  State<AddItemDialog> createState() =>
      _AddItemDialogState();
}

class _AddItemDialogState
    extends State<AddItemDialog> {

  final TextEditingController
      controller =
          TextEditingController();

  @override
  Widget build(BuildContext context) {

    return AlertDialog(

      title: Text(widget.title),

      content: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: widget.label,
        ),
        autofocus: true,
      ),

      actions: [

        TextButton(

          onPressed: () {

            Navigator.pop(context);

          },

          child: const Text(
              "Abbrechen"),

        ),

        ElevatedButton(

          onPressed: () {

            final value =
                controller.text.trim();

            if (value.isNotEmpty) {

              Navigator.pop(
                context,
                value,
              );

            }

          },

          child: const Text(
              "Speichern"),

        ),

      ],

    );
  }
}