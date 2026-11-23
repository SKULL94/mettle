import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';

class AnswerComposer extends StatefulWidget {
  const AnswerComposer({
    required this.enabled,
    required this.isSubmitting,
    required this.onSubmit,
    required this.onSkip,
    this.expand = false,
    super.key,
  });

  final bool enabled;
  final bool isSubmitting;
  final ValueChanged<String> onSubmit;
  final VoidCallback onSkip;
  final bool expand;

  @override
  State<AnswerComposer> createState() => _AnswerComposerState();
}

const _block = DoNothingAndStopPropagationTextIntent();

const _blocked = <ShortcutActivator, Intent>{
  SingleActivator(LogicalKeyboardKey.keyC, control: true): _block,
  SingleActivator(LogicalKeyboardKey.keyC, meta: true): _block,
  SingleActivator(LogicalKeyboardKey.keyX, control: true): _block,
  SingleActivator(LogicalKeyboardKey.keyX, meta: true): _block,
  SingleActivator(LogicalKeyboardKey.keyV, control: true): _block,
  SingleActivator(LogicalKeyboardKey.keyV, meta: true): _block,
  SingleActivator(LogicalKeyboardKey.keyA, control: true): _block,
  SingleActivator(LogicalKeyboardKey.keyA, meta: true): _block,
  SingleActivator(LogicalKeyboardKey.insert, shift: true): _block,
  SingleActivator(LogicalKeyboardKey.insert, control: true): _block,
};

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
    final field = Shortcuts(
      shortcuts: _blocked,
      child: TextField(
        controller: _controller,
        focusNode: _focus,
        enabled: widget.enabled,
        minLines: widget.expand ? null : 3,
        maxLines: widget.expand ? null : 6,
        expands: widget.expand,
        textAlignVertical: TextAlignVertical.top,
        textInputAction: TextInputAction.newline,
        keyboardType: TextInputType.multiline,
        contextMenuBuilder: (context, state) => const SizedBox.shrink(),
        decoration: const InputDecoration(hintText: AppStrings.answerHint),
      ),
    );

    return Column(
      children: [
        if (widget.expand) Expanded(child: field) else field,
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
