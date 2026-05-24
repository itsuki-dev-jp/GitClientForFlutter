import 'dart:io';

import 'package:gitclient/config/git_executable.dart';

/// `git --version` の結果を返す。
class GitVersionService {
  Future<String> fetchVersion() async {
    final gitExe = File(GitExecutable.path);
    if (!await gitExe.exists()) {
      throw GitVersionException('git.exe が見つかりません: ${GitExecutable.path}');
    }

    final result = await Process.run(GitExecutable.path, const [
      '--version',
    ], runInShell: false);

    if (result.exitCode != 0) {
      final stderr = result.stderr.toString().trim();
      throw GitVersionException(
        stderr.isEmpty
            ? 'git --version が失敗しました (exit ${result.exitCode})'
            : stderr,
      );
    }

    return result.stdout.toString().trim();
  }
}

class GitVersionException implements Exception {
  GitVersionException(this.message);

  final String message;

  @override
  String toString() => message;
}
