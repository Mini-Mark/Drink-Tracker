import 'dart:async';

import 'package:drinktracker/pages/popup/manage_drinks/choose_ml.dart';
import 'package:drinktracker/pages/widgets/textfield.dart';
import 'package:drinktracker/providers/app_state.dart';
import 'package:drinktracker/services/popup_service.dart';
import 'package:drinktracker/theme/color.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Popup_AddQuantity extends StatefulWidget {
  final int drinksID;
  Popup_AddQuantity({super.key, required this.drinksID});

  @override
  State<Popup_AddQuantity> createState() => _Popup_AddQuantityState();
}

class _Popup_AddQuantityState extends State<Popup_AddQuantity> {
  TextEditingController _controller = TextEditingController();
  FocusNode _focusNode = FocusNode();
  String? _errorMessage;

  bool _validateVolume() {
    final volumeText = _controller.text.trim();
    
    if (volumeText.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a volume';
      });
      return false;
    }

    final volume = int.tryParse(volumeText);
    if (volume == null) {
      setState(() {
        _errorMessage = 'Please enter a valid number';
      });
      return false;
    }

    if (volume < 1 || volume > 2000) {
      setState(() {
        _errorMessage = 'Volume must be between 1 and 2000 ml';
      });
      return false;
    }

    setState(() {
      _errorMessage = null;
    });
    return true;
  }

  addAmount(context) async {
    if (!_validateVolume()) {
      return;
    }
    
    final appState = Provider.of<AppState>(context, listen: false);
    await appState.addML(int.parse(_controller.text));

    back(context);
  }

  back(context) {
    Navigator.of(context).pop();
    PopupService().show(
      context,
      dialog: Popup_ChooseML(drinksID: widget.drinksID),
      outsideHint: "hold to edit",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(
        padding: EdgeInsets.only(left: 15, right: 15, top: 15),
        child: PopupService().getHeader(
          context: context,
          title: "Add Quantity",
          canBack: true,
          onBack: () {
            if (_focusNode.hasFocus) {
              _focusNode.unfocus();
              Timer(Duration(milliseconds: 800), () => back(context));
            } else {
              back(context);
            }
          },
        ),
      ),
      Padding(
          padding: const EdgeInsets.only(left: 25, right: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                  labelText: "Quantity",
                  controller: _controller,
                  isNumber: true,
                  maxLength: 4,
                  focusNode: _focusNode,
                  onChange: (value) {
                    if (_errorMessage != null) {
                      setState(() {
                        _errorMessage = null;
                      });
                    } else {
                      setState(() {});
                    }
                  }),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 12),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: danger,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          )),
      SizedBox(
        height: 20,
      ),
      Opacity(
        opacity: _controller.text.isNotEmpty ? 1.0 : 0.5,
        child: InkWell(
          onTap: _controller.text.isNotEmpty
              ? () {
                  if (_focusNode.hasFocus) {
                    _focusNode.unfocus();
                    Timer(
                        Duration(milliseconds: 800), () => addAmount(context));
                  } else {
                    addAmount(context);
                  }
                }
              : null,
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(15),
              bottomRight: Radius.circular(15)),
          child: Ink(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: light_secondary,
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15))),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.add, color: white),
              SizedBox(
                width: 5,
              ),
              Text(
                "Add",
                style: TextStyle(color: white),
              )
            ]),
          ),
        ),
      )
    ]);
  }
}
