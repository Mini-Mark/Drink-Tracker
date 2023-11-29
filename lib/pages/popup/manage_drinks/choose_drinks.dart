import 'package:auto_size_text/auto_size_text.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:drinktracker/data_json/drinks_json.dart';
import 'package:drinktracker/pages/popup/manage_drinks/add_drinks.dart';
import 'package:drinktracker/pages/popup/manage_drinks/choose_ml.dart';
import 'package:drinktracker/services/popup_service.dart';
import 'package:drinktracker/services/utils_service.dart';
import 'package:drinktracker/theme/color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Popup_ChooseDrink extends StatelessWidget {
  const Popup_ChooseDrink({super.key});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Column(
      children: [
        PopupService().getHeader(context: context, title: "Drinks"),
        SizedBox(
          width: size.width,
          child: Container(
            alignment: Alignment.center,
            child: Wrap(
                alignment: WrapAlignment.start,
                spacing: 10.0,
                runSpacing: 10.0,
                children: getDrinksList(context)),
          ),
        ),
        SizedBox(
          height: 20,
        )
      ],
    );
  }

  List<Widget> getDrinksList(context) {
    List<Widget> drinkWidgets = List.generate(
        drinkLists.length, (index) => drinksItem(context, drinkLists[index]));
    drinkWidgets.insert(0, addDrinksWidget(context));

    return drinkWidgets;
  }

  Widget addDrinksWidget(context) {
    var size = MediaQuery.of(context).size;
    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
        PopupService().show(context,
            padding: EdgeInsets.all(0), dialog: Popup_AddDrinks());
      },
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: size.width * 0.25,
        child: AspectRatio(
          aspectRatio: 1,
          child: DottedBorder(
            borderType: BorderType.RRect,
            radius: Radius.circular(10),
            padding: EdgeInsets.all(10),
            color: dark.withAlpha(150),
            strokeWidth: 1.2,
            dashPattern: [8, 4],
            child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.add, color: dark.withAlpha(150), size: 50),
                  ],
                )),
          ),
        ),
      ),
    );
  }

  Widget drinksItem(context, data) {
    var size = MediaQuery.of(context).size;
    return InkWell(
      splashColor: primary.withAlpha(150),
      onTap: () {
        Navigator.of(context).pop();
        PopupService().show(context,
            dialog: Popup_ChooseML(drinksID: data["id"]),
            outsideHint: "hold to edit");
      },
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: size.width * 0.25,
        child: AspectRatio(
          aspectRatio: 1,
          child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: data["color"] == null
                          ? light_secondary
                          : UtilsService().HexToColor(data["color"]),
                      width: 1.2)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(data["icon"],
                      color: data["color"] == null
                          ? light_secondary
                          : UtilsService().HexToColor(data["color"]),
                      size: 25),
                  SizedBox(
                    height: 8,
                  ),
                  SizedBox(
                    width: size.width * 0.25,
                    child: AutoSizeText(
                      data["name"],
                      style: TextStyle(
                        color: data["color"] == null
                            ? light_secondary
                            : UtilsService().HexToColor(data["color"]),
                      ),
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      minFontSize: 10,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                ],
              )),
        ),
      ),
    );
  }
}
