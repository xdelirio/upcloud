import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:upcloud/src/controllers/accounts_state.dart';
import 'package:upcloud/upcloud.dart';

/// Exposes the accounts of an [UpCloud] instance as a listenable [state].
///
/// ```dart
/// final accounts = AccountsController(upcloud);
/// await accounts.add(
///   providerId: 'demo',
///   credentials: Credentials.apiKey('key'),
/// );
/// ```
///
/// Operations store their error in [AccountsState.error] and also throw it
/// as an [UpCloudException].
class AccountsController extends ChangeNotifier {
  /// Creates a controller for [upcloud].
  ///
  /// Saved accounts are loaded with `UpCloud.init` unless [initialize] is
  /// false.
  AccountsController(this.upcloud, {bool initialize = true})
    : _state = AccountsState(accounts: upcloud.accounts) {
    _subscription = upcloud.accountChanges.listen(_onAccounts);
    // Provider names and icons may change with registry updates.
    _providersSubscription = upcloud.providerChanges.listen(
      (_) => _emit(_state),
    );
    if (initialize) unawaited(init());
  }

  /// The wrapped instance.
  final UpCloud upcloud;

  late final StreamSubscription<List<CloudAccount>> _subscription;
  late final StreamSubscription<List<ProviderDefinition>>
  _providersSubscription;
  AccountsState _state;
  var _disposed = false;

  /// Current state.
  AccountsState get state => _state;

  /// Registered providers.
  List<ProviderDefinition> get providers => upcloud.providers;

  /// Provider definition of [account], or `null` if it is not registered.
  ProviderDefinition? providerOf(CloudAccount account) =>
      upcloud.provider(account.providerId);

  /// Loads the saved accounts. Safe to call more than once.
  Future<void> init() async {
    _emit(_state.copyWith(isLoading: true, error: null));
    try {
      await upcloud.init();
      _emit(_state.copyWith(isLoading: false, accounts: upcloud.accounts));
    } on Object catch (e, st) {
      _emit(_state.copyWith(isLoading: false, error: _wrap(e, st)));
    }
  }

  /// Connects a new account; see `UpCloud.addAccount`.
  ///
  /// When [verify] is true the credentials are checked first and an
  /// [AuthenticationException] is thrown if the provider rejects them.
  Future<CloudAccount> add({
    required String providerId,
    required Credentials credentials,
    String? label,
    Uri? baseUrl,
    bool verify = true,
  }) => _run(() async {
    final account = await upcloud.addAccount(
      providerId: providerId,
      credentials: credentials,
      label: label,
      baseUrl: baseUrl,
      verify: verify,
    );
    if (verify) {
      _setStatus(account.id, const AccountStatus.connected());
    }
    return account;
  });

  /// Changes the name of account [accountId].
  Future<void> rename(String accountId, String label) => _run(() async {
    final account = upcloud.account(accountId);
    if (account == null) throw NotFoundException('Unknown account $accountId');
    await upcloud.updateAccount(account.copyWith(label: label.trim()));
  });

  /// Removes account [accountId] and cancels its transfers.
  Future<void> remove(String accountId) => _run(() async {
    await upcloud.removeAccount(accountId);
    _emit(
      _state.copyWith(
        statuses: Map.unmodifiable({..._state.statuses}..remove(accountId)),
      ),
    );
  });

  /// Checks that account [accountId] still accepts its credentials.
  ///
  /// Uses account info when available (which also reports storage) or
  /// lists the root folder. The result is stored in
  /// [AccountsState.statuses] and returned; this method does not throw.
  Future<AccountStatus> verify(String accountId) async {
    _setStatus(accountId, const AccountStatus.checking());
    AccountStatus status;
    try {
      final provider = upcloud.connect(accountId);
      if (provider is AccountInfoProviding) {
        status = AccountStatus.connected(info: await provider.accountInfo());
      } else {
        await UpCloud.verifyConnection(provider);
        status = const AccountStatus.connected();
      }
    } on Object catch (e, st) {
      status = AccountStatus.failed(_wrap(e, st));
    }
    if (upcloud.account(accountId) != null) _setStatus(accountId, status);
    return status;
  }

  /// Checks every account at the same time; see [verify].
  Future<void> verifyAll() =>
      Future.wait([for (final account in _state.accounts) verify(account.id)]);

  /// Clears [AccountsState.error].
  void clearError() {
    if (_state.error != null) _emit(_state.copyWith(error: null));
  }

  Future<T> _run<T>(Future<T> Function() action) async {
    _emit(_state.copyWith(isBusy: true, error: null));
    try {
      final result = await action();
      _emit(_state.copyWith(isBusy: false, accounts: upcloud.accounts));
      return result;
    } on Object catch (e, st) {
      final error = _wrap(e, st);
      _emit(_state.copyWith(isBusy: false, error: error));
      if (e is UpCloudException) rethrow;
      Error.throwWithStackTrace(error, st);
    }
  }

  void _setStatus(String accountId, AccountStatus status) => _emit(
    _state.copyWith(
      statuses: Map.unmodifiable({..._state.statuses, accountId: status}),
    ),
  );

  void _onAccounts(List<CloudAccount> accounts) {
    final ids = {for (final a in accounts) a.id};
    _emit(
      _state.copyWith(
        accounts: accounts,
        statuses: Map.unmodifiable({
          for (final entry in _state.statuses.entries)
            if (ids.contains(entry.key)) entry.key: entry.value,
        }),
      ),
    );
  }

  UpCloudException _wrap(Object error, StackTrace stackTrace) =>
      error is UpCloudException
      ? error
      : ProviderException('$error', cause: error, stackTrace: stackTrace);

  void _emit(AccountsState state) {
    if (_disposed) return;
    _state = state;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    unawaited(_subscription.cancel());
    unawaited(_providersSubscription.cancel());
    super.dispose();
  }
}
