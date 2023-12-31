import 'package:auto_size_text/auto_size_text.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:drinktracker/data_json/ml_json.dart';
import 'package:drinktracker/pages/home.dart';
import 'package:drinktracker/pages/popup/manage_drinks/add_quantity.dart';
import 'package:drinktracker/pages/popup/manage_drinks/choose_drinks.dart';
import 'package:drinktracker/pages/popup/manage_drinks/success_add_drinks.dart';
import 'package:drinktracker/services/drinks_service.dart';
import 'package:drinktracker/services/popup_service.dart';
import 'package:drinktracker/theme/color.dart';
import 'package:drinktracker/theme/font_size.dart';
import 'package:flutter/material.dart';

class Popup_ChooseML extends StatelessWidget {
  final int drinksID;
  const Popup_ChooseML({super.key, required this.drinksID});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    dynamic drinksData = DrinksService().getDrinksByID(drinksID);

    return Column(
      children: [
        PopupService().getHeader(
            context: context,
            title: drinksData["name"],
            titleIcon: drinksData["icon"],
            canBack: true,
            onBack: () {
              Navigator.of(context).pop();
              PopupService().show(context,
                  dialog: Popup_ChooseDrink(), outsideHint: "hold to edit");
            }),
        SizedBox(
          width: size.width,
          child: Container(
            alignment: Alignment.center,
            child: Wrap(
                alignment: WrapAlignment.start,
                spacing: 10.0,
                runSpacing: 10.0,
                children: getMLList(context)),
          ),
        ),
        SizedBox(
          height: 20,
        )
      ],
    );
  }

  List<Widget> getMLList(context) {
    List<Widget> drinkWidgets =
        List.generate(mlList.length, (index) => mlItem(context, mlList[index]));
    drinkWidgets.insert(0, addMLWidget(context));

    return drinkWidgets;
  }

  Widget addMLWidget(context) {
    var size = MediaQuery.of(context).size;
    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
        PopupService().show(context,
            padding: EdgeInsets.all(0),
            dialog: Popup_AddQuantity(
              drinksID: drinksID,
            ));
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

  Widget mlItem(context, data) {
    var size = MediaQuery.of(context).size;
    return InkWell(
      splashColor: primary.withAlpha(150),
      onTap: () {
        Navigator.of(context).pop();
        PopupService()
            .show(context,
                dialog: Popup_SuccessAddDrinks(
                    drinksID: drinksID, ml: data["amount"]),
                barrierDismissible: true)
            .then((value) async {
          final callback = await PopupService().getCallback();
          callback(1);

          PopupService().clearCallback();
        });
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
                  border: Border.all(color: light_secondary, width: 1.2)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: size.width * 0.25,
                    child: AutoSizeText.rich(
                      TextSpan(
                          text: "${data['amount']}",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: title_lg),
                          children: [
                            TextSpan(
                              text: "ml",
                              style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: text_md),
                            )
                          ]),
                      style: TextStyle(color: light_secondary),
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
