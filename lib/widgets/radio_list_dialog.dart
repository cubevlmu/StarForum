import 'package:flutter/material.dart';
import 'package:star_forum/l10n/app_localizations.dart';

class RadioListDialog<T> extends StatefulWidget {
  const RadioListDialog({
    super.key,
    required this.title,
    required this.itemNameValueMap,
    required this.groupValue,
    this.onChanged,
  });
  final String title;
  final Map<String, T> itemNameValueMap;
  final T groupValue;
  final Function(T? value)? onChanged;

  @override
  State<RadioListDialog<T>> createState() => _RadioListDialogState<T>();
}

class _RadioListDialogState<T> extends State<RadioListDialog<T>> {
  late T? _groupValue;
  late List<Widget> items;

  @override
  void initState() {
    _groupValue = widget.groupValue;
    items = <Widget>[];
    widget.itemNameValueMap.forEach((title, value) {
      items.add(RadioListTile(value: value, title: Text(title)));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: Text(widget.title),
      content: RadioGroup<T>(
        groupValue: _groupValue,
        onChanged: (value) {
          widget.onChanged?.call(value);
          setState(() {
            _groupValue = value;
          });
          Navigator.of(context).pop(value);
        },
        child: Column(children: items),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context)!.commonActionCancel),
        ),
      ],
    );
  }
}
