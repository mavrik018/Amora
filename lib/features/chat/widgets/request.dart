import 'package:amora/features/chat/models/connection_request.dart';
import 'package:amora/features/chat/providers/connection_provider.dart';
import 'package:amora/features/chat/widgets/action_button.dart';
import 'package:amora/features/discover/providers/profiles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConnectionRequestItem extends StatefulWidget {
  const ConnectionRequestItem({super.key, required this.req});
  final ConnectionRequest req;

  @override
  State<ConnectionRequestItem> createState() => _ConnectionRequestItemState();
}

class _ConnectionRequestItemState extends State<ConnectionRequestItem> {
  bool _isAccepting = false;
  bool _isRejecting = false;

  @override
  Widget build(BuildContext context) {
    final sender = widget.req.sender;
    return Consumer(
      builder: (context, ref, child) {
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
                        backgroundColor: const Color(0xFFEDE8E3),
                        backgroundImage: sender?.photos.isNotEmpty == true
                            ? NetworkImage(sender!.photos.first)
                            : null,
                        child: sender?.photos.isNotEmpty == true
                            ? null
                            : Icon(
                                Icons.person_outline,
                                color: const Color(0xFFAAAAAA),
                                size: 22.r,
                              ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -4,
                    right: -8,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ActionButton(
                          icon: Icons.check,
                          color: const Color(0xFF4CAF82),
                          isLoading: _isAccepting,
                          onTap: () async {
                            if (_isAccepting || _isRejecting) return;
                            setState(() => _isAccepting = true);
                            try {
                              await ref
                                  .read(connectionProvider)
                                  .acceptRequest(widget.req.id);
                              ref.invalidate(otherProfilesProvider);
                            } catch (e) {
                              if (mounted) {
                                setState(() => _isAccepting = false);
                              }
                            }
                          },
                        ),
                        SizedBox(width: 4.w),
                        ActionButton(
                          icon: Icons.close,
                          color: const Color(0xFFE57373),
                          isLoading: _isRejecting,
                          onTap: () async {
                            if (_isAccepting || _isRejecting) return;
                            setState(() => _isRejecting = true);
                            try {
                              await ref
                                  .read(connectionProvider)
                                  .rejectRequest(widget.req.id);
                              ref.invalidate(otherProfilesProvider);
                            } catch (e) {
                              if (mounted) {
                                setState(() => _isRejecting = false);
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
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
    );
  }
}
