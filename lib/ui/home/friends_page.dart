import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:handle_hero/bloc/home/home_bloc.dart';
import 'package:handle_hero/bloc/home/home_event.dart';
import 'package:handle_hero/utils/my_images.dart';
import 'package:handle_hero/widgets/treasure_ui.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({
    super.key,
    required this.userId,
    required this.userName,
  });

  final String userId;
  final String userName;

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  final _idController = TextEditingController();
  final _requests = FirebaseFirestore.instance.collection('friend_requests');
  DocumentSnapshot<Map<String, dynamic>>? _result;
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _incoming = [];
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _outgoing = [];
  String? _message;
  String? _dataError;
  bool _searching = false;
  bool _submitting = false;
  bool _loadingData = true;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  Future<void> _loadRequests() async {
    setState(() {
      _loadingData = true;
      _dataError = null;
    });
    try {
      final results = await Future.wait([
        _requests.where('recipientId', isEqualTo: widget.userId).get(),
        _requests.where('senderId', isEqualTo: widget.userId).get(),
      ]);
      if (!mounted) return;
      setState(() {
        _incoming = results[0].docs
            .toList();
        _outgoing = results[1].docs
            .toList();
        _loadingData = false;
      });
    } on FirebaseException catch (error) {
      if (!mounted) return;
      setState(() {
        _dataError = _firestoreError(error);
        _loadingData = false;
      });
    }
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
        _message = result.exists
            ? null
            : 'No player profile found. Ask them to log in once.';
      });
    } on FirebaseException catch (error) {
      if (!mounted) return;
      setState(() => _message = _firestoreError(error));
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  Future<void> _sendRequest(String friendId, String friendName) async {
    setState(() => _submitting = true);
    final requestId = '${widget.userId}_$friendId';
    try {
      final existing = await _requests.doc(requestId).get();
      final isAlreadyFriend = [
        ..._incoming,
        ..._outgoing,
      ].any((request) =>
          request.data()['status'] == 'accepted' &&
          (request.data()['senderId'] == friendId ||
              request.data()['recipientId'] == friendId));
      if (isAlreadyFriend ||
          (existing.exists && existing.data()?['status'] == 'accepted')) {
        if (mounted) setState(() => _message = 'You are already friends.');
        return;
      }
      final reversePending = _incoming.any(
        (request) =>
            request.data()['senderId'] == friendId &&
            request.data()['status'] == 'pending',
      );
      if (reversePending) {
        if (mounted) {
          setState(() => _message = 'They already sent you a request. Check below.');
        }
        return;
      }
      if (existing.exists && existing.data()?['status'] == 'pending') {
        if (mounted) setState(() => _message = 'You already sent a request.');
        return;
      }
      if (existing.exists && existing.data()?['status'] == 'declined') {
        await existing.reference.delete();
      }
      await _requests.doc(requestId).set({
        'senderId': widget.userId,
        'senderName': widget.userName,
        'recipientId': friendId,
        'recipientName': friendName,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        setState(() {
          _result = null;
          _idController.clear();
          _message = 'Friend request sent. They need to accept it.';
        });
        await _loadRequests();
      }
    } on FirebaseException catch (error) {
      if (mounted) setState(() => _message = _firestoreError(error));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _respondToRequest(
    QueryDocumentSnapshot<Map<String, dynamic>> request,
    String status,
  ) async {
    setState(() => _submitting = true);
    try {
      await request.reference.update({'status': status});
      await _loadRequests();
    } on FirebaseException catch (error) {
      if (mounted) setState(() => _dataError = _firestoreError(error));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _sendGift(String recipientId) async {
    setState(() => _submitting = true);
    final senderRef = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId);
    final recipientRef = FirebaseFirestore.instance
        .collection('users')
        .doc(recipientId);
    final dailyGiftRef = senderRef.collection('dailyGifts').doc(recipientId);
    final giftRef = FirebaseFirestore.instance.collection('coin_gifts').doc();
    try {
      final newBalance = await FirebaseFirestore.instance
          .runTransaction<int>((transaction) async {
            final sender = await transaction.get(senderRef);
            final recipient = await transaction.get(recipientRef);
            final previousGift = await transaction.get(dailyGiftRef);
            if (!sender.exists || !recipient.exists) {
              throw StateError('profile-not-found');
            }
            final lastSentAt = previousGift.data()?['lastSentAt'];
            if (lastSentAt is Timestamp &&
                DateTime.now().difference(lastSentAt.toDate()) <
                    const Duration(days: 1)) {
              throw StateError('already-sent');
            }
            final senderCoins =
                (sender.data()?['coins'] as num?)?.toInt() ?? 100;
            final recipientCoins =
                (recipient.data()?['coins'] as num?)?.toInt() ?? 100;
            if (senderCoins < 10) throw StateError('not-enough-coins');
            transaction.set(
              senderRef,
              {'coins': senderCoins - 10},
              SetOptions(merge: true),
            );
            transaction.set(
              recipientRef,
              {'coins': recipientCoins + 10},
              SetOptions(merge: true),
            );
            transaction.set(dailyGiftRef, {
              'amount': 10,
              'giftId': giftRef.id,
              'lastSentAt': FieldValue.serverTimestamp(),
            });
            transaction.set(giftRef, {
              'senderId': widget.userId,
              'recipientId': recipientId,
              'senderName': widget.userName,
              'amount': 10,
              'seen': false,
              'createdAt': FieldValue.serverTimestamp(),
            });
            return senderCoins - 10;
          });
      if (!mounted) return;
      context.read<HomeBloc>().add(
        CoinsBalanceSynced(widget.userId, newBalance),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You sent 10 coins to your friend.')),
      );
    } on StateError catch (error) {
      if (!mounted) return;
      final message = switch (error.message) {
        'already-sent' => 'You already sent this friend a gift today.',
        'not-enough-coins' => 'You need at least 10 coins to send a gift.',
        _ => 'Could not send the gift. Player profile not found.',
      };
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } on FirebaseException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_firestoreError(error))),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  String _firestoreError(FirebaseException error) => switch (error.code) {
    'permission-denied' => 'Firestore rules blocked this action. Publish the updated firestore.rules.',
    'failed-precondition' || 'not-found' => 'Firestore database is not available yet.',
    'unauthenticated' => 'Log in again, then retry.',
    'unavailable' => 'Firestore is unavailable. Check your connection.',
    _ => 'Firestore error: ${error.code}.',
  };

  @override
  Widget build(BuildContext context) {
    final accepted = [
      ..._incoming.where((request) => request.data()['status'] == 'accepted'),
      ..._outgoing.where((request) => request.data()['status'] == 'accepted'),
    ];
    final pendingIncoming = _incoming
        .where((request) => request.data()['status'] == 'pending')
        .toList();
    final pendingOutgoing = _outgoing
        .where((request) => request.data()['status'] == 'pending')
        .toList();
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
                        submitting: _submitting,
                        onSend: () => _sendRequest(
                          _result!.id,
                          (_result!.data()?['name'] as String?) ?? 'Player',
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (_dataError != null) ...[
                const SizedBox(height: 12),
                Text(_dataError!, style: const TextStyle(color: Color(0xFFE3D9AA), fontSize: 11)),
              ],
              const SizedBox(height: 20),
              if (_loadingData)
                const Center(child: CircularProgressIndicator())
              else ...[
                _RequestSection(
                  title: 'FRIEND REQUESTS',
                  emptyText: 'No incoming requests.',
                  requests: pendingIncoming,
                  currentUserId: widget.userId,
                  submitting: _submitting,
                  onAccept: (request) => _respondToRequest(request, 'accepted'),
                  onDecline: (request) => _respondToRequest(request, 'declined'),
                  incoming: true,
                ),
                const SizedBox(height: 16),
                _RequestSection(
                  title: 'SENT REQUESTS',
                  emptyText: 'No pending requests sent.',
                  requests: pendingOutgoing,
                  currentUserId: widget.userId,
                  submitting: true,
                  onAccept: (_) {},
                  onDecline: (_) {},
                  incoming: false,
                ),
                const SizedBox(height: 16),
                _RequestSection(
                  title: 'YOUR FRIENDS',
                  emptyText: 'Accepted friends will appear here.',
                  requests: accepted,
                  currentUserId: widget.userId,
                  submitting: _submitting,
                  onAccept: (_) {},
                  onDecline: (_) {},
                  incoming: false,
                  accepted: true,
                  onGift: (friendId) => _sendGift(friendId),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _RequestSection extends StatelessWidget {
  const _RequestSection({
    required this.title,
    required this.emptyText,
    required this.requests,
    required this.currentUserId,
    required this.submitting,
    required this.onAccept,
    required this.onDecline,
    required this.incoming,
    this.accepted = false,
    this.onGift,
  });

  final String title;
  final String emptyText;
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> requests;
  final String currentUserId;
  final bool submitting;
  final void Function(QueryDocumentSnapshot<Map<String, dynamic>>) onAccept;
  final void Function(QueryDocumentSnapshot<Map<String, dynamic>>) onDecline;
  final bool incoming;
  final bool accepted;
  final void Function(String friendId)? onGift;

  @override
  Widget build(BuildContext context) => TreasureWindow(
    title: title,
    child: requests.isEmpty
        ? Text(emptyText, style: const TextStyle(color: Color(0xFFE3D9AA), fontSize: 11))
        : Column(
            children: [
              for (final request in requests)
                _RequestRow(
                  request: request,
                  currentUserId: currentUserId,
                  submitting: submitting,
                  incoming: incoming,
                  accepted: accepted,
                  onGift: onGift,
                  onAccept: () => onAccept(request),
                  onDecline: () => onDecline(request),
                ),
            ],
          ),
  );
}

class _RequestRow extends StatelessWidget {
  const _RequestRow({
    required this.request,
    required this.currentUserId,
    required this.submitting,
    required this.incoming,
    required this.accepted,
    this.onGift,
    required this.onAccept,
    required this.onDecline,
  });

  final QueryDocumentSnapshot<Map<String, dynamic>> request;
  final String currentUserId;
  final bool submitting;
  final bool incoming;
  final bool accepted;
  final void Function(String friendId)? onGift;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) {
    final data = request.data();
    final isSender = data['senderId'] == currentUserId;
    final name = isSender ? data['recipientName'] : data['senderName'];
    final id = isSender ? data['recipientId'] : data['senderId'];
    final friendId = id as String? ?? '';
    final displayName = (name as String?)?.isNotEmpty == true
        ? name as String
        : 'Player';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.person_outline, color: Color(0xFFD1C27E)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(displayName, style: const TextStyle(color: Colors.white, fontSize: 11)),
                Text(friendId, style: const TextStyle(color: Color(0xFFE3D9AA), fontSize: 8)),
              ],
            ),
          ),
          if (accepted)
            StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(currentUserId)
                  .collection('dailyGifts')
                  .doc(friendId)
                  .snapshots(),
              builder: (context, snapshot) {
                final lastSent = snapshot.data?.data()?['lastSentAt'];
                final ready = lastSent is! Timestamp ||
                    DateTime.now().difference(lastSent.toDate()) >=
                        const Duration(days: 1);
                return TextButton(
                  onPressed: submitting || !ready || onGift == null || friendId.isEmpty
                      ? null
                      : () => onGift!(friendId),
                  child: Text(
                    ready ? 'GIFT 10' : 'SENT',
                    style: const TextStyle(fontSize: 8),
                  ),
                );
              },
            )
          else if (incoming) ...[
            TextButton(
              onPressed: submitting ? null : onAccept,
              child: const Text('ACCEPT', style: TextStyle(fontSize: 8)),
            ),
            TextButton(
              onPressed: submitting ? null : onDecline,
              child: const Text('DECLINE', style: TextStyle(fontSize: 8)),
            ),
          ] else
            const Text('PENDING', style: TextStyle(color: Color(0xFFE3D9AA), fontSize: 8)),
        ],
      ),
    );
  }
}

class _PlayerResult extends StatelessWidget {
  const _PlayerResult({
    required this.name,
    required this.id,
    required this.submitting,
    required this.onSend,
  });

  final String name;
  final String id;
  final bool submitting;
  final VoidCallback onSend;

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
        onPressed: submitting ? null : onSend,
        child: Text(submitting ? 'SENDING...' : 'REQUEST', style: const TextStyle(fontSize: 10)),
      ),
    ],
  );
}
