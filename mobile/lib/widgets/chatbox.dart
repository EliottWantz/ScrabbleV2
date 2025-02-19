import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:client_leger/controllers/chatbox_controller.dart';
import 'package:client_leger/services/websocket_service.dart';
import 'package:client_leger/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ChatBox extends GetView<ChatBoxController> {
  const ChatBox({super.key});

  @override
  Widget build(BuildContext context) {
    controller.websocketService.messages.listen((p0) {
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        controller.scrollDown();
      });
    });
    // return Column(
    //   mainAxisAlignment: MainAxisAlignment.center,
    //   children: [
    //     TextButton(onPressed: (){
    //       controller.sendMessage();
    //     }, child: Text('TextButton')),
    //     Obx(() => Text(controller.websocketService.itemCount.value.toString())),
    //   ],
    // );
    // Text(controller.websocketService.itemCount.value.toString());
    return Obx(() =>
        Expanded(
          child: Container(
            decoration: BoxDecoration(border: Border.all(color: Colors.black)),
            child: ListView.builder(
              controller: controller.scrollController,
              reverse: false,
              itemCount: controller.websocketService.messages.value.length,
              shrinkWrap: true,
              padding: EdgeInsets.only(top: 10, bottom: 10),
              itemBuilder: (context, index) {
                return Container(
                  padding: EdgeInsets.only(
                      left: 14, right: 14, top: 10, bottom: 10),
                  child: Align(
                    alignment: (controller.isCurrentUserMessage(controller
                        .websocketService
                        .messages
                        .value[index]
                        .payload!
                        .from)
                        ? Alignment.topRight
                        : Alignment.topLeft),
                    child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: (controller.isCurrentUserMessage(controller
                              .websocketService
                              .messages
                              .value[index]
                              .payload!
                              .from)
                              ? Colors.blue[200]
                              : Colors.grey.shade200),
                        ),
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text(
                              controller.websocketService.messages
                                  .value[index].payload!.from
                            ),
                            Text(
                                controller.websocketService.messages
                                    .value[index].payload!.message,
                                style: TextStyle(fontSize: 15)),
                            Text(
                                controller
                                    .getLocalTime(index),
                                style: TextStyle(fontSize: 15)),
                          ],
                        )),
                  ),
                );
              },
            ),
          ),
        ));

    // return Scaffold(
    //   body: Padding(
    //     padding: const EdgeInsets.all(8.0),
    //     child: Column(
    //       children: [
    //         Form(child: TextFormField(controller: controller.textController)),
    //         // StreamBuilder(
    //         //     stream: messageController.channel!.stream,
    //         //     builder: (context,snapshot){
    //         //       return Text(snapshot.hasData ? '${snapshot.data}' : '');
    //         //     }),
    //         TextButton(onPressed: () {
    //           controller.sendMessage();
    //         }, child: Text("Send")),
    //       ],
    //     ),
    //   ),
    // );
  }
}
