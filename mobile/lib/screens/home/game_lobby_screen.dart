import 'package:client_leger/api/api_repository.dart';
import 'package:client_leger/screens/floating_chat_screen.dart';
import 'package:client_leger/services/room_service.dart';
import 'package:client_leger/services/settings_service.dart';
import 'package:client_leger/services/user_service.dart';
import 'package:client_leger/services/users_service.dart';
import 'package:client_leger/services/websocket_service.dart';
import 'package:client_leger/utils/dialog_helper.dart';
import 'package:client_leger/widgets/app_sidebar.dart';
import 'package:client_leger/widgets/user_list.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:sidebarx/sidebarx.dart';

import '../../services/game_service.dart';

class GameLobbyScreen extends StatelessWidget {
  GameLobbyScreen({Key? key}) : super(key: key);

  final sideBarController =
      SidebarXController(selectedIndex: 0, extended: true);

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final String gameMode = Get.arguments;
  final GameService _gameService = Get.find();
  final WebsocketService _websocketService = Get.find();
  final RoomService _roomService = Get.find();
  final UserService _userService = Get.find();
  final UsersService _usersService = Get.find();
  final ApiRepository _apiRepository = Get.find();

  RxBool selectedChatRoom = false.obs;
  final SettingsService _settingsService = Get.find();

  @override
  Widget build(BuildContext context) {
    return Builder(
        builder: (BuildContext context) => Scaffold(
              resizeToAvoidBottomInset: true,
              drawerScrimColor: Colors.transparent,
              floatingActionButton: Wrap(
                  // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  spacing: 800,
                  children: [
                    // FloatingActionButton.extended(
                    //   heroTag: null,
                    //   onPressed: () {
                    //     _buildInviteFriendDialog();
                    //   },
                    //   backgroundColor: Color.fromARGB(255, 98, 0, 238),
                    //   foregroundColor: Colors.white,
                    //   autofocus: true,
                    //   focusElevation: 5,
                    //   label: Row(children: const [
                    //     Icon(
                    //       Icons.people_alt,
                    //     ),
                    //     Text("Inviter un ami")
                    //   ]),
                    // ),
                    FloatingActionButton(
                      heroTag: null,
                      onPressed: () {
                        _scaffoldKey.currentState?.openEndDrawer();
                      },
                      backgroundColor: Color.fromARGB(255, 98, 0, 238),
                      foregroundColor: Colors.white,
                      autofocus: true,
                      focusElevation: 5,
                      child: const Icon(
                        Icons.question_answer_rounded,
                      ),
                    ),
                  ]),
              key: _scaffoldKey,
              endDrawer: Drawer(child: Obx(() => _buildChatRoomsList())),
              body: Row(
                children: [
                  AppSideBar(controller: sideBarController),
                  Expanded(
                    child: _buildItems(
                      context,
                    ),
                  ),
                ],
              ),
            ));
  }

  Widget _buildItems(BuildContext context) {
    return AnimatedBuilder(
        animation: sideBarController,
        builder: (context, child) {
          return SingleChildScrollView(
            child: Center(
              child: SizedBox(
                  height: 610,
                  width: 600,
                  child: Obx(
                    () => Column(
                      children: [
                        Image(
                          image: _settingsService.getLogo(),
                        ),
                        const Gap(20),
                        _buildStartButton(context),
                        _buildUpperGap(),
                        _buildPendingJoinGameRequests(),
                        _buildLowerGap(),
                        Text(
                            gameMode == 'tournoi'
                                ? '${_gameService.currentTournamentUserIds.value!.length}/4 joueurs présents'
                                : '${_gameService.currentGameRoomUserIds.value!.length}/4 joueurs présents',
                            style: Theme.of(context).textTheme.headline6),
                      ],
                    ),
                  )),
            ),
          );
        });
  }

  Widget _buildUpperGap() {
    if (gameMode == 'tournoi' &&
        _gameService.pendingJoinTournamentRequestUserIds.value.isEmpty) {
      return Gap(Get.height / 5);
    } else if (gameMode != 'tournoi' &&
        _gameService.pendingJoinGameRequestUserIds.value.isEmpty) {
      return Gap(Get.height / 5);
    }
    return SizedBox();
  }

