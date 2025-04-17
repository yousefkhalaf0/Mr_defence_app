import 'package:supabase_flutter/supabase_flutter.dart';

class AuthServices {
  static SupabaseClient client() {
    final supabase = Supabase.instance.client;
    return supabase;
  }
}
