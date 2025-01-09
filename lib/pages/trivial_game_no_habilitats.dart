import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kidneyproject/pages/menu_joc.dart';
import 'package:kidneyproject/pages/menu_principal.dart';

class TrivialPageNoHabilitats extends StatefulWidget {
  final String userId;

  TrivialPageNoHabilitats({Key? key, required this.userId}) : super(key: key);

  @override
  _TrivialPageNoHabilitatsState createState() => _TrivialPageNoHabilitatsState();
}

class _TrivialPageNoHabilitatsState extends State<TrivialPageNoHabilitats> {
  int currentQuestionIndex = 0;
  int correctAnswersCount = 0;
  int coins = 0;
 // bool _isExplanationVisible = true; // Boolean to toggle explanation visibility

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
/*  void _toggleExplanation() {
    setState(() {
      _isExplanationVisible = !_isExplanationVisible;
    });
  }*/
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
          ],
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
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isCorrect ? 'Resposta Correcta' : 'Resposta Incorrecta'),
          content: Text(isCorrect
              ? '¡Oleeee! La resposta és $correctAnswer.'
              : 'Ohhh, la resposta correcta és $correctAnswer.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (isCorrect) {
                  setState(() {
                    correctAnswersCount++;
                    _addCoins(50);
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
                    buttonColors[buttonIndex] = Colors.red;
                   // _discardIncorrectAnswer();
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

void saveGameData(String userId, int pointsNoHabilitats, int coins) async {
  try {
    DocumentReference userRef = FirebaseFirestore.instance
        .collection('Usuarios')
        .doc(userId)
        .collection('trivial')
        .doc('datos');

    print('Guardando datos: Puntos = $pointsNoHabilitats, Monedas = $coins');

    DocumentSnapshot userDoc = await userRef.get();

    if (userDoc.exists) {
      int currentMaxScoreNoHabilitats = 0; 

      if (userDoc.data() != null && (userDoc.data() as Map<String, dynamic>).containsKey('maxPuntuacionNoHabilitats')) {
        currentMaxScoreNoHabilitats = userDoc['maxPuntuacionNoHabilitats'] ?? 0;
      } else {
        currentMaxScoreNoHabilitats = pointsNoHabilitats;
      }

      int newMaxScoreNoHabilitats = pointsNoHabilitats > currentMaxScoreNoHabilitats ? pointsNoHabilitats : currentMaxScoreNoHabilitats;

      await userRef.set({
        'pointsNoHabilitats': pointsNoHabilitats,  
        'coins': coins,
        'maxPuntuacionNoHabilitats': newMaxScoreNoHabilitats,  
      }, SetOptions(merge: true));  

      print('Datos guardados correctamente, maxPuntuacion actualizada si corresponde');
    } else {
      await userRef.set({
        'pointsNoHabilitats': pointsNoHabilitats,
        'coins': coins,
        'maxPuntuacionNoHabilitats': pointsNoHabilitats,  
      });

      print('Nuevo documento de usuario creado con maxPuntuacion: $pointsNoHabilitats');
    }
  } catch (error) {
    print('Error al guardar los datos del juego: $error');
  }
}

  /*void _discardIncorrectAnswer() {
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
  }*/

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
