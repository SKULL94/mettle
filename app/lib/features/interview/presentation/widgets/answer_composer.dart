import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';

class AnswerComposer extends StatefulWidget {
  const AnswerComposer({
    required this.enabled,
    required this.isSubmitting,
    required this.onSubmit,
    required this.onSkip,
    super.key,
  });

  final bool enabled;
  final bool isSubmitting;
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
            TextButton(
              onPressed: widget.enabled ? widget.onSkip : null,
              child: const Text(AppStrings.skip),
            ),
            const SizedBox(width: AppDimens.sm),
            Expanded(
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: _controller,
                builder: (context, value, _) => _SubmitButton(
                  isSubmitting: widget.isSubmitting,
                  onPressed: widget.enabled && value.text.trim().isNotEmpty
                      ? _submit
                      : null,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({required this.isSubmitting, required this.onPressed});

  final bool isSubmitting;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: isSubmitting ? null : onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Flexible(
            child: Text(
              AppStrings.submit,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: AppDimens.sm),
          if (isSubmitting)
            const SizedBox(
              width: AppDimens.iconSm,
              height: AppDimens.iconSm,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            const Icon(Icons.arrow_forward_rounded, size: AppDimens.iconMd),
        ],
      ),
    );
  }
}
