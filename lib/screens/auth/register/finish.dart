import 'dart:io';

import 'package:dio/dio.dart';
import 'package:aesd_app/components/button.dart';
import 'package:aesd_app/components/snack_bar.dart';
import 'package:aesd_app/providers/auth.dart';
import 'package:aesd_app/providers/user.dart';
import 'package:aesd_app/screens/auth/login.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';

class FinishPage extends StatefulWidget {
  const FinishPage({super.key});

  @override
  State<FinishPage> createState() => _FinishPageState();
}

class _FinishPageState extends State<FinishPage> {
  String _message = "";
  IconData _icon = Icons.screen_search_desktop_sharp;
  bool _success = false;
  bool _isLoading = false;

  Future<void> _init() async {
    try {
      // recupérer les données enregistrées dans le provider
      Map data = Provider.of<User>(context, listen: false).registerData;

      // Lancer la fonction d'enregistrement des données
      dynamic response =
          await Provider.of<Auth>(context, listen: false).register(data: data);

      // récupérer le résultat de l'operation et la reponse du serveur
      if (response.statusCode == 201) {
        setState(() {
          _success = true;
          _message = response.data['message'];
          _icon = Icons.check_circle;
        });
      }
    } on HttpException catch (e) {
      setState(() {
        _success = false;
        _message = e.message;
        _icon = Icons.cancel;
      });
    } on DioException catch (e) {
      e.printError();
      setState(() {
        _success = false;
        _message = "Echec de l'opération";
        _icon = Icons.cancel;
      });

      showSnackBar(
        context: context,
        message: "Vérifiez la connexion internet et rééssayez",
        type: SnackBarType.danger
      );
    } catch (e) {
      e.printError();
      setState(() {
        _success = false;
        _message = "L'enregistrement à échoué !";
        _icon = Icons.cancel;
      });
      showSnackBar(
          context: context,
          message: "Une erreur s'est produite",
          type: SnackBarType.danger);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    // avertir l'utilisateur du début du traitement
    setState(() {
      _isLoading = true;
      _message = "Traitement en cours. Patientez...";
    });

    Future.delayed(const Duration(seconds: 2), () {
      _init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        appBar: AppBar(),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _message,
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Icon(
                      _icon,
                      color: _icon == Icons.cancel
                          ? Colors.red
                          : _success == true
                              ? Colors.green
                              : Colors.grey,
                      size: 100,
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: customButton(
                  context: context,
                  text: _success
                      ? "Retour à la page de connexion"
                      : "Rééssayer",
                  trailing: Icon(
                    _success ? Icons.login : Icons.restore,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    if (_success) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                            builder: (context) => const LoginPage()),
                      );
                    } else {
                      // avertir l'utilisateur du début du traitement
                      setState(() {
                        _isLoading = true;
                        _icon = Icons.screen_search_desktop_sharp;
                        _message = "Traitement en cours. Patientez...";
                      });
                
                      _init();
                    }
                  }
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
