import 'dart:async';

import 'package:drinktracker/data_json/ml_json.dart';
import 'package:drinktracker/pages/popup/manage_drinks/choose_drinks.dart';
import 'package:drinktracker/pages/popup/manage_drinks/choose_ml.dart';
import 'package:drinktracker/pages/widgets/textfield.dart';
import 'package:drinktracker/services/ml_service.dart';
import 'package:drinktracker/services/popup_service.dart';
import 'package:drinktracker/theme/color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:drinktracker/services/app_state.dart';

class Popup_AddQuantity extends StatefulWidget {
  final String drinksID;
  Popup_AddQuantity({super.key, required this.drinksID});

  @override
  State<Popup_AddQuantity> createState() => _Popup_AddQuantityState();
}

class _Popup_AddQuantityState extends State<Popup_AddQuantity> {
  TextEditingController _controller = TextEditingController();
  FocusNode _focusNode = FocusNode();

  addAmount(context) async {
    final appState = Provider.of<AppState>(context, listen: false);
    await appState.addHistoryEntry(widget.drinksID, int.parse(_controller.text));

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
    var size = MediaQuery.of(context).size;

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
          child: CustomTextField(
              labelText: "Quantity",
              controller: _controller,
              isNumber: true,
              maxLength: 4,
              focusNode: _focusNode,
              onChange: (value) {
                setState(() {});
              })),
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
