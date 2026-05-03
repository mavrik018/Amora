import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../providers/admin_provider.dart';
import '../../../core/services/auth_service.dart';
import '../widgets/admin/admin_empty_state.dart';
import '../widgets/admin/admin_report_card.dart';
import '../widgets/admin/admin_verification_card.dart';

class AdminScreen extends ConsumerWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final reportsAsync = ref.watch(reportsStreamProvider);
    final verificationsAsync = ref.watch(pendingVerificationsProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F4F8),
        appBar: AppBar(
          title: Text(
            'Admin Panel',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          bottom: TabBar(
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: theme.colorScheme.primary,
            indicatorWeight: 3,
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Reports'),
                    reportsAsync.maybeWhen(
                      data: (reports) => reports.isNotEmpty
                          ? Container(
                              margin: EdgeInsets.only(left: 8.w),
                              padding: EdgeInsets.all(6.r),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${reports.length}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                      orElse: () => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Verifications'),
                    verificationsAsync.maybeWhen(
                      data: (requests) => requests.isNotEmpty
                          ? Container(
                              margin: EdgeInsets.only(left: 8.w),
                              padding: EdgeInsets.all(6.r),
                              decoration: const BoxDecoration(
                                color: Colors.orange,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${requests.length}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                      orElse: () => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: IconButton(
                onPressed: () async => await AuthService.logout(),
                icon: Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    Icons.logout_rounded,
                    color: theme.colorScheme.error,
                    size: 18.r,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: TabBarView(
          children: [
            // Reports Tab
            reportsAsync.when(
              data: (reports) {
                if (reports.isEmpty) {
                  return const AdminEmptyState(
                    title: 'All clear!',
                    subtitle: 'No pending reports to review',
                    icon: Icons.check_rounded,
                    color: Colors.green,
                  );
                }
                return ListView.builder(
                  padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 32.h),
                  itemCount: reports.length,
                  itemBuilder: (context, index) =>
                      AdminReportCard(report: reports[index]),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Error: $e')),
            ),
            // Verifications Tab
            verificationsAsync.when(
              data: (requests) {
                if (requests.isEmpty) {
                  return const AdminEmptyState(
                    title: 'No Requests',
                    subtitle: 'No pending identity verifications',
                    icon: Icons.verified_user_rounded,
                    color: Colors.blue,
                  );
                }
                return ListView.builder(
                  padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 32.h),
                  itemCount: requests.length,
                  itemBuilder: (context, index) =>
                      AdminVerificationCard(request: requests[index]),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Error: $e')),
            ),
          ],
        ),
      ),
    );
  }
}
