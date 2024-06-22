// import 'package:cs_location_tracker_app/components/old_reports_cases/Controller/chat_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatTextField extends ConsumerStatefulWidget {
  const ChatTextField({super.key, required this.receriverId});
  final String receriverId;

  @override
  ConsumerState<ChatTextField> createState() => _ChatTextFieldState();
}

class _ChatTextFieldState extends ConsumerState<ChatTextField> {
  late TextEditingController messageController;
  bool isMessageIconEnabled = false;

  // void sendTextMessage() async {
  //   if (isMessageIconEnabled) {
  //     ref.read(chatControllerProvider).sendTextMessage(
  //         context: context,
  //         textMessage: messageController.text,
  //         receiverId: widget.receriverId);
  //     messageController.clear();
  //   }
  // }

  @override
  void initState() {
    messageController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: messageController,
            maxLines: 4,
            minLines: 1,
            autofocus: true,
            onChanged: (value) {
              value.isEmpty
                  ? setState(() {
                      isMessageIconEnabled = false;
                    })
                  : setState(() {
                      isMessageIconEnabled = true;
                    });
            },
            decoration: InputDecoration(
                hintText: 'Type a message',
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                isDense: true,
                border: OutlineInputBorder(
                  borderSide: const BorderSide(
                      color: Colors.grey, width: 0, style: BorderStyle.none),
                  borderRadius: BorderRadius.circular(30),
                ),
                prefixIcon: Material(
                  color: Colors.transparent,
                  child: IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.emoji_emotions_outlined)),
                ),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RotatedBox(
                      quarterTurns: 45,
                      child: IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.attach_file)),
                    ),
                    IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.camera_alt_outlined))
                  ],
                )),
          ),
        ),
        const SizedBox(
          width: 5,
        ),
        IconButton(
          onPressed:(){
            // sendTextMessage();
          },
          icon: isMessageIconEnabled
              ? const Icon(Icons.send)
              : const Icon(Icons.mic_none_outlined),
          color: Colors.blue,
        ),
      ],
    );
  }
}
