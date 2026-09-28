import 'package:upcloud/src/accounts/cloud_account.dart';

/// Persists the accounts managed by `UpCloud`.
///
/// Implement it with secure storage in production apps: accounts contain
/// API keys and passwords.
abstract interface class AccountStore {
  /// Loads every saved account.
  Future<List<CloudAccount>> load();

  /// Replaces the saved accounts with [accounts].
  Future<void> save(List<CloudAccount> accounts);
}

/// Keeps accounts in memory only. Useful for tests and demos.
final class InMemoryAccountStore implements AccountStore {
  /// Creates a store with optional [initial] accounts.
  InMemoryAccountStore([List<CloudAccount> initial = const []])
    : _accounts = [...initial];

  List<CloudAccount> _accounts;

  @override
  Future<List<CloudAccount>> load() async => [..._accounts];

  @override
  Future<void> save(List<CloudAccount> accounts) async {
    _accounts = [...accounts];
  }
}
