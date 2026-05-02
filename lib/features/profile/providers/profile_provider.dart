import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/profile_repository.dart';
import '../../../core/providers/supabase_provider.dart';
import '../models/profile_model.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return ProfileRepository(client);
});

final userProfileProvider = FutureProvider<ProfileModel?>((ref) async {
  // This ensures the provider re-runs whenever the auth state changes (login/logout)
  ref.watch(authStateProvider);
  
  final repository = ref.watch(profileRepositoryProvider);
  final client = ref.watch(supabaseClientProvider);
  final userId = client.auth.currentUser?.id;

  if (userId == null) return null;

  return repository.getProfile(userId);
});
