import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:journal/apis/git.dart';
import 'package:journal/note_editor.dart';
import 'package:journal/note_viewer.dart';
import 'package:journal/state_container.dart';
import 'package:journal/widgets/app_drawer.dart';
import 'package:journal/widgets/journal_list.dart';

class HomeScreen extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final container = StateContainer.of(context);
    final appState = container.appState;

    var createButton = FloatingActionButton(
      onPressed: () => _newPost(context),
      child: Icon(Icons.add),
    );

    var journalList = JournalList(
      notes: appState.notes,
      noteSelectedFunction: (noteIndex) {
        var route = MaterialPageRoute(
          builder: (context) => NoteBrowsingScreen(
                notes: appState.notes,
                noteIndex: noteIndex,
              ),
        );
        Navigator.of(context).push(route);
      },
    );

    var appBarMenuButton = BadgeIconButton(
      icon: const Icon(Icons.menu),
      itemCount: appState.remoteGitRepoConfigured ? 0 : 1,
      onPressed: () {
        _scaffoldKey.currentState.openDrawer();
      },
    );

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('GitJournal'),
        leading: appBarMenuButton,
      ),
      floatingActionButton: createButton,
      body: Center(
        child: RefreshIndicator(
            child: journalList,
            onRefresh: () async {
              try {
                await container.syncNotes();
              } on GitException catch (exp) {
                _scaffoldKey.currentState
                  ..removeCurrentSnackBar()
                  ..showSnackBar(SnackBar(content: Text(exp.cause)));
              }
            }),
      ),
      drawer: AppDrawer(),
    );
  }

  void _newPost(BuildContext context) {
    var route = MaterialPageRoute(builder: (context) => NoteEditor());
    Navigator.of(context).push(route);
  }
}
