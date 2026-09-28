import 'package:flutter/material.dart';
import 'package:upcloud_flutter/src/l10n/upcloud_localizations.dart';

/// Asks for a single line of text. Returns `null` when cancelled.
Future<String?> showTextInputDialog(
  BuildContext context, {
  required String title,
  required String label,
  required String confirmLabel,
  String initialValue = '',
  String? Function(String value)? validator,
  TextInputType? keyboardType,
}) => showDialog<String>(
  context: context,
  builder: (context) => _TextInputDialog(
    title: title,
    label: label,
    confirmLabel: confirmLabel,
    initialValue: initialValue,
    validator: validator,
    keyboardType: keyboardType,
  ),
);

class _TextInputDialog extends StatefulWidget {
  const _TextInputDialog({
    required this.title,
    required this.label,
    required this.confirmLabel,
    required this.initialValue,
    required this.validator,
    required this.keyboardType,
  });

  final String title;
  final String label;
  final String confirmLabel;
  final String initialValue;
  final String? Function(String value)? validator;
  final TextInputType? keyboardType;

  @override
  State<_TextInputDialog> createState() => _TextInputDialogState();
}

class _TextInputDialogState extends State<_TextInputDialog> {
  late final _controller = TextEditingController(text: widget.initialValue);
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Select the name without the extension, like desktop file managers.
    final text = widget.initialValue;
    final dot = text.lastIndexOf('.');
    _controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: dot > 0 ? dot : text.length,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.of(context).pop(_controller.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = UpCloudLocalizations.of(context);
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          keyboardType: widget.keyboardType,
          decoration: InputDecoration(labelText: widget.label),
          validator: (value) {
            final text = value?.trim() ?? '';
            if (text.isEmpty) return l10n.nameRequired;
            return widget.validator?.call(text);
          },
          onFieldSubmitted: (_) => _submit(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(onPressed: _submit, child: Text(widget.confirmLabel)),
      ],
    );
  }
}

/// Asks the user to confirm an action. Returns `true` when confirmed.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  bool destructive = false,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) {
      final l10n = UpCloudLocalizations.of(context);
      final scheme = Theme.of(context).colorScheme;
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: destructive
                ? FilledButton.styleFrom(
                    backgroundColor: scheme.error,
                    foregroundColor: scheme.onError,
                  )
                : null,
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmLabel),
          ),
        ],
      );
    },
  );
  return confirmed ?? false;
}

/// Validates an http(s) URL. Returns the parsed URL or `null`.
Uri? parseHttpUrl(String text) {
  final url = Uri.tryParse(text.trim());
  if (url == null || !url.hasAuthority || url.host.isEmpty) return null;
  if (url.scheme != 'http' && url.scheme != 'https') return null;
  return url;
}
