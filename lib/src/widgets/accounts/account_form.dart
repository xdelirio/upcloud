import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:upcloud/src/controllers/accounts_controller.dart';
import 'package:upcloud/src/l10n/upcloud_localizations.dart';
import 'package:upcloud/src/scope/upcloud_scope.dart';
import 'package:upcloud/src/widgets/accounts/provider_picker.dart';
import 'package:upcloud/src/widgets/common/dialogs.dart';
import 'package:upcloud/src/widgets/common/message_view.dart';
import 'package:upcloud/upcloud.dart';

final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

/// A login form generated from the [CredentialSchema] of a provider.
///
/// Without a fixed [provider], a dropdown at the top lets the user choose
/// one of [providers] and the credential fields follow the selection.
///
/// Each [CredentialField] becomes an input (text, secret, email or URL)
/// with validation and an optional help link. Submitting calls
/// `UpCloud.addAccount` (through [controller] when given) and reports
/// errors such as [AuthenticationException] inline.
///
/// The form is not scrollable; place it inside a scroll view.
class AccountForm extends StatefulWidget {
  /// Creates a form to connect an account.
  ///
  /// Pass [provider] to ask only for its credentials, or leave it `null` to
  /// let the user choose among [providers] (by default the providers of
  /// [controller] or of the [UpCloud] instance).
  const AccountForm({
    this.provider,
    this.providers,
    this.initialProviderId,
    this.upcloud,
    this.controller,
    this.onAdded,
    this.verify = true,
    this.showHeader = true,
    this.showLabelField = true,
    this.showAdvanced = true,
    this.onOpenHelpUrl,
    this.submitLabel,
    super.key,
  });

  /// Provider whose credentials are requested. When `null`, a provider
  /// dropdown is shown.
  final ProviderDefinition? provider;

  /// Providers offered in the dropdown when [provider] is `null`.
  final List<ProviderDefinition>? providers;

  /// Provider selected initially in the dropdown. Defaults to the first.
  final String? initialProviderId;

  /// Instance used to add the account. Defaults to the [UpCloudScope].
  final UpCloud? upcloud;

  /// When given, accounts are added with [AccountsController.add].
  final AccountsController? controller;

  /// Called with the new account after a successful submit.
  final ValueChanged<CloudAccount>? onAdded;

  /// Whether to check the credentials before saving the account.
  final bool verify;

  /// Whether to show the provider name above the fields when [provider] is
  /// fixed.
  final bool showHeader;

  /// Whether to ask for an optional account name.
  final bool showLabelField;

  /// Whether to offer the API base URL override.
  final bool showAdvanced;

  /// Opens help links (e.g. with `url_launcher`). When `null` the link is
  /// copied to the clipboard.
  final ValueChanged<Uri>? onOpenHelpUrl;

  /// Label of the submit button. Defaults to "Connect".
  final String? submitLabel;

  @override
  State<AccountForm> createState() => _AccountFormState();
}

class _AccountFormState extends State<AccountForm> {
  final _formKey = GlobalKey<FormState>();
  final _label = TextEditingController();
  final _baseUrl = TextEditingController();
  var _fields = <String, TextEditingController>{};
  final _revealed = <String>{};
  var _submitting = false;
  UpCloudException? _error;
  ProviderDefinition? _selected;
  var _fieldsFor = '';

  /// Providers offered in the dropdown.
  List<ProviderDefinition> get _choices =>
      widget.providers ??
      widget.controller?.providers ??
      (widget.upcloud ?? UpCloudScope.of(context)).providers;

