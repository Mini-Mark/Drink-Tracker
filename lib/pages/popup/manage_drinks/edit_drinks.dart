import 'dart:async';

import 'package:drinktracker/data_json/drinks_icons_list.dart';
import 'package:drinktracker/pages/popup/manage_drinks/choose_drinks.dart';
import 'package:drinktracker/pages/widgets/textfield.dart';
import 'package:drinktracker/services/drinks_service.dart';
import 'package:drinktracker/services/popup_service.dart';
import 'package:drinktracker/theme/color.dart';
import 'package:flutter/material.dart';

class Popup_EditDrinks extends StatefulWidget {
  final int drinksID;
  const Popup_EditDrinks({super.key, required this.drinksID});

  @override
  State<Popup_EditDrinks> createState() => _Popup_EditDrinksState();
}

class _Popup_EditDrinksState extends State<Popup_EditDrinks> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  int choosePosition = 0;

  @override
  void initState() {
    super.initState();
    final drinkData = DrinksService().getDrinksByID(widget.drinksID);
    _controller.text = drinkData["name"];
    choosePosition = drinksIconList.indexOf(drinkData["icon"]);
  }

  updateDrinks(context) {
    DrinksService().updateDrinks(widget.drinksID, _controller.text, drinksIconList[choosePosition]);
    back(context);
  }

  deleteDrinks(context) {
    DrinksService().deleteDrinks(widget.drinksID);
    back(context);
  }

  back(context) {
    Navigator.of(context).pop();
    PopupService().show(
      context,
      dialog: const Popup_ChooseDrink(),
      outsideHint: "hold to edit",
    );
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Column(children: [
      Padding(
        padding: const EdgeInsets.only(left: 15, right: 15, top: 15),
        child: PopupService().getHeader(
          context: context,
          title: "Edit Drink",
          canBack: true,
          onBack: () {
            if (_focusNode.hasFocus) {
              _focusNode.unfocus();
              Timer(const Duration(milliseconds: 800), () => back(context));
            } else {
              back(context);
            }
          },
        ),
      ),
      Padding(
          padding: const EdgeInsets.only(left: 25, right: 25),
          child: CustomTextField(
              labelText: "Drink name",
              controller: _controller,
              focusNode: _focusNode,
              maxLength: 25,
              onChange: (value) {
                setState(() {});
              })),
      const SizedBox(height: 20),
      Padding(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.start,
          spacing: 15,
          runSpacing: 15,
          children: List.generate(
              drinksIconList.length,
              (index) => SizedBox(
                    width: size.width * 0.12,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(5),
                      onTap: () {
                        setState(() {
                          choosePosition = index;
                        });
                      },
                      child: Ink(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: choosePosition == index
                                    ? secondary
                                    : Colors.transparent),
                            borderRadius: BorderRadius.circular(5)),
                        child: Icon(
                          drinksIconList[index],
                          color: choosePosition == index ? secondary : dark,
                          size: size.width * 0.07,
                        ),
                      ),
                    ),
                  )),
        ),
      ),
      const SizedBox(height: 20),
      Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                if (_focusNode.hasFocus) {
                  _focusNode.unfocus();
                  Timer(const Duration(milliseconds: 800), () => deleteDrinks(context));
                } else {
                  deleteDrinks(context);
                }
              },
              borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(15)),
              child: Ink(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                    color: danger,
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(15))),
                child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.delete, color: white),
                  SizedBox(width: 5),
                  Text("Delete", style: TextStyle(color: white))
                ]),
              ),
            ),
          ),
          Expanded(
            child: Opacity(
              opacity: _controller.text.isNotEmpty ? 1.0 : 0.5,
              child: InkWell(
                onTap: _controller.text.isNotEmpty
                    ? () {
                        if (_focusNode.hasFocus) {
                          _focusNode.unfocus();
                          Timer(const Duration(milliseconds: 800), () => updateDrinks(context));
                        } else {
                          updateDrinks(context);
                        }
                      }
                    : null,
                borderRadius: const BorderRadius.only(
                    bottomRight: Radius.circular(15)),
                child: Ink(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                      color: light_secondary,
                      borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(15))),
                  child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.check, color: white),
                    SizedBox(width: 5),
                    Text("Update", style: TextStyle(color: white))
                  ]),
                ),
              ),
            ),
          ),
        ],
      )
    ]);
  }
}
