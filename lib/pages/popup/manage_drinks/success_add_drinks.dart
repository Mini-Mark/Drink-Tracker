import 'package:auto_size_text/auto_size_text.dart';
import 'package:drinktracker/pages/home.dart';
import 'package:drinktracker/services/drinks_service.dart';
import 'package:drinktracker/services/history_service.dart';
import 'package:drinktracker/services/popup_service.dart';
import 'package:drinktracker/theme/color.dart';
import 'package:drinktracker/theme/font_size.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Popup_SuccessAddDrinks extends StatefulWidget {
  final int drinksID;
  final int ml;
  const Popup_SuccessAddDrinks(
      {super.key, required this.drinksID, required this.ml});

  @override
  State<Popup_SuccessAddDrinks> createState() => _Popup_SuccessAddDrinksState();
}

class _Popup_SuccessAddDrinksState extends State<Popup_SuccessAddDrinks> {
  @override
  void initState() {
    super.initState();

    HistoryService().addHistory(drinksID: widget.drinksID, amount: widget.ml);
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    dynamic drinksData = DrinksService().getDrinksByID(widget.drinksID);

    return Column(
      children: [
        PopupService().getHeader(context: context),
        SizedBox(
          width: size.width,
          child: Container(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(alignment: Alignment.topRight, children: [
                  Icon(drinksData["icon"],
                      color: dark, size: size.width * 0.25),
                  Icon(Icons.circle, color: white, size: 30),
                  Icon(Icons.check_circle_rounded, color: success, size: 30),
                ]),
                SizedBox(
                  height: 10,
                ),
                SizedBox(
                  child: AutoSizeText.rich(
                    TextSpan(
                        text: "Added ",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: title_lg - 4,
                            color: secondary),
                        children: [
                          TextSpan(
                            text: "${drinksData['name']} ${widget.ml}ml",
                            style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: title_lg - 4,
                                color: dark),
                          )
                        ]),
                    style: TextStyle(color: light_secondary),
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              ],
            ),
          ),
        ),
        SizedBox(
          height: 30,
        )
      ],
    );
  }
}
