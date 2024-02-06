import 'package:flutter/material.dart';
import 'package:mp3/model/models.dart';

class Quiz extends StatefulWidget {
  final List<Flashcard> flashcards;
  final String deckName;

  const Quiz({required this.flashcards, required this.deckName, Key? key})
      : super(key: key);

  @override
  State<Quiz> createState() => _QuizState();
}

class _QuizState extends State<Quiz> {
  int currentIndex = 0; // stores the index of the flashcards
  bool isFlipped = false;

  // Variables to store the values of the card => seen, flipped, peeked and answers
  int seen = 1;
  int flip = 0;
  int peek = 0;
  int answer = 1;

  List<Flashcard> shuffledFlashcards = [];
  List<int> flippedCards = [];
  List<int> visitedcards = [
    0
  ]; // Stores the index of the first card of the flashcards, because it is already displayed on the screens

  @override
  void initState() {
    super.initState();
    shuffledFlashcards = List<Flashcard>.from(widget.flashcards)..shuffle();
  }

  // Method called when the previous button is pressed.
  void goToPreviousCard() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
        if (!visitedcards.contains(currentIndex)) {
          // checks if the index of this card is present in our list
          seen++;
          visitedcards.add(currentIndex);
        }
        isFlipped = false;
        answer = seen;
      });
    } else {
      setState(() {
        // If at the first card, go to the last card in the deck
        currentIndex = shuffledFlashcards.length - 1;
        if (!visitedcards.contains(currentIndex)) {
          seen++;
          visitedcards.add(currentIndex);
        }
        isFlipped = false;
        answer = seen;
      });
    }
  }

  //// Method called when the next button is pressed.
  void goToNextCard() {
    if (currentIndex < shuffledFlashcards.length - 1) {
      setState(() {
        currentIndex++;
        // If the current card is not seen, increment the seen count and mark it as seen
        if (!visitedcards.contains(currentIndex)) {
          seen++;
          visitedcards.add(currentIndex);
        }
        isFlipped = false;
        answer = seen;
      });
    } else {
      setState(() {
        // If at the last card, go to the first card in the deck
        currentIndex = 0;
        if (!visitedcards.contains(currentIndex)) {
          seen++;
          visitedcards.add(currentIndex);
        }
        isFlipped = false;
        answer = seen;
      });
    }
  }

  // Method called when Flip button is pressed.
  void flipCard() {
    setState(() {
      isFlipped = !isFlipped;
      // If the card is flipped, seen, and not flipped, increment flip count and peek count
      if (isFlipped &&
          visitedcards.contains(currentIndex) &&
          !flippedCards.contains(currentIndex)) {
        flip++;
        answer = seen;
        flippedCards.add(currentIndex);
        peek++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.deckName} Quiz'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(20.0),
            width: 300,
            height: 200,
            decoration: BoxDecoration(
              color: isFlipped ? Colors.lightGreen : Colors.lightBlue,
              borderRadius: BorderRadius.circular(15.0),
              border: Border.all(color: Colors.black),
            ),
            child: Center(
              child: Text(
                isFlipped
                    ? shuffledFlashcards[currentIndex].answer
                    : shuffledFlashcards[currentIndex].question,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 30.0),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded),
                onPressed: goToPreviousCard,
              ),
              IconButton(
                icon: const Icon(Icons.flip),
                onPressed: flipCard,
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios_rounded),
                onPressed: goToNextCard,
              ),
            ],
          ),
          const SizedBox(height: 20.0),
          Text('Seen: $seen out of ${shuffledFlashcards.length} cards'),
          Text('Peeked at $peek out of $answer answers'),
        ],
      ),
    );
  }
}
