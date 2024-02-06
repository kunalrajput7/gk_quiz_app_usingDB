import 'package:flutter/material.dart';
import 'package:mp3/main.dart';
import 'package:mp3/model/models.dart';
import 'flashcardlist.dart';
import 'package:mp3/utils/db_helper.dart';

class DeckList extends StatefulWidget {
  const DeckList({super.key});

  @override
  State<DeckList> createState() => _DeckListState();
}

class _DeckListState extends State<DeckList> {
  late List<Deck> decks;

  @override
  void initState() {
    super.initState();
    loadDecks();
  }

  // the load deck function here fetches all the decks from the database using the dbHelper object
  Future<void> loadDecks() async {
    final dbHelper = DBHelper();
    final deckList = await dbHelper.getAllDecks();
    setState(() {
      decks = deckList;
    });
  }

  // Method to edit the deck name on app screen and in the database
  Future<void> _editDeck(int index) async {
    String oldDeckName = decks[index].title;
    TextEditingController deckNameController =
        TextEditingController(text: oldDeckName);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Deck Name'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: deckNameController,
                decoration: const InputDecoration(labelText: 'New Deck Name'),
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
                // Saving the edited name in the database
                final dbHelper = DBHelper();
                final newDeckName = deckNameController.text;

                if (newDeckName.isNotEmpty) {
                  final updatedDeck =
                      Deck(id: decks[index].id, title: newDeckName);
                  await updatedDeck.dbUpdate(dbHelper);

                  // Updating the deck title in the list by calling the setState() function
                  setState(() {
                    decks[index].title = newDeckName;
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

  // Method to delete the deck in the app and in the database
  void _deleteDeck(int index) async {
    final dbHelper = DBHelper();
    final deckId = decks[index].id;

    if (deckId != null) {
      // Deleting the flashcard of that deck by calling its method in the Database file
      await dbHelper.deleteFlashcardsForDeck(deckId);

      // And then, delete the deck from the database
      await dbHelper.delete('deck', deckId);

      // And finally updating the new deck list
      setState(() {
        decks.removeAt(index);
      });
    }
  }

  // Method to add a new deck in the app and also in the database
  Future<void> _addDeck() async {
    TextEditingController deckNameController = TextEditingController();
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Deck Name'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: deckNameController,
                decoration: const InputDecoration(labelText: 'Deck Name'),
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
                final newDeckName = deckNameController.text;

                if (newDeckName.isNotEmpty) {
                  final dbHelper = DBHelper();
                  final newDeck = Deck(title: newDeckName);
                  await newDeck.dbSave(dbHelper);

                  setState(() {
                    decks.add(newDeck);
                  });
                }

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Method to show all the flashcards of a deck by calling the Flashcard widget constructor
  void _showFlashcards(int index) {
    final deck = decks[index];
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FlashcardList(deck: deck),
      ),
    );
  }

  // Method to load the existing JSON data when I click on the Download button on the app bar
  void _downloadData() async {
    await loadJSONData();
    loadDecks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Deck List"),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_sharp),
            onPressed: _downloadData,
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final maxDecksInRow = (screenWidth / 200).floor();
          final crossAxisCount = maxDecksInRow > 0
              ? maxDecksInRow
              : 1; // Keeping 1 coloumn minimun in the app screen

          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 1.0,
            ),
            itemCount: decks.length,
            itemBuilder: (context, index) {
              final deck = decks[index];
              return Card(
                key: UniqueKey(),
                color: Colors.purple[100],
                child: InkWell(
                  onTap: () {
                    _showFlashcards(index);
                  },
                  child: Container(
                    alignment: Alignment.center,
                    child: Stack(
                      children: [
                        Center(
                          child: Text(deck.title),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              _editDeck(index);
                            },
                          ),
                        ),
                        Positioned(
                          top: 0,
                          left: 0,
                          child: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              _deleteDeck(index);
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
          _addDeck();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
