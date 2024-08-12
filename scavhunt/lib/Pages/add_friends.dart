// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddFriendsPage extends StatefulWidget {
  const AddFriendsPage({Key? key}) : super(key: key);

  @override
  State<AddFriendsPage> createState() => _AddFriendsPageState();
}

class _AddFriendsPageState extends State<AddFriendsPage> {
  final TextEditingController _searchController = TextEditingController();
  User? _searchedUser;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Center(child: Text('Please log in'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Enter User ID',
                suffixIcon: IconButton(
                  onPressed: () async {
                    final searchedUserId = _searchController.text.trim();
                    if (searchedUserId.isNotEmpty) {
                      _searchUser(searchedUserId);
                    }
                  },
                  icon: const Icon(Icons.search),
                ),
              ),
            ),
          ),
          if (_searchedUser != null)
            ListTile(
              title: Text(_searchedUser!.displayName),
              subtitle: Text('User ID: ${_searchedUser!.id}'),
              trailing: ElevatedButton(
                onPressed: () {
                  _sendFriendRequest(currentUser.uid, _searchedUser!.id);
                },
                child: const Text('Add Friend'),
              ),
            ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('friend_requests')
                  .where('to', isEqualTo: currentUser.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                final friendRequests = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: friendRequests.length,
                  itemBuilder: (context, index) {
                    final requestData =
                        friendRequests[index].data() as Map<String, dynamic>;
                    final fromUserId = requestData['from'];

                    return FutureBuilder<DocumentSnapshot>(
                      future: _firestore.collection('users').doc(fromUserId).get(),
                      builder: (context, userSnapshot) {
                        if (userSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return ListTile(
                            title: Text('Loading...'),
                          );
                        }

                        if (userSnapshot.hasError) {
                          return ListTile(
                            title: Text('Error: ${userSnapshot.error}'),
                          );
                        }

                        final userData =
                            userSnapshot.data!.data() as Map<String, dynamic>;

                        return ListTile(
                          title: Text(userData['displayName'] ?? 'No Name'),
                          subtitle: Text('User ID: $fromUserId'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () {
                                  _acceptFriendRequest(
                                      fromUserId, currentUser.uid);
                                },
                                icon: Icon(Icons.check, color: Colors.green),
                              ),
                              IconButton(
                                onPressed: () {
                                  _rejectFriendRequest(
                                      fromUserId, currentUser.uid);
                                },
                                icon: Icon(Icons.close, color: Colors.red),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('friendships')
                  .where('users', arrayContains: currentUser.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                final friendships = snapshot.data!.docs;
                final friendIds = friendships.fold<List<String>>([], (previous, element) {
                  final data = element.data() as Map<String, dynamic>;
                  final users = List<String>.from(data['users']);
                  return [...previous, ...users.where((id) => id != currentUser.uid)];
                });

                return ListView.builder(
                  itemCount: friendIds.length,
                  itemBuilder: (context, index) {
                    final friendId = friendIds[index];

                    return FutureBuilder<DocumentSnapshot>(
                      future: _firestore.collection('users').doc(friendId).get(),
                      builder: (context, userSnapshot) {
                        if (userSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return ListTile(
                            title: Text('Loading...'),
                          );
                        }

                        if (userSnapshot.hasError) {
                          return ListTile(
                            title: Text('Error: ${userSnapshot.error}'),
                          );
                        }

                        final userData =
                            userSnapshot.data!.data() as Map<String, dynamic>;

                        return ListTile(
                          title: Text(userData['displayName'] ?? 'No Name'),
                          subtitle: Text('User ID: $friendId'),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _searchUser(String userId) async {
    try {
      final userSnapshot =
          await _firestore.collection('users').doc(userId).get();

      if (userSnapshot.exists) {
        setState(() {
          _searchedUser = User(
            id: userSnapshot.id,
            displayName: userSnapshot['displayName'] ?? 'No Name',
          );
        });
      } else {
        setState(() {
          _searchedUser = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User not found!')),
        );
      }
    } catch (e) {
      print('Error searching for user: $e');
    }
  }

  Future<void> _sendFriendRequest(String fromUserId, String toUserId) async {
    try {
      final requestDoc = _firestore
          .collection('friend_requests')
          .doc('$fromUserId-$toUserId');
      final docSnapshot = await requestDoc.get();

      if (!docSnapshot.exists) {
        await requestDoc.set({
          'from': fromUserId,
          'to': toUserId,
          'status': 'pending', // Add a status field
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Friend request sent!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Friend request already sent!')),
        );
      }
    } catch (e) {
      print('Error sending friend request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send friend request!')),
      );
    }
  }

  Future<void> _acceptFriendRequest(
      String fromUserId, String toUserId) async {
    try {
      // Create a new friendship document
      final friendshipDocRef =
          _firestore.collection('friendships').doc(); // Auto-generate ID
      await friendshipDocRef.set({
        'users': [fromUserId, toUserId],
      });

      // Delete the friend request
      await _firestore
          .collection('friend_requests')
          .doc('$fromUserId-$toUserId')
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Friend request accepted!')),
      );
    } catch (e) {
      print('Error accepting friend request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to accept friend request!')),
      );
    }
  }

  Future<void> _rejectFriendRequest(
      String fromUserId, String toUserId) async {
    try {
      await _firestore
          .collection('friend_requests')
          .doc('$fromUserId-$toUserId')
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Friend request rejected!')),
      );
    } catch (e) {
      print('Error rejecting friend request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to reject friend request!')),
      );
    }
  }
}

class User {
  final String id;
  final String displayName;

  User({required this.id, required this.displayName});
}
