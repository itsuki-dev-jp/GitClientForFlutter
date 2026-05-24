import 'package:flutter/material.dart';
import 'package:gitclient/config/git_executable.dart';
import 'package:gitclient/services/git_version_service.dart';

void main() {
  runApp(const GitClientApp());
}

class GitClientApp extends StatelessWidget {
  const GitClientApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Git Client',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const GitVersionPage(),
    );
  }
}

class GitVersionPage extends StatefulWidget {
  const GitVersionPage({super.key});

  @override
  State<GitVersionPage> createState() => _GitVersionPageState();
}

class _GitVersionPageState extends State<GitVersionPage> {
  final _gitVersionService = GitVersionService();

  String? _versionText;
  String? _errorText;
  bool _isLoading = false;

  Future<void> _checkGitVersion() async {
    setState(() {
      _isLoading = true;
      _versionText = null;
      _errorText = null;
    });

    try {
      final version = await _gitVersionService.fetchVersion();
      if (!mounted) return;
      setState(() {
        _versionText = version;
        _isLoading = false;
      });
    } on GitVersionException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorText = e.message;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorText = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Git Client'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Git 実行ファイル',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            SelectableText(
              GitExecutable.path,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontFamily: 'monospace',
                  ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _isLoading ? null : _checkGitVersion,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Git バージョンを確認'),
            ),
            const SizedBox(height: 24),
            Text(
              '結果',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  _versionText ?? _errorText ?? 'ボタンを押すと git --version を実行します。',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: _errorText != null ? Theme.of(context).colorScheme.error : null,
                        fontFamily: _versionText != null ? 'monospace' : null,
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
