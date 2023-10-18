import 'package:flutter/material.dart';
import 'package:how_are_you/util/Constants.dart';

class CustomSliderDialog extends StatefulWidget {
  double initValue;

  CustomSliderDialog({
    Key? key,
    required this.initValue,
  });

  @override
  _CustomSliderDialogState createState() => _CustomSliderDialogState();
}

class _CustomSliderDialogState extends State<CustomSliderDialog> {
  late double _sliderValue;

  @override
  void initState() {
    super.initState();
    _sliderValue = widget.initValue;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: const EdgeInsets.all(0),
      contentPadding: const EdgeInsets.all(0),
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(30)),
      ),
      content: SingleChildScrollView(
        child: Slider(
          value: _sliderValue,
          min: 10,
          max: 50,
          label: _sliderValue.round().toString(),
          onChanged: (value) {
            setState(() {
              _sliderValue = value;
            });
          },
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text(
            "change size!",
            style: TextStyle(
              color: appDialogActionColor,
            ),
          ),
          onPressed: () {
            Navigator.pop(context, _sliderValue);
          },
        ),
      ],
    );
  }
}
