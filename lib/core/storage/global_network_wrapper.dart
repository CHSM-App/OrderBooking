
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_booking_app/core/network/dio_provider.dart';
import 'package:order_booking_app/presentation/providers/viewModel_provider.dart';
import 'package:order_booking_app/presentation/viewModels/network_model.dart';



class GlobalNetworkWrapper extends ConsumerStatefulWidget {
  final Widget child;

  const GlobalNetworkWrapper({super.key, required this.child});

  @override
  ConsumerState<GlobalNetworkWrapper> createState() =>
      _GlobalNetworkWrapperState();
}

class _GlobalNetworkWrapperState extends ConsumerState<GlobalNetworkWrapper> {
  bool? _lastKnownNetworkState;
  bool? _lastKnownApiState;
  OverlayEntry? _currentOverlay;
  bool _isInitialized = false;
  String? _currentErrorType; // 'network' or 'api'

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeStates();
    });
  }

  void _initializeStates() {
    if (!mounted) return;

    final networkState = ref.read(networkStateProvider);
    final apiState = ref.read(apiStateProvider);

    if (networkState.isInitialized) {
      _lastKnownNetworkState = networkState.isConnected;
    }
    _lastKnownApiState = apiState.isApiAvailable;
    _isInitialized = true;

    print(
        '✅ GlobalNetworkWrapper initialized - Network: $_lastKnownNetworkState, API: $_lastKnownApiState');
  }

  @override
  Widget build(BuildContext context) {
    final networkState = ref.watch(networkStateProvider);
    final apiState = ref.watch(apiStateProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (_isInitialized) {
        _handleNetworkChange(networkState);
        _handleApiChange(networkState, apiState);
      } else if (networkState.isInitialized) {
        _initializeStates();
      }
    });

    return widget.child;
  }

  void _handleNetworkChange(NetworkState current) {
    if (!current.isInitialized || !mounted) return;

    // Network lost during runtime
    if (_lastKnownNetworkState == true && !current.isConnected) {
   //   print('🔴 Network lost - showing no internet overlay');
      _showNetworkOverlay();
    }
    // Network restored
    else if (_lastKnownNetworkState == false && current.isConnected) {
     // print('🟢 Network restored - hiding overlay');
      _hideOverlay();
    }

    _lastKnownNetworkState = current.isConnected;
  }

  void _handleApiChange(NetworkState networkState, ApiState current) {
    if (!networkState.isConnected || !mounted) return;

    // API failed during runtime
    if (_lastKnownApiState == true &&
        !current.isApiAvailable &&
        current.lastChecked != null) {
      print('🔴 API down - showing server down overlay');
      _showServerOverlay();
    }
    // API restored
    else if (_lastKnownApiState == false && current.isApiAvailable) {
      print('🟢 API restored - hiding overlay');
      _hideOverlay();
    }

    _lastKnownApiState = current.isApiAvailable;
  }

  void _showNetworkOverlay() {
    if (_currentOverlay != null && _currentErrorType == 'network') {
      return;
    }

    _hideOverlay(); // hide existing overlay
    _currentErrorType = 'network';

    _currentOverlay = OverlayEntry(
      builder: (context) {
        final networkState = ref.watch(networkStateProvider);
        return Material(
          color: Colors.black87,
          child: WillPopScope(
            onWillPop: () async => false,
            child: SafeArea(
              child: Center(
                child: Container(
                  margin: const EdgeInsets.all(32),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.wifi_off_rounded,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Connection Lost',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        networkState.errorMessage ??
                            'Your internet connection was lost.\nPlease check your connection.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: networkState.isRetrying
                              ? null
                              : () async {
                                  await ref
                                      .read(networkStateProvider.notifier)
                                      .retryConnection(context);
                                },
                          icon: networkState.isRetrying
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.refresh),
                          label: networkState.isRetrying
                              ? const Text("Checking...")
                              : const Text("Retry Connection"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_currentOverlay!);
  }

  void _showServerOverlay() {
    if (_currentOverlay != null && _currentErrorType == 'api') return;

    _hideOverlay();
    _currentErrorType = 'api';

    _currentOverlay = OverlayEntry(
      builder: (context) {
        final apiState = ref.watch(apiStateProvider);
        return Material(
          color: Colors.black87,
          child: WillPopScope(
            onWillPop: () async => false,
            child: SafeArea(
              child: Center(
                child: Container(
                  margin: const EdgeInsets.all(32),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E2C),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.dns_rounded,
                        size: 64,
                        color: Colors.red.shade300,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Server Error',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'The server is not responding.\nThis is usually temporary.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.white70),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: apiState.isChecking
                              ? null
                              : () async {
                                  await ref
                                      .read(apiStateProvider.notifier)
                                      .checkApiHealth();
                                },
                          icon: apiState.isChecking
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.refresh),
                          label: apiState.isChecking
                              ? const Text("Checking...")
                              : const Text("Retry Server"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_currentOverlay!);
  }

  void _hideOverlay() {
    _currentOverlay?.remove();
    _currentOverlay = null;
    _currentErrorType = null;
  }

  @override
  void dispose() {
    _hideOverlay();
    super.dispose();
  }
}