  Widget _buildLowerGap() {
    if (gameMode == 'tournoi' &&
        _gameService.pendingJoinTournamentRequestUserIds.value.isEmpty) {
      return Gap(200);
    } else if (gameMode != 'tournoi' &&
        _gameService.pendingJoinGameRequestUserIds.value.isEmpty) {
      return Gap(200);
    }
    return SizedBox();
  }

  Widget _buildStartButton(BuildContext context) {
    if (gameMode == 'tournoi') {
      if (_gameService.currentTournamentUserIds.value!.length >= 4 &&
          _gameService.isTournamentCreator()) {
        return ElevatedButton.icon(
          onPressed: () {
            _websocketService.startTournament(_gameService.currentTournamentId);
          },
          icon: const Icon(
            // <-- Icon
            Icons.play_arrow,
            size: 20,
          ),
          label: Text('Démarrer le tournoi'), // <-- Text
        );
      } else {
        return Text('En attente d\'autre joueurs... Veuillez patientez',
            style: Theme.of(context).textTheme.headline6);
      }
    } else {
      if (_gameService.currentGameRoomUserIds.value!.length >= 2 &&
          _gameService.isGameCreator()) {
        return ElevatedButton.icon(
          onPressed: () {
            _websocketService.startGame(_gameService.currentGameId);
          },
          icon: const Icon(
            // <-- Icon
            Icons.play_arrow,
            size: 20,
          ),
          label: Text('Démarrer la partie'), // <-- Text
        );
      } else {
        return Text('En attente d\'autre joueurs... Veuillez patientez',
            style: Theme.of(context).textTheme.headline6);
      }
    }
  }

  Widget _buildPendingJoinGameRequests() {
    if (gameMode == 'tournoi') {
      if (!_gameService.currentTournament.value!.isPrivate) {
        return CircularProgressIndicator(
            semanticsLabel:
                _gameService.currentTournament.value!.isPrivate.toString());
      } else if (_gameService.currentTournament.value!.creatorId !=
          _userService.user.value!.id) {
        return CircularProgressIndicator(
            semanticsLabel:
                _gameService.currentTournament.value!.isPrivate.toString());
      } else if (_gameService
          .pendingJoinTournamentRequestUserIds.value!.isEmpty) {
        return CircularProgressIndicator(
            semanticsLabel:
                _gameService.currentTournament.value!.isPrivate.toString());
      } else {
        return Expanded(
          child: ListView.builder(
              itemCount: _gameService
                  .pendingJoinTournamentRequestUserIds.value!.length,
              itemBuilder: (context, item) {
                final index = item;
                return _buildPendingRequest(_gameService
                    .pendingJoinTournamentRequestUserIds.value![index]);
              }),
        );
      }
    } else {
      if (!_gameService.currentGameInfo!.isPrivateGame) {
        return CircularProgressIndicator(
            semanticsLabel:
                _gameService.currentGameInfo!.isPrivateGame.toString());
      } else if (_gameService.currentGameInfo!.creatorId !=
          _userService.user.value!.id) {
        return CircularProgressIndicator(
            semanticsLabel:
                _gameService.currentGameInfo!.isPrivateGame.toString());
      } else if (_gameService.pendingJoinGameRequestUserIds.value!.isEmpty) {
        return CircularProgressIndicator(
            semanticsLabel:
                _gameService.currentGameInfo!.isPrivateGame.toString());
      } else {
        return Expanded(
          child: ListView.builder(
              itemCount:
                  _gameService.pendingJoinGameRequestUserIds.value!.length,
              itemBuilder: (context, item) {
                final index = item;
                return _buildPendingRequest(
                    _gameService.pendingJoinGameRequestUserIds.value![index]);
              }),
        );
      }
    }
  }

