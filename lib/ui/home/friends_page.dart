import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:handle_hero/utils/my_images.dart';
import 'package:handle_hero/widgets/treasure_ui.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key, required this.userId});

  final String userId;

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  final _idController = TextEditingController();
  DocumentSnapshot<Map<String, dynamic>>? _result;
  String? _message;
  bool _searching = false;
  bool _adding = false;

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final id = _idController.text.trim();
    if (id.isEmpty) {
      setState(() {
        _result = null;
        _message = 'Enter a player ID to search.';
      });
      return;
    }
    if (id == widget.userId) {
      setState(() {
        _result = null;
        _message = 'That is your own player ID.';
      });
      return;
    }
    setState(() {
      _searching = true;
      _result = null;
      _message = null;
    });
    try {
      final result = await FirebaseFirestore.instance
          .collection('users')
          .doc(id)
          .get();
      if (!mounted) return;
      setState(() {
        _result = result.exists ? result : null;
        _message = result.exists ? null : 'No player found with that ID.';
      });
    } on FirebaseException {
      if (!mounted) return;
      setState(() => _message = 'Could not search. Check your connection.');
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  Future<void> _addFriend(String friendId, String name) async {
    setState(() => _adding = true);
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('friends')
          .doc(friendId)
          .set({'id': friendId, 'name': name});
      if (mounted) {
        setState(() {
          _result = null;
          _idController.clear();
          _message = 'Friend added.';
        });
      }
    } on FirebaseException {
      if (mounted) {
        setState(() => _message = 'Could not add this friend. Try again.');
      }
    } finally {
      if (mounted) setState(() => _adding = false);
    }
  }

  Future<void> _removeFriend(String friendId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('friends')
        .doc(friendId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    final friends = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('friends');
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(MyImages.background, fit: BoxFit.cover),
        SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              TreasureWindow(
                title: 'FRIENDS',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Search for a player using their ID.',
                      style: TextStyle(color: Color(0xFFE3D9AA), fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _idController,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: const InputDecoration(
                        labelText: 'PLAYER ID',
                        labelStyle: TextStyle(color: Color(0xFFE3D9AA)),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF7C806C), width: 2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFD1C27E), width: 2),
                        ),
                      ),
                      onSubmitted: (_) => _search(),
                    ),
                    const SizedBox(height: 12),
                    TreasureButton(
                      label: _searching ? 'SEARCHING...' : 'SEARCH',
                      labelColor: Colors.black,
                      labelShadow: false,
                      onPressed: _searching ? null : _search,
                    ),
                    if (_message != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _message!,
                        style: const TextStyle(color: Color(0xFFE3D9AA), fontSize: 11),
                      ),
                    ],
                    if (_result != null) ...[
                      const SizedBox(height: 16),
                      _PlayerResult(
                        name: (_result!.data()?['name'] as String?) ?? 'Player',
                        id: _result!.id,
                        adding: _adding,
                        onAdd: () => _addFriend(
                          _result!.id,
                          (_result!.data()?['name'] as String?) ?? 'Player',
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: friends.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Text(
                      'Could not load friends. Check your Firestore setup.',
                      style: TextStyle(color: Color(0xFFE3D9AA), fontSize: 11),
                    );
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final docs = snapshot.data!.docs;
                  if (docs.isEmpty) {
                    return const TreasureWindow(
                      title: 'YOUR FRIENDS',
                      child: Text(
                        'No friends yet. Search by player ID to add someone.',
                        style: TextStyle(color: Color(0xFFE3D9AA), fontSize: 11),
                      ),
                    );
                  }
                  return TreasureWindow(
                    title: 'YOUR FRIENDS',
                    child: Column(
                      children: [
                        for (final friend in docs)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              (friend.data()['name'] as String?) ?? 'Player',
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                            ),
                            subtitle: Text(
                              friend.id,
                              style: const TextStyle(color: Color(0xFFE3D9AA), fontSize: 9),
                            ),
                            trailing: IconButton(
                              tooltip: 'Remove friend',
                              onPressed: () => _removeFriend(friend.id),
                              icon: const Icon(Icons.close, color: Color(0xFFE3D9AA)),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PlayerResult extends StatelessWidget {
  const _PlayerResult({
    required this.name,
    required this.id,
    required this.adding,
    required this.onAdd,
  });

  final String name;
  final String id;
  final bool adding;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      const Icon(Icons.person_outline, color: Color(0xFFD1C27E)),
      const SizedBox(width: 8),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: const TextStyle(color: Colors.white, fontSize: 12)),
            Text(id, style: const TextStyle(color: Color(0xFFE3D9AA), fontSize: 8)),
          ],
        ),
      ),
      TextButton(
        onPressed: adding ? null : onAdd,
        child: Text(adding ? 'ADDING...' : 'ADD', style: const TextStyle(fontSize: 10)),
      ),
    ],
  );
}
