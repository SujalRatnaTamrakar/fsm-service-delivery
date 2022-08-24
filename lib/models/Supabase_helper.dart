import 'package:postgres/postgres.dart';
import 'package:postgrest/postgrest.dart';
import 'package:supabase/supabase.dart';

const String kSupabaseURL = 'https://supabase-url-here';
const String kSupabaseKEY =
    'supabase-key-here';
final supabase = SupabaseClient(kSupabaseURL, kSupabaseKEY);
final postGrest = PostgrestClient('$kSupabaseURL/rest/v1',
    headers: {'apikey': kSupabaseKEY}, schema: 'public,extensions');
