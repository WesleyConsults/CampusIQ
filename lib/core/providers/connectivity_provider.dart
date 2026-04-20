import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusiq/core/services/connectivity_service.dart';

final isOnlineProvider = FutureProvider<bool>((ref) async {
  return ConnectivityService.isOnline();
});
