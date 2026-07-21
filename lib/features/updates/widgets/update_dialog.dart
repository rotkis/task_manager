import 'package:flutter/material.dart';

import '../update_checker.dart';
import '../../../core/utils/permission_helper.dart';

/// Diálogo de nova versão disponível, com changelog e opções de
/// atualizar / adiar.
///
/// Quando o usuário clica em "Atualizar agora", faz o download do APK
/// com barra de progresso e, em seguida, abre o instalador nativo.
class UpdateDialog extends StatefulWidget {
  final ReleaseInfo release;
  final UpdateChecker checker;

  const UpdateDialog({
    super.key,
    required this.release,
    required this.checker,
  });

  /// Exibe o diálogo como um showDialog comum.
  static Future<void> show(
    BuildContext context, {
    required ReleaseInfo release,
    required UpdateChecker checker,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => UpdateDialog(release: release, checker: checker),
    );
  }

  @override
  State<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> {
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  String? _errorMessage;

  Future<void> _onUpdateNow() async {
    if (widget.release.apkUrl == null) {
      setState(() => _errorMessage = 'Nenhum APK encontrado nesta release.');
      return;
    }

    // Verifica permissão de instalar de fontes desconhecidas
    final canInstall = await PermissionHelper.checkInstallPackagesPermission();
    if (!canInstall && mounted) {
      final opened = await PermissionHelper.openInstallPackagesSettings();
      if (!opened) {
        setState(
            () => _errorMessage = 'Não foi possível abrir as configurações '
                'de instalação. Tente novamente.');
        return;
      }
      // Após voltar das configurações, verifica de novo
      final retry = await PermissionHelper.checkInstallPackagesPermission();
      if (!retry && mounted) {
        setState(() => _errorMessage = 'Permissão de instalação não concedida. '
            'Tente novamente.');
        return;
      }
    }

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
      _errorMessage = null;
    });

    try {
      final filePath = await widget.checker.downloadApk(
        widget.release.apkUrl!,
        onProgress: (progress) {
          if (mounted) {
            setState(() => _downloadProgress = progress);
          }
        },
      );

      if (!mounted) return;

      // Abre o instalador nativo via FileProvider
      await PermissionHelper.installApk(filePath);

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'Erro ao baixar atualização: $e');
        _isDownloading = false;
      }
    }
  }

  Future<void> _onLater() async {
    await widget.checker.markDismissed(widget.release.version);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.system_update, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          const Text('Nova versão disponível'),
        ],
      ),
      content: _isDownloading ? _buildProgress() : _buildContent(),
      actions: _isDownloading
          ? []
          : [
              TextButton(
                onPressed: _onLater,
                child: const Text('Depois'),
              ),
              FilledButton.icon(
                onPressed: _onUpdateNow,
                icon: const Icon(Icons.download),
                label: const Text('Atualizar agora'),
              ),
            ],
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'v${widget.release.version}',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          if (widget.release.changelog != null &&
              widget.release.changelog!.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text('O que há de novo:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(widget.release.changelog!),
          ],
        ],
      ),
    );
  }

  Widget _buildProgress() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LinearProgressIndicator(value: _downloadProgress),
        const SizedBox(height: 12),
        Text('${(_downloadProgress * 100).toStringAsFixed(0)}%'),
        if (_errorMessage != null) ...[
          const SizedBox(height: 8),
          Text(
            _errorMessage!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
      ],
    );
  }
}
