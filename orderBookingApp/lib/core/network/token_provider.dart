import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final tokenProvider =
    StateNotifierProvider<TokenNotifier, TokenState>((ref) {
  return TokenNotifier();
});

class TokenState {
  final String accessToken;
  final String refreshToken;
  final int roleId;
  final bool isLoggedIn;

  TokenState({
    required this.accessToken,
    required this.refreshToken,
    required this.roleId,
    required this.isLoggedIn,
  });

  factory TokenState.initial() => TokenState(
        accessToken: "",
        refreshToken: "",
        roleId: 0,
        isLoggedIn: false,
      );
}

class TokenNotifier extends StateNotifier<TokenState> {
  TokenNotifier() : super(TokenState.initial());

  final storage = const FlutterSecureStorage();

  /// SAVE TOKENS AFTER OTP SUCCESS
  Future<void> saveTokens(
      String accessToken, String refreshToken, int roleId) async {
    await storage.write(key: "accessToken", value: accessToken);
    await storage.write(key: "refreshToken", value: refreshToken);
    await storage.write(key: "roleId", value: roleId.toString());

    state = TokenState(
      accessToken: accessToken,
      refreshToken: refreshToken,
      roleId: roleId,
      isLoggedIn: true,
    );
  }

  /// LOAD TOKENS ON APP START
  Future<void> loadTokens() async {
    final accessToken = await storage.read(key: "accessToken") ?? "";
    final refreshToken = await storage.read(key: "refreshToken") ?? "";
    final roleId =
        int.tryParse(await storage.read(key: "roleId") ?? "0") ?? 0;

    state = TokenState(
      accessToken: accessToken,
      refreshToken: refreshToken,
      roleId: roleId,
      isLoggedIn: accessToken.isNotEmpty,
    );
  }

  /// LOGOUT
  Future<void> clearTokens() async {
    await storage.deleteAll();
    state = TokenState.initial();
  }
}
