import 'dart:async';

import 'package:drinktracker/data_json/drinks_icons_list.dart';
import 'package:drinktracker/pages/popup/manage_drinks/choose_drinks.dart';
import 'package:drinktracker/pages/widgets/textfield.dart';
import 'package:drinktracker/services/drinks_service.dart';
import 'package:drinktracker/services/popup_service.dart';
import 'package:drinktracker/theme/color.dart';
import 'package:flutter/material.dart';

class Popup_AddDrinks extends StatefulWidget {
  @override
  State<Popup_AddDrinks> createState() => _Popup_AddDrinksState();
}

class _Popup_AddDrinksState extends State<Popup_AddDrinks> {
  TextEditingController _controller = TextEditingController();
  FocusNode _focusNode = FocusNode();

  int choosePosition = 0;

  addDrinks(context) {
    DrinksService().addDrinks(_controller.text, drinksIconList[choosePosition]);

    back(context);
  }

  back(context) {
    Navigator.of(context).pop();
    PopupService().show(
      context,
      dialog: Popup_ChooseDrink(),
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
          title: "Add Drink",
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
              labelText: "Drink name",
              controller: _controller,
              focusNode: _focusNode,
              maxLength: 25,
              onChange: (value) {
                setState(() {});
              })),
      SizedBox(
        height: 20,
      ),
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
                        padding: EdgeInsets.all(5),
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
                        Duration(milliseconds: 800), () => addDrinks(context));
                  } else {
                    addDrinks(context);
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
