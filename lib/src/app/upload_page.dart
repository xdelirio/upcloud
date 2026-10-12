import 'package:flutter/material.dart';
import 'package:upcloud/src/app/file_io.dart';
import 'package:upcloud/src/app/glass_chrome.dart';
import 'package:upcloud/src/app/page_scaffold.dart';
import 'package:upcloud/ui.dart';

/// Uploads several files to several accounts at once with
/// [UploadComposer].
///
/// The page owns the composer controller, so the floating glass button can
/// start the uploads.
class UploadPage extends StatefulWidget {
  const UploadPage({required this.onSubmitted, super.key});

  /// Called with the started batch.
  final ValueChanged<UploadBatch> onSubmitted;

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  late final UploadComposerController _composer = UploadComposerController(
    UpCloudScope.of(context),
  );

  @override
  void dispose() {
    _composer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = UpCloudLocalizations.of(context);
    return PageScaffold(
      title: Text(l10n.upload),
      body: UploadComposer(
        controller: _composer,
        onPickFiles: pickUploadSources,
        onSubmitted: widget.onSubmitted,
        // The floating glass button submits.
        showSubmitButton: false,
        padding: panelListPadding(
          context,
          extra: 96,
        ).copyWith(left: 12, right: 12, top: 12),
      ),
      primaryAction: ListenableBuilder(
        listenable: _composer,
        builder: (context, _) => GlassActionButton(
          icon: Icons.cloud_upload_rounded,
          label: _composer.canSubmit
              ? l10n.startUploads(_composer.uploadCount)
              : l10n.upload,
          onPressed: _composer.canSubmit
              ? () => submitComposer(_composer, onSubmitted: widget.onSubmitted)
              : null,
        ),
      ),
    );
  }
}
