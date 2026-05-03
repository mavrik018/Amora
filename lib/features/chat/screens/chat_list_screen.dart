import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/connection_provider.dart';
import 'chat_thread_screen.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final connectionRequestsAsync = ref.watch(connectionRequestsStreamProvider);
    final acceptedConnectionsAsync = ref.watch(acceptedConnectionsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        centerTitle: false,
      ),
      body: CustomScrollView(
        slivers: [
          // Connection Requests Section
          connectionRequestsAsync.when(
            data: (requests) {
              if (requests.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
              return SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      child: Text(
                        'Connection Requests',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 120.h,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: requests.length,
                        itemBuilder: (context, index) {
                          final req = requests[index];
                          final sender = req.sender;
                          return Padding(
                            padding: EdgeInsets.only(left: 16.w, right: index == requests.length - 1 ? 16.w : 0),
                            child: Column(
                              children: [
                                Stack(
                                  children: [
                                    CircleAvatar(
                                      radius: 35.r,
                                      backgroundImage: sender?.photos.isNotEmpty == true 
                                          ? NetworkImage(sender!.photos.first) 
                                          : null,
                                      child: sender?.photos.isNotEmpty == true ? null : const Icon(Icons.person),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () => ref.read(connectionProvider).acceptRequest(req.id),
                                              child: const Icon(Icons.check_circle, color: Colors.green, size: 24),
                                            ),
                                            GestureDetector(
                                              onTap: () => ref.read(connectionProvider).rejectRequest(req.id),
                                              child: const Icon(Icons.cancel, color: Colors.red, size: 24),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8.h),
                                Text(sender?.fullName ?? 'Unknown', style: TextStyle(fontSize: 12.sp)),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const Divider(),
                  ],
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(child: LinearProgressIndicator()),
            error: (e, st) => SliverToBoxAdapter(child: Text('Error: $e')),
          ),
          
          // Ongoing Chats Section
          acceptedConnectionsAsync.when(
            data: (connections) {
              if (connections.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Text('No messages yet.', style: theme.textTheme.bodyLarge),
                  ),
                );
              }
              final myId = Supabase.instance.client.auth.currentUser!.id;
              
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final conn = connections[index];
                    final otherProfile = conn.senderId == myId ? conn.receiver : conn.sender;
                    return ListTile(
                      leading: CircleAvatar(
                        radius: 25.r,
                        backgroundImage: otherProfile?.photos.isNotEmpty == true 
                            ? NetworkImage(otherProfile!.photos.first) 
                            : null,
                        child: otherProfile?.photos.isNotEmpty == true ? null : const Icon(Icons.person),
                      ),
                      title: Text(otherProfile?.fullName ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text('Tap to open chat...'), // Ideally we'd fetch the latest message
                      onTap: () {
                        if (otherProfile != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatThreadScreen(otherProfile: otherProfile),
                            ),
                          );
                        }
                      },
                    );
                  },
                  childCount: connections.length,
                ),
              );
            },
            loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
            error: (e, st) => SliverFillRemaining(child: Center(child: Text('Error: $e'))),
          ),
        ],
      ),
    );
  }
}
