import 'package:client_leger/models/user.dart';
import 'package:get/get.dart';

import 'users_service.dart';

class UserService extends GetxService {
  final user = Rxn<User>();
  final pendingRequest = <dynamic>[].obs;
  final friends = <dynamic>[].obs;

  bool isCurrentUser(String userId) {
    return user.value!.id == userId;
  }
}