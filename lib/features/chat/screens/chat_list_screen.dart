import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/connection_provider.dart';
import 'chat_thread_screen.dart';
import 'package:amora/features/discover/providers/profiles.dart';
import '../providers/chat_provider.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final connectionRequestsAsync = ref.watch(connectionRequestsStreamProvider);
    final acceptedConnectionsAsync = ref.watch(
      acceptedConnectionsStreamProvider,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F5F2),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text('Messages', style: theme.textTheme.headlineSmall),
        centerTitle: false,
      ),
      body: CustomScrollView(
        slivers: [
          connectionRequestsAsync.when(
            data: (requests) {
              if (requests.isEmpty) {
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              }
              return SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 12.h),
                      child: Row(
                        children: [
                          Container(
                            width: 4.w,
                            height: 16.h,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8896A),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'New Requests',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF6B6B6B),
                              letterSpacing: 0.8,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8896A),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${requests.length}',
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 110.h,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        itemCount: requests.length,
                        itemBuilder: (context, index) {
                          final req = requests[index];
                          final sender = req.sender;
                          return Padding(
                            padding: EdgeInsets.only(right: 12.w),
                            child: Column(
                              children: [
                                Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: const Color(0xFFE8896A),
                                          width: 2.5,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(2),
                                        child: CircleAvatar(
                                          radius: 30.r,
                                          backgroundColor: const Color(
                                            0xFFEDE8E3,
                                          ),
                                          backgroundImage:
                                              sender?.photos.isNotEmpty == true
                                              ? NetworkImage(
                                                  sender!.photos.first,
                                                )
                                              : null,
                                          child:
                                              sender?.photos.isNotEmpty == true
                                              ? null
                                              : Icon(
                                                  Icons.person_outline,
                                                  color: const Color(
                                                    0xFFAAAAAA,
                                                  ),
                                                  size: 22.r,
                                                ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: -2,
                                      right: -2,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          _ActionButton(
                                            icon: Icons.check,
                                            color: const Color(0xFF4CAF82),
                                            onTap: () async {
                                              await ref
                                                  .read(connectionProvider)
                                                  .acceptRequest(req.id);
                                              ref.invalidate(
                                                otherProfilesProvider,
                                              );
                                            },
                                          ),
                                          SizedBox(width: 2.w),
                                          _ActionButton(
                                            icon: Icons.close,
                                            color: const Color(0xFFE57373),
                                            onTap: () async {
                                              await ref
                                                  .read(connectionProvider)
                                                  .rejectRequest(req.id);
                                              ref.invalidate(
                                                otherProfilesProvider,
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 6.h),
                                Text(
                                  sender!.fullName.split(' ').first,
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF3A3A3A),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Divider(
                        color: const Color(0xFFE0DAD4),
                        thickness: 1,
                        height: 1,
                      ),
                    ),
                    SizedBox(height: 8.h),
                  ],
                ),
              );
            },
            loading: () => SliverToBoxAdapter(
              child: LinearProgressIndicator(
                color: const Color(0xFFE8896A),
                backgroundColor: const Color(0xFFF0EBE6),
              ),
            ),
            error: (e, st) => SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Text(
                  'Error: $e',
                  style: const TextStyle(color: Color(0xFFE57373)),
                ),
              ),
            ),
          ),

          acceptedConnectionsAsync.maybeWhen(
            data: (connections) {
              if (connections.isEmpty) {
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              }
              return SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 8.h),
                  child: Row(
                    children: [
                      Container(
                        width: 4.w,
                        height: 16.h,
                        decoration: BoxDecoration(
                          color: const Color(0xFF6B9ED2),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Conversations',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF6B6B6B),
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            orElse: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
          ),

          acceptedConnectionsAsync.when(
            data: (connections) {
              if (connections.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 48.r,
                          color: const Color(0xFFCCC7C0),
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          'No conversations yet',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: const Color(0xFFAAAAAA),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Connect with someone to start chatting',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: const Color(0xFFBBBBBB),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final myId = Supabase.instance.client.auth.currentUser!.id;

              return SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final conn = connections[index];
                    final otherProfile = conn.senderId == myId
                        ? conn.receiver
                        : conn.sender;

                    return Padding(
                      padding: EdgeInsets.only(bottom: 6.h),
                      child: Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            if (otherProfile != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatThreadScreen(
                                    otherProfile: otherProfile,
                                  ),
                                ),
                              );
                            }
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 14.w,
                              vertical: 12.h,
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 26.r,
                                  backgroundColor: const Color(0xFFEDE8E3),
                                  backgroundImage:
                                      otherProfile?.photos.isNotEmpty == true
                                      ? NetworkImage(otherProfile!.photos.first)
                                      : null,
                                  child: otherProfile?.photos.isNotEmpty == true
                                      ? null
                                      : Icon(
                                          Icons.person_outline,
                                          color: const Color(0xFFAAAAAA),
                                          size: 20.r,
                                        ),
                                ),
                                SizedBox(width: 12.w),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        otherProfile?.fullName ?? 'Unknown',
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF1A1A1A),
                                        ),
                                      ),
                                      SizedBox(height: 3.h),
                                      if (otherProfile != null)
                                        Consumer(
                                          builder: (context, ref, child) {
                                            final latestMsgAsync = ref.watch(
                                              latestMessageProvider(
                                                otherProfile.id,
                                              ),
                                            );
                                            return latestMsgAsync.when(
                                              data: (msg) {
                                                final isUnread =
                                                    msg != null &&
                                                    !msg.isRead &&
                                                    msg.receiverId == myId;
                                                return Text(
                                                  msg?.content ??
                                                      'No messages yet',
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 13.sp,
                                                    color: isUnread
                                                        ? const Color(
                                                            0xFF3A3A3A,
                                                          )
                                                        : const Color(
                                                            0xFFAAAAAA,
                                                          ),
                                                    fontWeight: isUnread
                                                        ? FontWeight.w600
                                                        : FontWeight.normal,
                                                  ),
                                                );
                                              },
                                              loading: () => Text(
                                                '...',
                                                style: TextStyle(
                                                  fontSize: 13.sp,
                                                  color: const Color(
                                                    0xFFCCCCCC,
                                                  ),
                                                ),
                                              ),
                                              error: (_, __) =>
                                                  const SizedBox.shrink(),
                                            );
                                          },
                                        ),
                                    ],
                                  ),
                                ),

                                if (otherProfile != null)
                                  Consumer(
                                    builder: (context, ref, child) {
                                      final unreadCountAsync = ref.watch(
                                        unreadCountProvider(otherProfile.id),
                                      );
                                      return unreadCountAsync.when(
                                        data: (count) => count > 0
                                            ? Container(
                                                width: 22.w,
                                                height: 22.w,
                                                decoration: const BoxDecoration(
                                                  color: Color(0xFFE8896A),
                                                  shape: BoxShape.circle,
                                                ),
                                                alignment: Alignment.center,
                                                child: Text(
                                                  count > 99 ? '99+' : '$count',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10.sp,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              )
                                            : const SizedBox.shrink(),
                                        loading: () => const SizedBox.shrink(),
                                        error: (_, __) =>
                                            const SizedBox.shrink(),
                                      );
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }, childCount: connections.length),
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFFE8896A)),
              ),
            ),
            error: (e, st) => SliverFillRemaining(
              child: Center(
                child: Text(
                  'Error: $e',
                  style: const TextStyle(color: Color(0xFFE57373)),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(child: SizedBox(height: 24.h)),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.35),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 13),
      ),
    );
  }
}
