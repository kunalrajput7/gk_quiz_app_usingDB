import 'dart:convert';
import 'package:mp3/utils/db_helper.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mp3/model/models.dart';
import 'views/decklist.dart';

// Method to load the JSON data into the database.
Future<void> loadJSONData() async {
  // Load JSON data from assets using rootBundle
  final jsonContent = await rootBundle.loadString('assets/flashcards.json');
  final List<dynamic> jsonList =
      jsonDecode(jsonContent); // Cast to dynamic list

  for (final dynamic map in jsonList) {
    final deckTitle = map['title'];
    final flashcards = map['flashcards'];

    final dbHelper = DBHelper();
    final deck = Deck(title: deckTitle);
    await deck.dbSave(dbHelper);

    for (final flashcardMap in flashcards) {
      final question = flashcardMap['question'];
      final answer = flashcardMap['answer'];

      final flashcard = Flashcard(
        deckId: deck.id!,
        question: question,
        answer: answer,
      );

      await flashcard.dbSave(dbHelper);
    }
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  final dbHelper = DBHelper();
  final decks = await dbHelper.getAllDecks();

  if (decks.isEmpty) {
    // Load the JSON files in the database only if there are no items in the database
    await loadJSONData();
  }

  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: DeckList(),
  ));
}
