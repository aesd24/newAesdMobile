import 'dart:io';
import 'package:aesd_app/components/button.dart';
import 'package:aesd_app/components/picture_containers.dart';
import 'package:aesd_app/components/snack_bar.dart';
import 'package:aesd_app/components/field.dart';
import 'package:aesd_app/functions/camera_functions.dart';
import 'package:aesd_app/providers/event.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';

class EventForm extends StatefulWidget {
  const EventForm({super.key, required this.churchId});

  final int churchId;

  @override
  State<EventForm> createState() => _EventFormState();
}

class _EventFormState extends State<EventForm> {
  bool isLoading = false;
  List months = [
    "Janvier",
    "Février",
    "Mars",
    "Avril",
    "Mai",
    "Juin",
    "Juillet",
    "Août",
    "Septembre",
    "Octobre",
    "Novembre",
    "Décembre"
  ];

  bool isPublic = false;

  // affiche de l'évènement
  File? image;

  // date de l'évènement
  DateTime? startDate;
  DateTime? endDate;

  // controllers
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final typeController = TextEditingController();
  final categoryController = TextEditingController();
  final locationController = TextEditingController();
  final organizerController = TextEditingController();

  // clé de formulaire
  final _formKey = GlobalKey<FormState>();

  handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      showSnackBar(
        context: context,
        message: "Remplissez correctement le formulaire",
        type: SnackBarType.danger
      );
      return;
    }

    if (image == null) {
      showSnackBar(
        context: context,
        message: "Veuillez sélectionner l'affiche de l'évènement",
        type: SnackBarType.warning
      );
      return;
    }

    if (startDate == null || endDate == null) {
      showSnackBar(
        context: context,
        message: "Renseignez correctement les dates de début et de fin",
        type: SnackBarType.warning
      );
      return;
    }

    createEvent();
  }

  createEvent() async {
    try {
      setState(() {
        isLoading = true;
      });
      await Provider.of<Event>(context, listen: false).createEvent({
        'is_public': isPublic,
        'title': titleController.text,
        'startDate': startDate,
        'endDate': endDate,
        'location': locationController.text,
        'type': typeController.text,
        'category': categoryController.text,
        'organizer': organizerController.text,
        'description': descriptionController.text,
        'churchId': widget.churchId,
        'file': image
      }).then((value) {
        showSnackBar(
          context: context,
          message: "Evènement créé avec succès !",
          type: SnackBarType.success
        );
      });
    } on DioException {
      showSnackBar(
        context: context,
        message: "Erreur réseau. Vérifiez votre connexion internet",
        type: SnackBarType.danger
      );
    } on HttpException catch(e) {
      showSnackBar(
        context: context,
        message: e.message,
        type: SnackBarType.danger
      );
    } catch(e) {
      showSnackBar(
        context: context,
        message: "Une erreur inattendu est survenue",
        type: SnackBarType.danger
      );
      e.printError();
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Création d'évènement"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 25),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                isPublic ? "L'évènement sera tout publique" :
                                "L'évènement sera interne à l'église",
                                overflow: TextOverflow.clip,
                              ),
                            ),
                            Switch(
                              value: isPublic,
                              onChanged: (value) {
                                setState(() {
                                  isPublic = value;
                                });
                              }
                            ),
                          ],
                        ),
                      ),
                      // partie de l'affiche
                      image == null
                          ? GestureDetector(
                              onTap: () async {
                                // selectionner une photo depuis la galérie
                                File? file = await pickImage(camera: true);
                                if (file != null) {
                                  image = file;
                                  setState(() {});
                                }
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(10),
                                margin: const EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    border:
                                        Border.all(width: 1.5, color: Colors.green)),
                                alignment: Alignment.center,
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.photo_size_select_actual_rounded,
                                        color: Colors.green),
                                    SizedBox(width: 15),
                                    Text("Ajouter l'affiche de l'évènement")
                                  ],
                                ),
                              ),
                            )
                          : imageSelectionBox(
                              context: context,
                              label: "",
                              overlayText: "Cliquez pour changer",
                              picture: image,
                              onClick: () async {
                                File? pickedFile = await pickImage(camera: true);
                                setState(() {
                                  image = pickedFile;
                                });
                              }),
                
                      // formulaire de création de l'évènement
                      Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              // titre de l'évènement
                              customTextField(
                                label: "Titre de l'évènement",
                                placeholder: "Ex: La campagne AESD",
                                controller: titleController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Remplissez d'abords le champs !";
                                  }
                                  return null;
                                },
                                prefixIcon: const Icon(Icons.event_note)
                              ),
                
                              // période de l'évènement
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: customDateField(
                                        label: "Date de debut",
                                        value: startDate,
                                        onChanged: (value){
                                          setState(() {
                                            startDate = value;
                                          });
                                        }
                                      ),
                                    ),
                                    SizedBox(width: 7),
                                    Expanded(
                                      child: customDateField(
                                        label: "Date de fin",
                                        value: endDate,
                                        onChanged: (value){
                                          setState(() {
                                            endDate = value;
                                          });
                                        }
                                      ),
                                    )
                                  ],
                                ),
                              ),
      
                              customTextField(
                                label: "Lieu",
                                placeholder: "Ex: Grand terrain de l'Université aesd",
                                controller: locationController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Remplissez d'abords le champs !";
                                  }
                                  return null;
                                },
                                prefixIcon: const Icon(Icons.location_pin)
                              ),
      
                              customTextField(
                                label: "Type",
                                placeholder: "Type d'évènement",
                                controller: typeController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Remplissez d'abords le champs !";
                                  }
                                  return null;
                                },
                              ),
      
                              customTextField(
                                label: "Catégorie",
                                placeholder: "Catégorie d'évènement",
                                controller: categoryController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Remplissez d'abords le champs !";
                                  }
                                  return null;
                                },
                              ),
      
                              customTextField(
                                label: "Organisateur",
                                placeholder: "Ex: Zadi Tapé",
                                controller: organizerController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Remplissez d'abords le champs !";
                                  }
                                  return null;
                                },
                                prefixIcon: Icon(FontAwesomeIcons.solidUser, size: 20)
                              ),
                
                              // description de l'évènement
                              customMultilineField(
                                  label: "Description de l'évènement",
                                  controller: descriptionController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Remplissez d'abords le champs !";
                                    }
                                    if (value.length < 30) {
                                      return "Donnez une description un peu plus détaillée";
                                    }
                                    return null;
                                  }),
      
                              SizedBox(height: 10)
                            ],
                          )),
                    ],
                  ),
                ),
              ),
              customButton(
                context: context,
                text: "Soumettre",
                trailing: const Icon(Icons.send, color: Colors.white),
                onPressed: () => handleSubmit()
              ),
              SizedBox(height: 15)
            ],
          ),
        ),
      ),
    );
  }
}
