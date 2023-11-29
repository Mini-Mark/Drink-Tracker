import 'package:auto_size_text/auto_size_text.dart';
import 'package:drinktracker/theme/color.dart';
import 'package:drinktracker/theme/font_size.dart';
import 'package:flutter/material.dart';

class PopupService {
  static dynamic? globalCallback;

  getCallback() {
    return globalCallback;
  }

  clearCallback() {
    globalCallback = null;
  }

  Future<void> show(BuildContext context,
      {required Widget dialog,
      dynamic? callback,
      String? outsideHint,
      bool barrierDismissible = false,
      EdgeInsets? padding}) async {
    if (callback != null) {
      globalCallback = callback;
    }

    return showDialog<void>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Dialog(
              insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
              backgroundColor: Colors.white,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height *
                        0.8 // Set your maximum height here
                    ),
                child: Scrollbar(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: padding != null ? padding : EdgeInsets.all(15.0),
                      child: dialog,
                    ),
                  ),
                ),
              ),
            ),
            outsideHint != null
                ? Padding(
                    padding: const EdgeInsets.only(right: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          outsideHint,
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: text_md,
                            color: white,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Icon(Icons.touch_app_rounded, color: white),
                      ],
                    ),
                  )
                : Container()
          ],
        );
      },
    );
  }

  getHeader(
      {required BuildContext context,
      String? title,
      IconData? titleIcon,
      bool canBack: false,
      Function()? onBack}) {
    return WillPopScope(
      onWillPop: () async {
        onBack != null ? onBack() : Navigator.of(context).pop();
        return false;
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                canBack
                    ? SizedBox(
                        width: 40,
                        child: IconButton(
                            padding: EdgeInsets.all(0),
                            onPressed: () => onBack != null
                                ? onBack()
                                : Navigator.of(context).pop(),
                            icon: Icon(
                              Icons.arrow_back_ios,
                              color: dark,
                            )),
                      )
                    : Container(),
                titleIcon != null
                    ? Row(children: [
                        Icon(titleIcon, color: dark),
                        SizedBox(
                          width: 10,
                        ),
                      ])
                    : Container(),
                title != null
                    ? AutoSizeText(
                        title,
                        maxLines: 1,
                        style: TextStyle(
                            fontSize: title_lg,
                            fontWeight: FontWeight.bold,
                            color: dark),
                      )
                    : Container(),
              ],
            ),
            SizedBox(
              width: 40,
              child: IconButton(
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.all(0),
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.close,
                    color: black.withAlpha(100),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
