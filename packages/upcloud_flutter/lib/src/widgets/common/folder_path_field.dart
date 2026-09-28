import 'package:flutter/material.dart';
import 'package:upcloud_flutter/src/l10n/upcloud_localizations.dart';

/// A text field for a folder path (`Movies/2026`) with suggestions.
///
/// Suggestions matching the text (ignoring case) are offered while the
/// field has focus.
class FolderPathField extends StatelessWidget {
  /// Creates a folder path field.
  const FolderPathField({
    required this.controller,
    required this.focusNode,
    required this.label,
    this.helperText,
    this.suggestions = const [],
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.fieldKey,
    super.key,
  });

  /// Text of the field.
  final TextEditingController controller;

  /// Focus of the field.
  final FocusNode focusNode;

  /// Label of the field.
  final String label;

  /// Text below the field.
  final String? helperText;

  /// Paths offered while typing, most relevant first.
  final List<String> suggestions;

  /// Called when the text changes (typing, clearing or picking a
  /// suggestion).
  final ValueChanged<String>? onChanged;

  /// Called when the user submits the field.
  final ValueChanged<String>? onSubmitted;

  /// Whether the field accepts input.
  final bool enabled;

  /// Key of the inner [TextField], for tests.
  final Key? fieldKey;

  Iterable<String> _options(TextEditingValue value) {
    final query = value.text.trim().toLowerCase();
    return suggestions.where((path) {
      final lower = path.toLowerCase();
      return lower != query && (query.isEmpty || lower.contains(query));
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = UpCloudLocalizations.of(context);
    return Autocomplete<String>(
      textEditingController: controller,
      focusNode: focusNode,
      optionsBuilder: _options,
      onSelected: onChanged,
      optionsViewBuilder: (context, onSelected, options) =>
          _Options(options: options.toList(), onSelected: onSelected),
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) =>
          ListenableBuilder(
            listenable: controller,
            builder: (context, _) => TextField(
              key: fieldKey,
              controller: controller,
              focusNode: focusNode,
              enabled: enabled,
              autocorrect: false,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: label,
                hintText: l10n.folderPathHint,
                helperText: helperText,
                helperMaxLines: 3,
                prefixIcon: const Icon(Icons.folder_outlined),
                suffixIcon: controller.text.isEmpty || !enabled
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close_rounded),
                        tooltip: l10n.clear,
                        onPressed: () {
                          controller.clear();
                          onChanged?.call('');
                        },
                      ),
              ),
              onChanged: onChanged,
              onSubmitted: (value) {
                onFieldSubmitted();
                onSubmitted?.call(value);
              },
            ),
          ),
    );
  }
}

class _Options extends StatelessWidget {
  const _Options({required this.options, required this.onSelected});

  final List<String> options;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final highlighted = AutocompleteHighlightedOption.of(context);
    return Align(
      alignment: AlignmentDirectional.topStart,
      child: Material(
        elevation: 3,
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 240),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 4),
            shrinkWrap: true,
            itemCount: options.length,
            itemBuilder: (context, index) {
              final option = options[index];
              return ListTile(
                dense: true,
                selected: index == highlighted,
                leading: const Icon(Icons.history_rounded, size: 20),
                title: Text(option),
                onTap: () => onSelected(option),
              );
            },
          ),
        ),
      ),
    );
  }
}
