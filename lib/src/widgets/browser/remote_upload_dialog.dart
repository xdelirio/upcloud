import 'package:flutter/material.dart';
import 'package:upcloud/src/l10n/upcloud_localizations.dart';
import 'package:upcloud/src/widgets/common/dialogs.dart';

/// Asks for the URL of a remote upload and an optional file name. Returns
/// `null` when cancelled.
Future<(Uri, String?)?> showRemoteUploadDialog(BuildContext context) =>
    showDialog<(Uri, String?)>(
      context: context,
      builder: (context) => const _RemoteUploadDialog(),
    );

class _RemoteUploadDialog extends StatefulWidget {
  const _RemoteUploadDialog();

  @override
  State<_RemoteUploadDialog> createState() => _RemoteUploadDialogState();
}

class _RemoteUploadDialogState extends State<_RemoteUploadDialog> {
  final _formKey = GlobalKey<FormState>();
  final _url = TextEditingController();
  final _name = TextEditingController();

  @override
  void dispose() {
    _url.dispose();
    _name.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final name = _name.text.trim();
    Navigator.of(context)
        .pop((parseHttpUrl(_url.text)!, name.isEmpty ? null : name));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = UpCloudLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.uploadFromUrl),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _url,
                autofocus: true,
                keyboardType: TextInputType.url,
                decoration: InputDecoration(
                  labelText: l10n.url,
                  hintText: 'https://',
                  prefixIcon: const Icon(Icons.link_rounded),
                ),
                validator: (value) =>
                    parseHttpUrl(value ?? '') == null ? l10n.invalidUrl : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _name,
                decoration: InputDecoration(labelText: l10n.fileNameOptional),
                onFieldSubmitted: (_) => _submit(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(onPressed: _submit, child: Text(l10n.upload)),
      ],
    );
  }
}
