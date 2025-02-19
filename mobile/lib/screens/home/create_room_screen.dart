import 'package:client_leger/services/room_service.dart';
import 'package:client_leger/services/user_service.dart';
import 'package:client_leger/services/websocket_service.dart';
import 'package:client_leger/widgets/input_field.dart';
import 'package:client_leger/widgets/search_bar.dart';
import 'package:client_leger/widgets/user_list.dart';
import 'package:flutter/material.dart';
import 'package:form_validator/form_validator.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

class CreateRoomScreen extends StatelessWidget {
  CreateRoomScreen({Key? key}) : super(key: key);

  final UserService _userService = Get.find();
  final WebsocketService _websocketService = Get.find();
  final RoomService roomService = Get.find();

  final GlobalKey<FormState> _newRoomFormKey = GlobalKey<FormState>();

  final newRoomController = TextEditingController();

  RxString searchInput = ''.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Form(
            key: _newRoomFormKey,
            child: Column(
              children: [
                Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Text('create-room-screen.canal'.tr,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 30)),
                    )),
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: InputField(
                        controller: newRoomController,
                        keyboardType: TextInputType.text,
                        placeholder: 'create-room-screen.placeholder'.tr,
                        validator: ValidationBuilder(
                                requiredMessage:
                                    'create-room-screen.placeholder-validation'
                                        .tr)
                            .build()),
                  ),
                ),
                SearchBar(searchInput, 'friends'),
                Expanded(
                    child: Obx(() => UserList(
                        mode: 'checkList',
                        inputSearch: searchInput,
                        items: _userService.friends.value))),
                Gap(8),
                ElevatedButton.icon(
                  onPressed: () {
                    if (_newRoomFormKey.currentState!.validate()) {
                      _websocketService.createRoom(newRoomController.text,
                          userIds:
                              List<String>.from(roomService.newRoomUserIds));
                      newRoomController.text = '';
                    }
                  },
                  style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Colors.black))),
                  icon: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.create,
                      size: 50,
                    ),
                  ),
                  label: Text('create-room-screen.create-canal'.tr), // <-- Text
                ),
                const Gap(20)
              ],
            )),
      ),
    );
  }
}
