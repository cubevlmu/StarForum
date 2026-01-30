import 'package:flutter/material.dart';
import 'package:forum/utils/setting_util.dart';
import 'package:forum/widgets/slider_dialog.dart';

class SettingsSliderTile extends StatefulWidget {
  const SettingsSliderTile(
      {super.key,
      required this.title,
      required this.subTitle,
      required this.settingsKey,
      required this.defualtValue,
      required this.min,
      required this.max,
      this.divisions,
      required this.buildLabel});
  final String title;
  final String subTitle;
  final String settingsKey;
  final double defualtValue;

  final double min;
  final double max;
  final int? divisions;

  ///构建trailing和slider的label
  final String Function(double selectingValue)? buildLabel;

  @override
  State<SettingsSliderTile> createState() => _SettingsSliderTileState();
}

class _SettingsSliderTileState extends State<SettingsSliderTile> {
  @override
  Widget build(BuildContext context) {
    double initValue = SettingsUtil.getValue(widget.settingsKey,
        defaultValue: widget.defualtValue);
    return ListTile(
      title: Text(widget.title),
      subtitle: Text(widget.subTitle),
      trailing: widget.buildLabel != null
          ? StatefulBuilder(builder: (context, setState) {
              return Text(widget.buildLabel!.call(initValue));
            })
          : null,
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => SliderDialog(
            title: widget.title,
            initValue: initValue,
            min: widget.min,
            max: widget.max,
            divisions: widget.divisions,
            buildLabel: widget.buildLabel,
            onOk: (selectingValue) async {
              await SettingsUtil.setValue(widget.settingsKey, selectingValue);
              setState(() {});
            },
          ),
        );
      },
    );
  }
}
