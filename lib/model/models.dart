import 'package:mp3/utils/db_helper.dart';

//These are my model classes, which contain the variables and methods to operate the database
class Deck {
  int? id;
  String title;

  Deck({
    this.id,
    required this.title,
  });

  //function to save the data into the deck table
  Future<void> dbSave(DBHelper dbHelper) async {
    id = await dbHelper.insert('deck', {'title': title});
  }

  //function to update the existing data into the deck table
  Future<void> dbUpdate(DBHelper dbHelper) async {
    await dbHelper.updateDeckTitle(id!, title);
  }

  factory Deck.fromMap(Map<String, dynamic> map) {
    return Deck(
      id: map['id'],
      title: map['title'],
    );
  }
}

class Flashcard {
  int? id;
  int deckId;
  String question;
  String answer;

  Flashcard({
    this.id,
    required this.deckId,
    required this.question,
    required this.answer,
  });

  //function to save the data into flashcard deck table
  Future<void> dbSave(DBHelper dbHelper) async {
    id = await dbHelper.insert('flashcard', {
      'deck_id': deckId,
      'question': question,
      'answer': answer,
    });
  }

  //function to delete the data from the flashcard table
  Future<void> dbDelete() async {
    if (id != null) {
      await DBHelper().delete('flashcard', id!);
    }
  }

  //function to update the existing data into the flashcard table
  Future<void> dbUpdate(DBHelper dbHelper) async {
    if (id != null) {
      await dbHelper.updateFlashcard(id!, deckId, question, answer);
    }
  }

  factory Flashcard.fromMap(Map<String, dynamic> map) {
    return Flashcard(
      id: map['id'],
      deckId: map['deck_id'],
      question: map['question'],
      answer: map['answer'],
    );
  }
}
