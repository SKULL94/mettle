import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';

class AnswerComposer extends StatefulWidget {
  const AnswerComposer({
    required this.enabled,
    required this.onSubmit,
    required this.onSkip,
    super.key,
  });

  final bool enabled;
  final ValueChanged<String> onSubmit;
  final VoidCallback onSkip;

  @override
  State<AnswerComposer> createState() => _AnswerComposerState();
}

class _AnswerComposerState extends State<AnswerComposer> {
  final _controller = TextEditingController();
  final _focus = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(AnswerComposer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled && !oldWidget.enabled) {
      _controller.clear();
      _focus.requestFocus();
    }
  }

  void _submit() {
    final value = _controller.text.trim();
    if (value.isEmpty) return;
    widget.onSubmit(value);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _controller,
          focusNode: _focus,
          enabled: widget.enabled,
          minLines: 3,
          maxLines: 6,
          textInputAction: TextInputAction.newline,
          keyboardType: TextInputType.multiline,
          decoration: const InputDecoration(hintText: AppStrings.answerHint),
        ),
        const SizedBox(height: AppDimens.sm),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: widget.enabled ? widget.onSkip : null,
                child: const Text(AppStrings.skip),
              ),
            ),
            const SizedBox(width: AppDimens.sm),
            Expanded(
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: _controller,
                builder: (context, value, _) {
                  final canSubmit =
                      widget.enabled && value.text.trim().isNotEmpty;
                  return FilledButton(
                    onPressed: canSubmit ? _submit : null,
                    child: const Text(AppStrings.submit),
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
