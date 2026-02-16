import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kidneyproject/pages/menu_joc.dart';
import 'package:kidneyproject/pages/menu_principal.dart';

class TrivialPage extends StatefulWidget {
  final String userId;

  TrivialPage({Key? key, required this.userId}) : super(key: key);

  @override
  _TrivialPageState createState() => _TrivialPageState();
}

class _TrivialPageState extends State<TrivialPage> {
  int currentQuestionIndex = 0;
  int correctAnswersCount = 0;
  int coins = 0;
  bool _isExplanationVisible = true; // Boolean to toggle explanation visibility
  bool mostrarImagen = false; // Variable to control image visibility

  List<Map<String, dynamic>> questionsAndAnswers = [];

  List<Color> buttonColors = [
    Colors.blue,
    Colors.blue,
    Colors.blue,
    Colors.blue,
  ];

  bool incorrectAnswerDiscarded = false;

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
    _fetchCoins();
  }

  void _fetchQuestions() async {
    try {
      QuerySnapshot questionSnapshot = await FirebaseFirestore.instance
          .collection('Trivial')
          .get();

      List<Map<String, dynamic>> fetchedQuestionsAndAnswers =
          questionSnapshot.docs.map((doc) {
        Map<String, dynamic> data = {
          'question': doc['Pregunta'],
          'answers': List<String>.from(doc['Respostes']),
          'correctAnswer': doc['Resposta Correcta'],
        };

        // Mostrar los datos por consola
        print('Question: ${data['question']}');
        print('Answers: ${data['answers']}');
        print('Correct Answer: ${data['correctAnswer']}');

        return data;
      }).toList();

      // Barajar las preguntas y seleccionar las primeras 5
      fetchedQuestionsAndAnswers.shuffle();
      fetchedQuestionsAndAnswers = fetchedQuestionsAndAnswers.sublist(
          0, min(5, fetchedQuestionsAndAnswers.length));

      // Actualizar el estado para mostrar las preguntas y respuestas
      setState(() {
        questionsAndAnswers = fetchedQuestionsAndAnswers;
      });
    } catch (error) {
      print('Error fetching questions: $error');
    }
  }

  void _fetchCoins() async {
    try {
      DocumentSnapshot userData = await FirebaseFirestore.instance
          .collection('Usuarios')
          .doc(widget.userId)
          .collection('trivial')
          .doc('datos')
          .get();

      setState(() {
        coins = userData['coins'] ?? 0;
      });
    } catch (error) {
      print('Error fetching coins: $error');
    }
  }

  void _subtractCoins(int amount) {
    setState(() {
      coins -= amount;
    });
    _updateCoinsInFirestore();
  }

  void _addCoins(int amount) {
    setState(() {
      coins += amount;
    });
    _updateCoinsInFirestore();
  }

  void _updateCoinsInFirestore() async {
    try {
      await FirebaseFirestore.instance
          .collection('Usuarios')
          .doc(widget.userId)
          .collection('trivial')
          .doc('datos')
          .update({'coins': coins});
    } catch (error) {
      print('Error updating coins in Firestore: $error');
    }
  }
  void _toggleExplanation() {
    setState(() {
      _isExplanationVisible = !_isExplanationVisible;
    });
  }
  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Trivial Game'),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Image.asset(
                'lib/images/coin.png',
                width: 24,
                height: 24,
              ),
              SizedBox(width: 5),
              Text('$coins'),
            ],
          ),
        ),
      ],
    ),
    body: Padding(
      padding: const EdgeInsets.all(20.0),
      child: SingleChildScrollView(  // Asegura que el contenido se pueda desplazar
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Punts: $correctAnswersCount',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10.0),
            Text(
              currentQuestionIndex < questionsAndAnswers.length
                  ? questionsAndAnswers[currentQuestionIndex]['question']
                  : 'Fi del joc',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20.0),
            if (currentQuestionIndex < questionsAndAnswers.length)
              ...questionsAndAnswers[currentQuestionIndex]['answers']
                  .asMap()
                  .entries
                  .map((entry) {
                int index = entry.key;
                String answer = entry.value;
                return Column(
                  children: [
                    TrivialButton(
                      text: answer,
                      onPressed: () {
                        checkAnswer(answer, context, index);
                      },
                      color: buttonColors[index],
                    ),
                    const SizedBox(height: 10.0),
                  ],
                );
              }).toList(),
            SizedBox(height: 30.0),
            Text(
              'Pistes',
              style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // HelpWrong Button (Elimina una resposta incorrecta)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  onPressed: () {
                    if (coins >= 100) {
                      _subtractCoins(100);
                      _discardIncorrectAnswer(); // Llama a la función que elimina una resposta incorrecta.
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('No tens suficients monedes'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  child: Row(
                    children: [
                      Image.asset(
                        'lib/images/helpWrong.png',
                        height: 40,
                      ),
                      SizedBox(width: 5),
                      Text('100'),
                    ],
                  ),
                ),
                // HelpCorrect Button (Muestra la respuesta correcta)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  onPressed: () {
                    if (coins >= 200) {
                      _subtractCoins(200);
                      _markCorrectAnswer(); // Llama a la función que marca la resposta correcta.
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('No tens suficients monedes'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  child: Row(
                    children: [
                      Image.asset(
                        'lib/images/helpCorrect.png',
                        height: 40,
                      ),
                      SizedBox(width: 5),
                      Text('200'),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 30.0),
            // Toggle Button to show or hide the explanation
            ElevatedButton(
              onPressed: _toggleExplanation,
              child: Text(_isExplanationVisible ? 'Mostrar explicació' : 'Ocultar explicació'),
            ),
            SizedBox(height: 20.0),
            // Explanation text that is conditionally shown
            if (!_isExplanationVisible)
              Text(
                "Explicació dels botons: \n\n"
                "1. Botó vermell: Al presionar el botó, elimina una resposta incorrecta. (Cost: 100 monedes).\n\n"
                "2. Botó verd: Al presionar el botó, marca la resposta correcta. (Cost: 200 monedes).",
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Roboto', // O cualquier otra fuente que prefieras
                  color: Colors.black87, // Color del texto
                  height: 1.2, // Espaciado entre líneas
                ),
                textAlign: TextAlign.left, // Alineación del texto a la izquierda
              ),
          ],
        ),
      ),
    ),
  );
}

  void checkAnswer(
      String selectedAnswer, BuildContext context, int buttonIndex) {
    String correctAnswer =
    questionsAndAnswers[currentQuestionIndex]['correctAnswer'].trim();
    bool isCorrect = selectedAnswer.trim() == correctAnswer;

    setState(() {
      buttonColors[buttonIndex] = isCorrect ? Colors.green : Colors.red;
      if (isCorrect) {
        mostrarImagen = true; // Hacer visible la imagen si la respuesta es correcta
      }
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isCorrect ? 'Resposta Correcta' : 'Resposta Incorrecta'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isCorrect
                    ? '¡Oleeee! La resposta és $correctAnswer.'
                    : 'Ohhh, la resposta correcta és $correctAnswer.',
              ),
              // Mostrar la imagen solo si la respuesta es correcta y mostrarImagen es true
              if (isCorrect && mostrarImagen)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Image.asset(
                    'lib/images/+50Puntos.png',
                    width: 150,
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (isCorrect) {
                  setState(() {
                    correctAnswersCount++;
                    _addCoins(50);
                    mostrarImagen = false; // Restablecer la imagen para no mostrarla nuevamente
                    if (currentQuestionIndex < questionsAndAnswers.length - 1) {
                      currentQuestionIndex++;
                      incorrectAnswerDiscarded = false;
                    } else {
                      saveGameData(widget.userId, correctAnswersCount, coins);
                      showSummaryDialog(context);
                    }
                  });
                } else {
                  setState(() {
                    // Avanzar a la siguiente pregunta si la respuesta es incorrecta
                    if (currentQuestionIndex < questionsAndAnswers.length - 1) {
                      currentQuestionIndex++;
                    }
                  });
                }
                resetButtonColors();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }


  void saveGameData(String userId, int points, int coins) async {
  try {
    // Referencia al documento de Firestore
    DocumentReference userRef = FirebaseFirestore.instance
        .collection('Usuarios')
        .doc(userId)
        .collection('trivial')
        .doc('datos');

    // Log para verificar los datos a guardar
    print('Guardando datos: Puntos = $points, Monedas = $coins');

    // Obtener el documento
    DocumentSnapshot userDoc = await userRef.get();

    if (userDoc.exists) {
      // Si el documento existe, comprobar si 'maxPuntuacion' está presente
      int currentMaxScore = 0; // Valor por defecto si el campo no existe

      if (userDoc.data() != null && (userDoc.data() as Map<String, dynamic>).containsKey('maxPuntuacion')) {
        // Si maxPuntuacion existe, la leemos
        currentMaxScore = userDoc['maxPuntuacion'] ?? 0;
      } else {
        // Si no existe, inicializamos con el valor actual de los puntos
        currentMaxScore = points;
      }

      // Determinar la nueva puntuación máxima (si es mayor, la actualizamos)
      int newMaxScore = points > currentMaxScore ? points : currentMaxScore;

      // Guardar los nuevos datos, incluyendo la puntuación máxima
      await userRef.set({
        'points': points,  // Guardar los puntos de esta partida
        'coins': coins,
        'maxPuntuacion': newMaxScore,  // Siempre actualizamos la puntuación máxima si es necesario
      }, SetOptions(merge: true));  // Merge solo actualiza los campos

      print('Datos guardados correctamente, maxPuntuacion actualizada si corresponde');
    } else {
      // Si el documento no existe, lo creamos con la puntuación inicial
      await userRef.set({
        'points': points,
        'coins': coins,
        'maxPuntuacion': points,  // Si no existe, inicializamos 'maxPuntuacion' con los puntos
      });

      print('Nuevo documento de usuario creado con maxPuntuacion: $points');
    }
  } catch (error) {
    print('Error al guardar los datos del juego: $error');
  }
}


  void _discardIncorrectAnswer() {
    if (!incorrectAnswerDiscarded) {
      setState(() {
        // Obtener la respuesta correcta
        String correctAnswer =
            questionsAndAnswers[currentQuestionIndex]['correctAnswer'];

        // Iterar sobre las respuestas y encontrar la incorrecta
        for (int i = 0;
            i < questionsAndAnswers[currentQuestionIndex]['answers'].length;
            i++) {
          if (questionsAndAnswers[currentQuestionIndex]['answers'][i] !=
              correctAnswer) {
            buttonColors[i] =
                Colors.red; // Marcar la respuesta incorrecta como incorrecta
            break; // Salir del bucle una vez que se haya marcado una respuesta incorrecta
          }
        }

        incorrectAnswerDiscarded = true;
      });
    }
  }

  void _markCorrectAnswer() {
    setState(() {
      // Obtener la respuesta correcta
      String correctAnswer =
          questionsAndAnswers[currentQuestionIndex]['correctAnswer'];

      // Iterar sobre las respuestas y encontrar la correcta
      for (int i = 0;
          i < questionsAndAnswers[currentQuestionIndex]['answers'].length;
          i++) {
        if (questionsAndAnswers[currentQuestionIndex]['answers'][i] ==
            correctAnswer) {
          buttonColors[i] =
              Colors.green; // Marcar la respuesta correcta como correcta
          break; // Salir del bucle una vez que se haya marcado la respuesta correcta
        }
      }
    });
  }

  void resetGame() {
    setState(() {
      currentQuestionIndex = 0;
      correctAnswersCount = 0;
      resetButtonColors();
    });

    // Guardar los datos del juego al reiniciar
    saveGameData(widget.userId, correctAnswersCount, coins);
  }

  void resetButtonColors() {
    setState(() {
      buttonColors = List<Color>.filled(
        questionsAndAnswers[currentQuestionIndex]['answers'].length,
        Colors.blue,
      );
    });
  }

  void showSummaryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Resum de la partida'),
          content: Text('Punts obtinguts: $correctAnswersCount'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                resetGame();
              },
              child: Text('Tornar a Jugar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          MenuJoc(userId: widget.userId)),
                );
              },
              child: Text('Tornar al Menú'),
            ),
          ],
        );
      },
    );
  }
}

class TrivialButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;

  const TrivialButton({
    Key? key,
    required this.text,
    required this.onPressed,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: SizedBox(
        width: double.infinity,
        child: Material(
          color: color,
          child: InkWell(
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Center(
                child: Text(
                  text,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
