import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EditableTemperature extends StatefulWidget {
  const EditableTemperature({
    super.key,
    required this.title,
    required this.value,
    required this.step,
    required this.onChanged,
    this.compact = false,
  });

  final String title;
  final int? value;
  final int step;
  final ValueChanged<int?> onChanged;
  final bool compact;

  @override
  State<EditableTemperature> createState() => _EditableTemperatureState();
}

class _EditableTemperatureState extends State<EditableTemperature> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  bool _editing = false;

  TextStyle get _textStyle => TextStyle(
        fontSize: widget.compact ? 17 : 18,
        fontWeight: FontWeight.w600,
        height: 1.0,
      );

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController();
    _focusNode = FocusNode();

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _editing) {
        _saveValue();
      }
    });
  }

  @override
  void didUpdateWidget(covariant EditableTemperature oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!_editing) {
      _controller.text = widget.value?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _startEditing() {
    _controller.text = widget.value?.toString() ?? '';

    setState(() {
      _editing = true;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      _focusNode.requestFocus();

      _controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _controller.text.length,
      );
    });
  }

  void _saveValue() {
    final value = int.tryParse(_controller.text);

    if (value != null) {
      widget.onChanged(value);
    }

    if (mounted) {
      setState(() {
        _editing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_editing) {
      _controller.text = widget.value?.toString() ?? '';
    }

    final buttonSize = widget.compact ? 34.0 : 36.0;
    final valueWidth = widget.compact ? 58.0 : 76.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),

        SizedBox(height: widget.compact ? 10 : 12),

        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: buttonSize,
              height: buttonSize,
              child: IconButton(
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(
                  minWidth: buttonSize,
                  minHeight: buttonSize,
                ),
                iconSize: 20,
                splashRadius: 20,
                icon: const Icon(Icons.remove),
                onPressed: () {
                  widget.onChanged(
                    (widget.value ?? 0) - widget.step,
                  );
                },
              ),
            ),

            SizedBox(
              width: valueWidth,
              height: 28,
              child: Center(
                child: !_editing
                    ? InkWell(
                        borderRadius: BorderRadius.circular(6),
                        onTap: _startEditing,
                        child: SizedBox(
                          height: 28,
                          child: Center(
                            child: Text(
                              "${widget.value ?? '-'}°C",
                              style: _textStyle,
                            ),
                          ),
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Transform.translate(
                            offset: const Offset(0, 2),
                            child: IntrinsicWidth(
                              child: TextField(
                                controller: _controller,
                                focusNode: _focusNode,
                                autofocus: true,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                style: _textStyle,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  focusedErrorBorder: InputBorder.none,
                                  isCollapsed: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                onSubmitted: (_) => _saveValue(),
                                onTapOutside: (_) => _saveValue(),
                              ),
                            ),
                          ),
                          Text(
                            "°C",
                            style: _textStyle,
                          ),
                        ],
                      ),
              ),
            ),

            SizedBox(
              width: buttonSize,
              height: buttonSize,
              child: IconButton(
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(
                  minWidth: buttonSize,
                  minHeight: buttonSize,
                ),
                iconSize: 20,
                splashRadius: 20,
                icon: const Icon(Icons.add),
                onPressed: () {
                  widget.onChanged(
                    (widget.value ?? 0) + widget.step,
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}