  Widget _buildPendingRequest(String userId) {
    return Column(
      children: [
        const Divider(),
        ListTile(
            title: Text(_usersService.getUserUsername(userId),
                style: TextStyle(fontSize: 18.0)),
            trailing: SizedBox(
              height: 100,
              width: 250,
              child: Row(children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    final res =
                        await _gameService.acceptJoinGameRequest(userId);
                  },
                  icon: const Icon(
                    Icons.check,
                    size: 20,
                  ),
                  label: const Text('Accepter'),
                ),
                Gap(16),
                ElevatedButton.icon(
                  onPressed: () async {
                    final res =
                        await _gameService.declineJoinGameRequest(userId);
                    if (res == true) {
                      _gameService.pendingJoinGameRequestUserIds.remove(userId);
                    } else {
                      DialogHelper.showErrorDialog(
                          title: "Erreur dans la demande",
                          description:
                              "La demande de refus du joueur n'a pas été accomplie.");
                    }
                  },
                  icon: const Icon(
                    Icons.close,
                    size: 20,
                  ),
                  label: const Text('Refuser'),
                )
              ]),
            )),
        // trailing: Icon(alreadySaved ? Icons.favorite : Icons.favorite_border,
        //     color: alreadySaved ? Colors.red : null),
      ],
    );
  }

  Future _buildInviteFriendDialog() {
    return Get.dialog(
        Dialog(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Déconnexion',
                  style: Get.textTheme.bodyMedium,
                ),
                _buildOnlineFriendsList(),
                ElevatedButton(
                  onPressed: () {
                    if (Get.isDialogOpen!) Get.back();
                  },
                  child: const Text('Fermer'),
                ),
              ],
            ),
          ),
        ),
        barrierDismissible: false);
  }

  Widget _buildOnlineFriendsList() {
    return SizedBox(
        width: 500,
        height: 500,
        child: UserList(
            mode: 'gameInvite',
            inputSearch: ''.obs,
            items: _usersService.getOnlineFriendUsernames()));
  }

  // Widget _buildOnlineFriendsList() {
  //   return FutureBuilder(
  //     future: _apiRepository.onlineFriends(),
  //     builder: (BuildContext context, AsyncSnapshot<List<User>?> snapshot) {
  //       if (snapshot.connectionState == ConnectionState.none
  //         || snapshot.connectionState == ConnectionState.waiting
  //         || snapshot.hasData == null) {
  //         return Center(
  //           child: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: const [
  //               CircularProgressIndicator(),
  //               Gap(8),
  //               Text('Collecte des données'),
  //             ],
  //           ),
  //         );
  //       }
  //       return Expanded(
  //           child: UserList(inputSearch: ''.obs, items: _usersService.getUserIdsFromUserList(snapshot.data!))
  //       );
  //     }
  //   );
  // }

  Widget _buildChatRoomsList() {
    if (!selectedChatRoom.value) {
      print("selectedchatroom value");
      print(selectedChatRoom);
      return Column(
        children: [
          Container(
            color: Color.fromARGB(255, 98, 0, 238),
            height: 60,
            width: double.infinity,
            child: const DrawerHeader(
              child: Text(
                'Chats',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
          ),
          Expanded(
              child: ListView.builder(
            // padding: const EdgeInsets.all(16.0),
            padding: EdgeInsets.zero,
            itemCount: _roomService.getRooms().length,
            itemBuilder: (context, item) {
              final index = item;
              return _buildChatRoomRow(_roomService.getRooms()[index].roomName,
                  _roomService.getRooms()[index].roomId);
            },
          ))
        ],
      );
    } else {
      print("selectedchatroom value");
      print(selectedChatRoom);
      return FloatingChatScreen(selectedChatRoom);
    }
  }

  Widget _buildChatRoomRow(String roomName, String roomId) {
    return Column(
      children: [
        ListTile(
          title: Text(roomName.split('/').length > 1
              ? roomName.split('/')[1]
              : roomName),
          // onTap: () => Get.toNamed(Routes.CHAT, arguments: {'text': 'roomName'}),
          onTap: () {
            selectedChatRoom.value = !selectedChatRoom.value;
            _roomService.currentFloatingChatRoomId.value = roomId;
            _roomService.updateCurrentFloatingRoomMessages();
          },
        ),
        const Divider(),
      ],
    );
  }
}
