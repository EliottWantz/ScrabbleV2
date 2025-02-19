import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';

class SearchBar extends StatelessWidget {
  SearchBar(RxString input, String mode, {
    Key? key,
    // required this.text,
    // required this.onChanged,
    // required this.hintText,
  }) : _input = input,
        _mode = mode,
        super(key: key);

  final RxString _input;

  final String? _mode;
  // final String text;
  // final ValueChanged<String> onChanged;
  // final String hintText;

  final controller = TextEditingController();

  final styleActive = TextStyle(color: Colors.black);
  final styleHint = TextStyle(color: Colors.black54);

  final FocusNode messageInputFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    // final style = widget.text.isEmpty ? styleHint : styleActive;

    return Container(
      // margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(8),
      child: Obx(() => TextField(
          controller: controller,
          keyboardType: TextInputType.text,
          focusNode: messageInputFocusNode,
          onChanged: (_) {
            _input.value = controller.text;
            messageInputFocusNode.requestFocus();
          },
          onSubmitted: (_) {
            messageInputFocusNode.requestFocus();
          },
          decoration: InputDecoration(
              hintText: _buildHintText(),
              suffixIcon: _input.value == ''
              ? IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.search)
                )
              : IconButton(
                  onPressed: () {
                    _input.value = '';
                    controller.text = '';
                  },
                  icon: Icon(Icons.clear),
                ),
              border: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.all(Radius.circular(8)))
          ),
        ),
      ),
    );
  }

  String _buildHintText() {
    if (_mode == 'rooms') {
      return "Recherchez les serveurs";
    } else {
      return "Recherchez vos amis";
    }
  }
}
