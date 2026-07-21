import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:task_manager/core/constants/app_constants.dart';
import 'package:task_manager/features/updates/update_checker.dart';

/// Mock manual de [http.Client] — retorna respostas pré-programadas.
class MockHttpClient extends http.BaseClient {
  final Map<String, http.Response> _responses = {};

  /// Registra uma resposta para uma URL exata.
  void register(String url, http.Response response) {
    _responses[url] = response;
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    final url = request.url.toString();
    final response = _responses[url];
    if (response == null) {
      throw Exception('Nenhuma resposta registrada para: $url');
    }
    return Future.value(
      http.StreamedResponse(
        Stream.value(response.bodyBytes),
        response.statusCode,
        headers: response.headers,
      ),
    );
  }
}

void main() {
  late MockHttpClient mockClient;
  late UpdateChecker checker;

  setUp(() {
    mockClient = MockHttpClient();
    checker = UpdateChecker(client: mockClient);
    // SharedPreferences: limpa o cache a cada teste
    SharedPreferences.setMockInitialValues({});
  });

  // ─── Throttle / Dismiss ─────────────────────────────────────────

  group('UpdateChecker — needsCheck / markChecked / markDismissed', () {
    test('needsCheck retorna true na primeira vez', () async {
      expect(await checker.needsCheck(), isTrue);
    });

    test('needsCheck retorna false se checou há menos de 24h', () async {
      await checker.markChecked();
      expect(await checker.needsCheck(), isFalse);
    });

    test('getDismissedVersion retorna null se nunca dispensou', () async {
      expect(await checker.getDismissedVersion(), isNull);
    });

    test('markDismissed guarda a versão', () async {
      await checker.markDismissed('2.0.0');
      expect(await checker.getDismissedVersion(), '2.0.0');
    });
  });

  // ─── checkForUpdate ─────────────────────────────────────────────

  group('UpdateChecker — checkForUpdate', () {
    const currentVersion = '1.0.0';
    const apiUrl = AppConstants.githubApiUrl;

    void mockRelease(Map<String, dynamic> body) {
      mockClient.register(
        apiUrl,
        http.Response(jsonEncode(body), 200),
      );
    }

    test('retorna ReleaseInfo se versão remota é maior', () async {
      mockRelease({
        'tag_name': 'v1.1.0',
        'body': 'Correções de bugs',
        'assets': [
          {
            'name': 'app-release.apk',
            'browser_download_url':
                'https://github.com/rotkis/task_manager/releases/download/v1.1.0/app-release.apk',
          },
        ],
      });

      final result = await checker.checkForUpdate(currentVersion);

      expect(result, isNotNull);
      expect(result!.version, '1.1.0');
      expect(result.changelog, 'Correções de bugs');
      expect(
        result.apkUrl,
        'https://github.com/rotkis/task_manager/releases/download/v1.1.0/app-release.apk',
      );
    });

    test('retorna ReleaseInfo sem APK nos assets (só changelog)', () async {
      mockRelease({
        'tag_name': 'v1.1.0',
        'body': 'Apenas changelog',
        'assets': [],
      });

      final result = await checker.checkForUpdate(currentVersion);

      expect(result, isNotNull);
      expect(result!.version, '1.1.0');
      expect(result.changelog, 'Apenas changelog');
      expect(result.apkUrl, isNull);
    });

    test('retorna null se versão remota é igual', () async {
      mockRelease({'tag_name': 'v1.0.0', 'assets': []});
      final result = await checker.checkForUpdate(currentVersion);
      expect(result, isNull);
    });

    test('retorna null se versão remota é menor', () async {
      mockRelease({'tag_name': 'v0.9.0', 'assets': []});
      final result = await checker.checkForUpdate(currentVersion);
      expect(result, isNull);
    });

    test('retorna null se falha HTTP (status != 200)', () async {
      mockClient.register(
        apiUrl,
        http.Response('Not Found', 404),
      );
      final result = await checker.checkForUpdate(currentVersion);
      expect(result, isNull);
    });

    test('retorna null se exceção de rede (falha silenciosa)', () async {
      // Não registra resposta — o mock vai lançar exceção
      final result = await checker.checkForUpdate(currentVersion);
      expect(result, isNull);
    });

    test('retorna null se versão já foi dispensada', () async {
      await checker.markDismissed('1.1.0');
      mockRelease({'tag_name': 'v1.1.0', 'assets': []});

      final result = await checker.checkForUpdate(currentVersion);
      expect(result, isNull);
    });

    test('retorna release se versão é mais nova que a dispensada', () async {
      await checker.markDismissed('1.1.0');
      mockRelease({
        'tag_name': 'v2.0.0',
        'body': 'Versão grande',
        'assets': [],
      });

      final result = await checker.checkForUpdate(currentVersion);
      expect(result, isNotNull);
      expect(result!.version, '2.0.0');
    });

    test('retorna null se release não tem tag_name', () async {
      mockRelease({'body': 'no tag'});
      final result = await checker.checkForUpdate(currentVersion);
      expect(result, isNull);
    });

    test('throttle + dismiss combinados: nova versão não dispensada passa',
        () async {
      // Cenário: já checou há <24h, mas versão remota (3.0.0) é mais nova
      // que a dispensada (2.0.0). needsCheck deve retornar false pelo
      // throttle, então checkForUpdate não é chamado de fato.
      await checker.markChecked();
      await checker.markDismissed('2.0.0');

      // needsCheck: throttle de 24h impede nova checagem
      expect(await checker.needsCheck(), isFalse);

      // Se mesmo assim forçar checkForUpdate, a versão 3.0.0 não foi
      // dispensada (dispensou 2.0.0), então retornaria release.
      mockRelease({'tag_name': 'v3.0.0', 'body': 'Maior', 'assets': []});
      final result = await checker.checkForUpdate(currentVersion);
      expect(result, isNotNull);
      expect(result!.version, '3.0.0');
    });
  });
}
