import 'dart:async';

import 'package:drinktracker/pages/popup/manage_drinks/choose_ml.dart';
import 'package:drinktracker/pages/widgets/textfield.dart';
import 'package:drinktracker/services/ml_service.dart';
import 'package:drinktracker/services/popup_service.dart';
import 'package:drinktracker/theme/color.dart';
import 'package:flutter/material.dart';

class Popup_EditQuantity extends StatefulWidget {
  final int drinksID;
  final int mlAmount;
  const Popup_EditQuantity({super.key, required this.drinksID, required this.mlAmount});

  @override
  State<Popup_EditQuantity> createState() => _Popup_EditQuantityState();
}

class _Popup_EditQuantityState extends State<Popup_EditQuantity> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller.text = widget.mlAmount.toString();
  }

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

  updateAmount(context) {
    if (!_validateVolume()) {
      return;
    }
    
    MLService().updateML(widget.mlAmount, int.parse(_controller.text));
    back(context);
  }

  deleteAmount(context) {
    MLService().deleteML(widget.mlAmount);
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
        padding: const EdgeInsets.only(left: 15, right: 15, top: 15),
        child: PopupService().getHeader(
          context: context,
          title: "Edit Quantity",
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
      const SizedBox(height: 20),
      Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                if (_focusNode.hasFocus) {
                  _focusNode.unfocus();
                  Timer(const Duration(milliseconds: 800), () => deleteAmount(context));
                } else {
                  deleteAmount(context);
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
                          Timer(const Duration(milliseconds: 800), () => updateAmount(context));
                        } else {
                          updateAmount(context);
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
