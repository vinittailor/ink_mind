// Network connectivity abstraction.
//
// Use cases and repositories depend on this interface rather than any platform
// package directly. Swap the implementation in get_it without changing
// any domain or presentation code.

/// Contract for checking network availability.
abstract interface class NetworkInfo {
  /// Returns `true` if the device currently has internet access.
  Future<bool> get isConnected;
}

/// Concrete implementation.
///
/// Currently returns `true` unconditionally as a placeholder — sufficient for
/// building and testing features against a live network.
///
/// To add real connectivity checking later:
///   1. Add `connectivity_plus` to pubspec.yaml.
///   2. Inject [Connectivity] from that package here.
///   3. Replace the body of [isConnected] with a platform check.
///   4. Re-register `NetworkInfoImpl` in [injection_container.dart] with the
///      new dependency — zero changes to use-case or repository code.
class NetworkInfoImpl implements NetworkInfo {
  const NetworkInfoImpl();

  @override
  Future<bool> get isConnected async => true; // TODO: wire connectivity_plus
}
