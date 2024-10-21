import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_form_provider.dart';

class TaskForm extends StatelessWidget {
  const TaskForm({Key? key}) : super(key: key);
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TaskFormProvider(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Neue Aufgabe')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Consumer<TaskFormProvider?>(
            builder: (context, formProvider, child) {
              return Form(
                key: formProvider?.formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: formProvider?.titleController,
                      decoration: const InputDecoration(labelText: 'Titel'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Bitte geben Sie einen Titel ein';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: formProvider?.descriptionController,
                      decoration:
                          const InputDecoration(labelText: 'Beschreibung'),
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                            'Deadline: ${formProvider?.selectedDate.year}-${formProvider?.selectedDate.month.toString().padLeft(2, '0')}-${formProvider?.selectedDate.day.toString().padLeft(2, '0')}'),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate:
                                formProvider?.selectedDate ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2101),
                          );
                          if (picked != null &&
                              picked != formProvider?.selectedDate) {
                            formProvider?.setSelectedDate(picked);
                          }
                        },
                      ),
                    ),
                    DropdownButtonFormField<int>(
                      value: formProvider?.selectedPriority,
                      decoration: const InputDecoration(labelText: 'Priorität'),
                      items: const [
                        DropdownMenuItem(value: 1, child: Text('Hoch')),
                        DropdownMenuItem(value: 2, child: Text('Mittel')),
                        DropdownMenuItem(value: 3, child: Text('Niedrig')),
                      ],
                      onChanged: (value) {
                        formProvider?.setSelectedPriority(value!);
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => formProvider?.submitForm(context),
                      child: const Text('Aufgabe hinzufügen'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