  /// Provider whose fields are shown, `null` when there is none to choose.
  ProviderDefinition? get _provider => widget.provider ?? _selected;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.provider == null && _selected == null) {
      final choices = _choices;
      _selected =
          choices.where((p) => p.id == widget.initialProviderId).firstOrNull ??
          choices.firstOrNull;
    }
    _syncFields();
  }

  @override
  void didUpdateWidget(AccountForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncFields();
  }

  void _select(ProviderDefinition? provider) {
    if (provider == null || provider.id == _selected?.id) return;
    setState(() {
      _selected = provider;
      _syncFields();
    });
  }

  /// Recreates the inputs when the provider changes.
  void _syncFields() {
    final provider = _provider;
    final id = provider?.id ?? '';
    if (id == _fieldsFor) return;
    _disposeFields();
    _fieldsFor = id;
    _fields = {
      for (final field
          in provider?.credentialSchema.fields ?? const <CredentialField>[])
        field.id: TextEditingController(),
    };
    _revealed.clear();
    _error = null;
  }

  void _disposeFields() {
    for (final controller in _fields.values) {
      controller.dispose();
    }
  }

  @override
  void dispose() {
    _disposeFields();
    _label.dispose();
    _baseUrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final provider = _provider;
    if (_submitting || provider == null) return;
    setState(() => _error = null);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final credentials = provider.credentialSchema.applyDefaults(
      Credentials({
        for (final entry in _fields.entries)
          if (entry.value.text.trim().isNotEmpty)
            entry.key: entry.value.text.trim(),
      }),
    );
    final label = _label.text.trim();
    final baseUrl = parseHttpUrl(_baseUrl.text);
    setState(() => _submitting = true);
    try {
      final controller = widget.controller;
      final CloudAccount account;
      if (controller != null) {
        account = await controller.add(
          providerId: provider.id,
          credentials: credentials,
          label: label.isEmpty ? null : label,
          baseUrl: baseUrl,
          verify: widget.verify,
        );
      } else {
        final upcloud = widget.upcloud ?? UpCloudScope.of(context);
        account = await upcloud.addAccount(
          providerId: provider.id,
          credentials: credentials,
          label: label.isEmpty ? null : label,
          baseUrl: baseUrl,
          verify: widget.verify,
        );
      }
      if (!mounted) return;
      setState(() => _submitting = false);
      widget.onAdded?.call(account);
    } on Object catch (e, st) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = e is UpCloudException
            ? e
            : ProviderException('$e', cause: e, stackTrace: st);
      });
    }
  }

  Future<void> _openHelp(Uri url) async {
    final open = widget.onOpenHelpUrl;
    if (open != null) {
      open(url);
      return;
    }
    await Clipboard.setData(ClipboardData(text: url.toString()));
    if (mounted) {
      showUpCloudSnackBar(context, UpCloudLocalizations.of(context).linkCopied);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = UpCloudLocalizations.of(context);
    final material = Theme.of(context);
    final provider = _provider;
    if (provider == null) {
      return MessageView(
        icon: Icons.cloud_off_outlined,
        title: l10n.noProviders,
      );
    }
    final fields = provider.credentialSchema.fields;
    final info = provider.info;
    final error = _error;
    return Form(
      key: _formKey,
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.provider == null) ...[
              DropdownButtonFormField<String>(
                key: const ValueKey('upcloud-account-provider'),
                initialValue: provider.id,
                isExpanded: true,
                decoration: InputDecoration(labelText: l10n.provider),
                items: [
                  for (final choice in _choices)
                    DropdownMenuItem(
                      value: choice.id,
                      child: Row(
                        children: [
                          ProviderAvatar(info: choice.info, radius: 14),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              choice.info.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
                onChanged: _submitting
                    ? null
                    : (id) => _select(
                        _choices.where((p) => p.id == id).firstOrNull,
                      ),
              ),
              const SizedBox(height: 16),
            ] else if (widget.showHeader) ...[
              Row(
                children: [
                  ProviderAvatar(info: info),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      info.name,
                      style: material.textTheme.titleLarge,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
            if (widget.showLabelField) ...[
              TextFormField(
                key: const ValueKey('upcloud-account-label'),
                controller: _label,
                enabled: !_submitting,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: l10n.accountName,
                  helperText: l10n.optional,
                  prefixIcon: const Icon(Icons.label_outline_rounded),
                ),
              ),
              const SizedBox(height: 16),
            ],
            for (final (index, field) in fields.indexed) ...[
              _buildField(context, field, isLast: index == fields.length - 1),
              if (field.helpUrl case final url?)
                _HelpLink(url: url, onTap: () => _openHelp(url)),
              const SizedBox(height: 16),
            ],
            if (widget.showAdvanced)
              Theme(
                data: material.copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  childrenPadding: const EdgeInsets.only(bottom: 16),
                  title: Text(l10n.advanced),
                  children: [
                    TextFormField(
                      key: const ValueKey('upcloud-account-base-url'),
                      controller: _baseUrl,
                      enabled: !_submitting,
                      keyboardType: TextInputType.url,
                      decoration: InputDecoration(
                        labelText: l10n.baseUrl,
                        hintText: provider.defaultBaseUrl?.toString(),
                        helperText: l10n.baseUrlHelper,
                        helperMaxLines: 2,
                        prefixIcon: const Icon(Icons.dns_outlined),
                      ),
                      validator: (value) {
                        final text = value?.trim() ?? '';
                        if (text.isEmpty) return null;
                        return parseHttpUrl(text) == null
                            ? l10n.invalidUrl
                            : null;
                      },
                    ),
                  ],
                ),
              ),
            if (error != null) ...[
              _ErrorBanner(error: error),
              const SizedBox(height: 16),
            ],
            FilledButton.icon(
              onPressed: _submitting ? null : _submit,
              icon: _submitting
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.login_rounded),
              label: Text(widget.submitLabel ?? l10n.connect),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    BuildContext context,
    CredentialField field, {
    required bool isLast,
  }) {
    final l10n = UpCloudLocalizations.of(context);
    final label = l10n.credentialLabel(field);
    final isSecret = field.kind == CredentialInputKind.secret;
    final revealed = _revealed.contains(field.id);
    // Empty fields with a default value get it on submit.
    final mustFill = field.isRequired && field.defaultValue == null;
    return TextFormField(
      key: ValueKey('upcloud-credential-${field.id}'),
      controller: _fields[field.id],
      enabled: !_submitting,
      obscureText: isSecret && !revealed,
      autocorrect: false,
      enableSuggestions: !isSecret,
      keyboardType: switch (field.kind) {
        CredentialInputKind.text => TextInputType.text,
        CredentialInputKind.secret => TextInputType.visiblePassword,
        CredentialInputKind.email => TextInputType.emailAddress,
        CredentialInputKind.url => TextInputType.url,
      },
      autofillHints: switch (field.kind) {
        CredentialInputKind.email => const [AutofillHints.email],
        CredentialInputKind.secret when field.id == 'password' => const [
          AutofillHints.password,
        ],
        CredentialInputKind.text ||
        CredentialInputKind.secret ||
        CredentialInputKind.url => null,
      },
      textInputAction: isLast ? TextInputAction.done : TextInputAction.next,
      onFieldSubmitted: isLast ? (_) => _submit() : null,
      decoration: InputDecoration(
        labelText: mustFill ? label : '$label (${l10n.optional})',
        hintText: field.defaultValue,
        helperText: field.hint,
        helperMaxLines: 3,
        prefixIcon: Icon(switch (field.kind) {
          CredentialInputKind.text => Icons.person_outline_rounded,
          CredentialInputKind.secret => Icons.key_rounded,
          CredentialInputKind.email => Icons.alternate_email_rounded,
          CredentialInputKind.url => Icons.link_rounded,
        }),
        suffixIcon: isSecret
            ? IconButton(
                icon: Icon(
                  revealed
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
                tooltip: revealed ? l10n.hideSecret : l10n.showSecret,
                onPressed: () => setState(() {
                  if (!_revealed.remove(field.id)) _revealed.add(field.id);
                }),
              )
            : null,
      ),
      validator: (value) {
        final text = value?.trim() ?? '';
        if (text.isEmpty) {
          return mustFill ? l10n.fieldRequired(label) : null;
        }
        return switch (field.kind) {
          CredentialInputKind.email when !_emailPattern.hasMatch(text) =>
            l10n.invalidEmail,
          CredentialInputKind.url when parseHttpUrl(text) == null =>
            l10n.invalidUrl,
          _ => null,
        };
      },
    );
  }
}

class _HelpLink extends StatelessWidget {
  const _HelpLink({required this.url, required this.onTap});

  final Uri url;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = UpCloudLocalizations.of(context);
    final material = Theme.of(context);
    final color = material.colorScheme.primary;
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Text.rich(
            TextSpan(
              children: [
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Icon(
                    Icons.help_outline_rounded,
                    size: 16,
                    color: color,
                  ),
                ),
                TextSpan(text: ' ${l10n.whereToFind} '),
                TextSpan(
                  text: '${url.host}${url.path}',
                  style: const TextStyle(decoration: TextDecoration.underline),
                ),
              ],
            ),
            style: material.textTheme.bodySmall?.copyWith(color: color),
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.error});

  final UpCloudException error;

  @override
  Widget build(BuildContext context) {
    final l10n = UpCloudLocalizations.of(context);
    final material = Theme.of(context);
    final scheme = material.colorScheme;
    final title = l10n.errorMessage(error);
    final details = error.message.trim();
    final showDetails =
        error is! ProviderException && details.isNotEmpty && details != title;
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: scheme.errorContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              error is AuthenticationException
                  ? Icons.lock_outline_rounded
                  : Icons.error_outline_rounded,
              color: scheme.onErrorContainer,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: material.textTheme.bodyMedium?.copyWith(
                      color: scheme.onErrorContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (showDetails) ...[
                    const SizedBox(height: 4),
                    Text(
                      details,
                      style: material.textTheme.bodySmall?.copyWith(
                        color: scheme.onErrorContainer,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
