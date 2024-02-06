import 'package:flutter/material.dart';
import 'package:mp3/model/models.dart';
import 'package:mp3/utils/db_helper.dart';
import 'package:mp3/views/quiz.dart';

class FlashcardList extends StatefulWidget {
  final Deck deck;

  const FlashcardList({required this.deck, Key? key}) : super(key: key);

  @override
  State<FlashcardList> createState() => _FlashcardListState();
}

class _FlashcardListState extends State<FlashcardList> {
  late List<Flashcard> flashcards;
  bool isSorted =
      false; // this variables stores T or F whether the cards are displayed in a sorted manner or not
  bool loading =
      true; // this variable store the T or F so that it displays the "loading" logo while the flashcards are been displayed

  @override
  void initState() {
    super.initState();
    loadFlashcards();
  }

  // Method to load all the Flashcards from the db
  Future<void> loadFlashcards() async {
    final dbHelper = DBHelper();
    final flashcardList = await dbHelper.getFlashcardsForDeck(widget.deck.id!);
    setState(() {
      flashcards = flashcardList;
      loading = false;
    });
  }

  // Method to edit a Flashcard from the db of the particular deck
  Future<void> _editFlashcard(int index) async {
    String oldQuestion = flashcards[index].question;
    String oldAnswer = flashcards[index].answer;
    TextEditingController questionController =
        TextEditingController(text: oldQuestion);
    TextEditingController answerController =
        TextEditingController(text: oldAnswer);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Flashcard'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: questionController,
                decoration: const InputDecoration(labelText: 'Question'),
              ),
              TextField(
                controller: answerController,
                decoration: const InputDecoration(labelText: 'Answer'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                final dbHelper = DBHelper();
                final newQuestion = questionController.text;
                final newAnswer = answerController.text;

                if (newQuestion.isNotEmpty && newAnswer.isNotEmpty) {
                  final updatedFlashcard = Flashcard(
                    id: flashcards[index].id,
                    deckId: widget.deck.id!,
                    question: newQuestion,
                    answer: newAnswer,
                  );

                  await updatedFlashcard.dbUpdate(dbHelper);
                  setState(() {
                    flashcards[index] = updatedFlashcard;
                  });

                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Method to delete a flash card from the table
  void _deleteFlashcard(int index) async {
    final dbHelper = DBHelper();
    final flashcardId = flashcards[index].id;

    if (flashcardId != null) {
      await dbHelper.delete('flashcard', flashcardId);

      setState(() {
        flashcards.removeAt(index);
      });
    }
  }

  // Method to add a flash card on the screen and in the database
  Future<void> _addFlashcard() async {
    TextEditingController questionController = TextEditingController();
    TextEditingController answerController = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Flashcard'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: questionController,
                decoration: const InputDecoration(labelText: 'Question'),
              ),
              TextField(
                controller: answerController,
                decoration: const InputDecoration(labelText: 'Answer'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                final newQuestion = questionController.text;
                final newAnswer = answerController.text;

                if (newQuestion.isNotEmpty && newAnswer.isNotEmpty) {
                  final dbHelper = DBHelper();
                  final newFlashcard = Flashcard(
                    deckId: widget.deck.id!,
                    question: newQuestion,
                    answer: newAnswer,
                  );

                  await newFlashcard.dbSave(dbHelper);
                  setState(() {
                    flashcards.add(newFlashcard);
                  });

                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Method called when the "Sort" button is click.
  void _toggleSort() {
    if (isSorted) {
      // Revert back to the previous order.
      flashcards.sort((a, b) => a.id!.compareTo(b.id!));
    } else {
      // Sort flashcards alphabetically by the question.
      flashcards.sort((a, b) => a.question.compareTo(b.question));
    }
    isSorted = !isSorted; // Toggle the sorting order.
    setState(() {});
  }

  void _navigateToQuiz() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Quiz(
          flashcards: flashcards,
          deckName: widget.deck.title,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.deck.title),
        actions: <Widget>[
          IconButton(
            icon: Icon(isSorted ? Icons.sort_by_alpha : Icons.sort_by_alpha),
            onPressed: _toggleSort,
          ),
          IconButton(
            icon: const Icon(Icons.quora_rounded),
            onPressed: _navigateToQuiz,
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = constraints.maxWidth;
                final maxFlashcardsInRow = (screenWidth / 200).floor();
                final crossAxisCount =
                    maxFlashcardsInRow > 0 ? maxFlashcardsInRow : 1;

                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: flashcards.length,
                  itemBuilder: (context, index) {
                    final flashcard = flashcards[index];
                    return Card(
                      key: UniqueKey(),
                      color: const Color.fromARGB(255, 44, 149, 206),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0)),
                      child: InkWell(
                        onTap: () {
                          _editFlashcard(index);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          child: Stack(
                            children: [
                              Center(
                                child: Text(
                                  flashcard.question,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    _editFlashcard(index);
                                  },
                                ),
                              ),
                              Positioned(
                                top: 0,
                                left: 0,
                                child: IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    _deleteFlashcard(index);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addFlashcard();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
