import 'dart:async';

import 'package:drinktracker/data_json/drinks_icons_list.dart';
import 'package:drinktracker/pages/popup/manage_drinks/choose_drinks.dart';
import 'package:drinktracker/pages/widgets/textfield.dart';
import 'package:drinktracker/services/drinks_service.dart';
import 'package:drinktracker/services/popup_service.dart';
import 'package:drinktracker/services/utils_service.dart';
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
  Color? selectedColor;

  // Color palette options
  final List<Color> colorPalette = [
    const Color(0xFF366C8E), // secondary
    const Color(0xFFFFBF5E), // warning
    const Color(0xFFFF7070), // danger
    const Color(0xFFFFC700), // edit
    const Color(0xFFE91E63), // pink
    const Color(0xFFF44336), // red
    const Color(0xFFFF9800), // orange
    const Color(0xFF4CAF50), // green
    const Color(0xFF607D8B), // blue grey
  ];

  @override
  void initState() {
    super.initState();
    final drinkData = DrinksService().getDrinksByID(widget.drinksID);
    _controller.text = drinkData["name"];
    choosePosition = drinksIconList.indexOf(drinkData["icon"]);

    // Load existing color if available
    final rawDrinkData = DrinksService()
        .getAllDrinks()
        .firstWhere((d) => d["id"] == widget.drinksID);
    if (rawDrinkData["color"] != null) {
      selectedColor = UtilsService().hexToColor(rawDrinkData["color"]);
    }
  }

  updateDrinks(context) async {
    String? colorHex;
    if (selectedColor != null) {
      colorHex = UtilsService().colorToHex(selectedColor!);
    }
    await DrinksService().updateDrinks(
        widget.drinksID, _controller.text, drinksIconList[choosePosition],
        color: colorHex);
    back(context);
  }

  deleteDrinks(context) async {
    await DrinksService().deleteDrinks(widget.drinksID);
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
        padding: const EdgeInsets.only(left: 25, right: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Color",
              style: TextStyle(
                  fontSize: 14, color: dark, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(
                colorPalette.length,
                (index) => InkWell(
                  onTap: () {
                    setState(() {
                      selectedColor = colorPalette[index];
                    });
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 25,
                    height: 25,
                    decoration: BoxDecoration(
                      color: colorPalette[index],
                      shape: BoxShape.circle,
                    ),
                    child: selectedColor == colorPalette[index]
                        ? const Icon(Icons.check, color: white, size: 20)
                        : null,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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
                  Timer(const Duration(milliseconds: 800),
                      () => deleteDrinks(context));
                } else {
                  deleteDrinks(context);
                }
              },
              borderRadius:
                  const BorderRadius.only(bottomLeft: Radius.circular(15)),
              child: Ink(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                    color: danger,
                    borderRadius:
                        BorderRadius.only(bottomLeft: Radius.circular(15))),
                child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
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
                          Timer(const Duration(milliseconds: 800),
                              () => updateDrinks(context));
                        } else {
                          updateDrinks(context);
                        }
                      }
                    : null,
                borderRadius:
                    const BorderRadius.only(bottomRight: Radius.circular(15)),
                child: Ink(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                      color: light_secondary,
                      borderRadius:
                          BorderRadius.only(bottomRight: Radius.circular(15))),
                  child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
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
