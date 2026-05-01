import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amora/core/services/supabase_service.dart';

final supabaseProvider = Provider((ref) => SupabaseService());

final supabaseClientProvider = Provider(
  (ref) => ref.watch(supabaseProvider).client,
);

final authStateProvider = StreamProvider(
  (ref) => ref.watch(supabaseProvider).auth.onAuthStateChange,
);
