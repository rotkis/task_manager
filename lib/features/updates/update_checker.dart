import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/version_compare.dart';

/// Resultado de uma checagem de atualização bem-sucedida.
class ReleaseInfo {
  final String version;
  final String? changelog;
  final String? apkUrl;

  const ReleaseInfo({
    required this.version,
    this.changelog,
    this.apkUrl,
  });
}

/// Serviço responsável por verificar e baixar atualizações via GitHub
/// Releases.
///
/// Toda a lógica de throttle (máx. 1 vez a cada 24h) e de versão
/// dispensada pelo usuário ("Depois") fica aqui.
class UpdateChecker {
  final http.Client _client;
  SharedPreferences? _prefs;

  UpdateChecker({http.Client? client}) : _client = client ?? http.Client();

  Future<SharedPreferences> get _sharedPrefs async =>
      _prefs ??= await SharedPreferences.getInstance();

  // ─── Verificação com throttle ─────────────────────────────────────

  /// Retorna `true` se a última checagem foi há mais de 24h **e** a
  /// versão remota não foi dispensada com "Depois".
  Future<bool> needsCheck() async {
    final prefs = await _sharedPrefs;

    // Throttle: no máximo 1 checagem a cada 24h
    final lastCheck = prefs.getInt(AppConstants.prefLastUpdateCheck);
    if (lastCheck != null) {
      final elapsed = DateTime.now().millisecondsSinceEpoch - lastCheck;
      if (elapsed < AppConstants.updateCheckIntervalHours * 3600000) {
        return false;
      }
    }

    return true;
  }

  /// Marca a checagem como realizada agora.
  Future<void> markChecked() async {
    final prefs = await _sharedPrefs;
    await prefs.setInt(
      AppConstants.prefLastUpdateCheck,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Guarda a versão que o usuário dispensou com "Depois".
  Future<void> markDismissed(String version) async {
    final prefs = await _sharedPrefs;
    await prefs.setString(AppConstants.prefDismissedVersion, version);
  }

  /// Retorna a versão dispensada (ou null se nunca dispensou).
  Future<String?> getDismissedVersion() async {
    final prefs = await _sharedPrefs;
    return prefs.getString(AppConstants.prefDismissedVersion);
  }

  // ─── Checagem remota ──────────────────────────────────────────────

  /// Faz a chamada HTTP para a GitHub API e compara a versão remota
  /// com a versão local instalada.
  ///
  /// Retorna um [ReleaseInfo] se houver uma versão mais nova disponível,
  /// ou `null` se:
  ///   - a requisição falhar (sem internet, GitHub fora do ar)
  ///   - a versão remota for igual ou menor que a instalada
  ///   - a versão remota já foi dispensada pelo usuário
  Future<ReleaseInfo?> checkForUpdate(String currentVersion) async {
    try {
      final response = await _client.get(
        Uri.parse(AppConstants.githubApiUrl),
        headers: {'Accept': 'application/vnd.github.v3+json'},
      );

      if (response.statusCode != 200) {
        // Falha silenciosa
        return null;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final tagName = data['tag_name'] as String?;
      if (tagName == null) return null;

      final remoteVersion = tagName.replaceFirst(RegExp(r'^v'), '');

      // Comparação semver
      if (compareVersion(remoteVersion, currentVersion) <= 0) {
        // Versão remota não é mais nova
        return null;
      }

      // Verifica se o usuário já dispensou esta versão
      final dismissed = await getDismissedVersion();
      if (dismissed != null && compareVersion(remoteVersion, dismissed) <= 0) {
        // Já dispensou esta versão ou uma igual/maior
        return null;
      }

      // Procura o APK nos assets
      String? apkUrl;
      final assets = data['assets'] as List<dynamic>?;
      if (assets != null) {
        for (final asset in assets) {
          final name = asset['name'] as String?;
          if (name != null && name.endsWith('.apk')) {
            apkUrl = asset['browser_download_url'] as String?;
            break;
          }
        }
      }

      return ReleaseInfo(
        version: remoteVersion,
        changelog: data['body'] as String?,
        apkUrl: apkUrl,
      );
    } catch (_) {
      // Falha silenciosa — nunca travar a abertura do app
      return null;
    }
  }

  // ─── Download e instalação ───────────────────────────────────────

  /// Baixa o APK da [url] para o diretório temporário do app.
  ///
  /// [onProgress] é chamado com um valor 0.0–1.0 conforme o download
  /// avança. Retorna o caminho do arquivo baixado.
  Future<String> downloadApk(
    String url, {
    void Function(double progress)? onProgress,
  }) async {
    final response = await _client.send(
      http.Request('GET', Uri.parse(url)),
    );

    final contentLength = response.contentLength ?? -1;
    final dir = await getTemporaryDirectory();
    final filePath = '${dir.path}/task_manager_update.apk';
    final file = File(filePath);

    final sink = file.openWrite();
    int bytesReceived = 0;

    await for (final chunk in response.stream) {
      sink.add(chunk);
      bytesReceived += chunk.length;
      if (contentLength > 0 && onProgress != null) {
        onProgress(bytesReceived / contentLength);
      }
    }

    await sink.flush();
    await sink.close();

    return filePath;
  }

  /// Libera recursos HTTP.
  void dispose() {
    _client.close();
  }
}
