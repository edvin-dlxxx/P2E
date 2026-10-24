// Generates tool-specific agent files from the canonical sources.
//
//   dart run tool/agents/sync_agent_files.dart          # write generated files
//   dart run tool/agents/sync_agent_files.dart --check  # CI: exit 1 when out of date or invalid
//
// Canonical sources:
//   docs/agents/rules/*.md     -> .cursor/rules/p2e-*.mdc   (Cursor)
//                              -> .claude/rules/p2e-*.md    (Claude Code)
//                              -> .agents/rules/p2e-*.md    (Antigravity)
//   .agents/skills/p2e-*/**    -> .claude/skills/p2e-*/**   (Claude Code; Codex, Cursor and
//                                                            Antigravity read .agents/skills directly)
// AGENTS.md is read natively by Codex, Cursor and Antigravity; CLAUDE.md imports it for Claude Code.
//
// Only files whose name starts with "p2e-" are managed, so personal rules and skills are never touched.
import 'dart:convert';
import 'dart:io';

const _rulesSrc = 'docs/agents/rules';
const _skillsSrc = '.agents/skills';
const _prefix = 'p2e-';
const _nameMax = 64;
const _descriptionMax = 1024;

final _errors = <String>[];

void main(List<String> args) {
  final check = args.contains('--check');
  if (!File('AGENTS.md').existsSync()) {
    stderr.writeln('Run from the repository root (AGENTS.md not found).');
    exit(2);
  }

  final expected = <String, List<int>>{}; // path -> bytes
  _buildRules(expected);
  _buildSkills(expected);

  if (_errors.isNotEmpty) {
    stderr.writeln('Invalid agent sources:');
    for (final e in _errors) {
      stderr.writeln('  - $e');
    }
    exit(1);
  }

  final managed = _existingManagedFiles();
  final stale = managed.where((p) => !expected.containsKey(p)).toList()..sort();
  final changed = <String>[];
  for (final entry in expected.entries) {
    final f = File(entry.key);
    if (!f.existsSync() || !_sameContent(f.readAsBytesSync(), entry.value)) {
      changed.add(entry.key);
    }
  }
  changed.sort();

  if (check) {
    if (changed.isEmpty && stale.isEmpty) {
      stdout.writeln(
        'Agent files are up to date (${expected.length} generated files).',
      );
      return;
    }
    stderr.writeln(
      'Agent files are out of date. Run: dart run tool/agents/sync_agent_files.dart',
    );
    for (final p in changed) {
      stderr.writeln('  changed: $p');
    }
    for (final p in stale) {
      stderr.writeln('  stale:   $p');
    }
    exit(1);
  }

  for (final p in changed) {
    final f = File(p);
    f.parent.createSync(recursive: true);
    f.writeAsBytesSync(expected[p]!);
    stdout.writeln('wrote   $p');
  }
  for (final p in stale) {
    File(p).deleteSync();
    stdout.writeln('removed $p');
  }
  _removeEmptyDirs(Directory('.claude/skills'));
  stdout.writeln(
    'Done: ${changed.length} written, ${stale.length} removed, ${expected.length} generated files total.',
  );
}

// ---------------------------------------------------------------- rules

void _buildRules(Map<String, List<int>> out) {
  final dir = Directory(_rulesSrc);
  if (!dir.existsSync()) {
    _errors.add('$_rulesSrc is missing');
    return;
  }
  final files =
      dir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.md'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));
  final ids = <String>{};
  for (final f in files) {
    final src = _rel(f.path);
    final doc = _parseFrontmatter(_normalize(f.readAsStringSync()), src);
    if (doc == null) continue;
    final id = doc.scalar('id');
    final description = doc.scalar('description');
    final globs = doc.list('globs');
    if (id == null ||
        !id.startsWith(_prefix) ||
        !RegExp(r'^[a-z0-9-]+$').hasMatch(id)) {
      _errors.add(
        '$src: "id" must be lowercase, hyphenated and start with "$_prefix"',
      );
      continue;
    }
    if (!ids.add(id)) _errors.add('$src: duplicate id "$id"');
    if (description == null || description.isEmpty) {
      _errors.add('$src: "description" is required');
    }
    if (globs.isEmpty) _errors.add('$src: at least one glob is required');
    for (final g in globs.where((g) => g.startsWith('*'))) {
      _errors.add(
        '$src: glob "$g" must start with a folder (e.g. lib/**/*.dart) so every tool parses it',
      );
    }
    if (description == null || globs.isEmpty) continue;

    final header =
        '<!-- GENERATED from $src by tool/agents/sync_agent_files.dart. Do not edit; edit the source. -->';
    final body = '$header\n\n${doc.body.trim()}\n';

    out['.cursor/rules/$id.mdc'] = _utf8(
      [
        '---',
        'description: ${_yamlString(description)}',
        'globs: ${globs.join(',')}',
        'alwaysApply: false',
        '---',
        body,
      ].join('\n'),
    );

    out['.claude/rules/$id.md'] = _utf8(
      [
        '---',
        'paths:',
        for (final g in globs) '  - ${_yamlString(g)}',
        '---',
        body,
      ].join('\n'),
    );

    out['.agents/rules/$id.md'] = _utf8(
      [
        '---',
        'trigger: glob',
        'description: ${_yamlString(description)}',
        'globs: ${_yamlString(globs.join(', '))}',
        '---',
        body,
      ].join('\n'),
    );
  }
}

// ---------------------------------------------------------------- skills

void _buildSkills(Map<String, List<int>> out) {
  final root = Directory(_skillsSrc);
  if (!root.existsSync()) {
    _errors.add('$_skillsSrc is missing');
    return;
  }
  final skillDirs =
      root
          .listSync()
          .whereType<Directory>()
          .where((d) => _base(d.path).startsWith(_prefix))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));
  for (final d in skillDirs) {
    final folder = _base(d.path);
    final skillFile = File('${d.path}/SKILL.md');
    if (!skillFile.existsSync()) {
      _errors.add('$_skillsSrc/$folder: SKILL.md is missing');
      continue;
    }
    final doc = _parseFrontmatter(
      _normalize(skillFile.readAsStringSync()),
      '$_skillsSrc/$folder/SKILL.md',
    );
    if (doc != null) {
      final name = doc.scalar('name');
      final description = doc.scalar('description');
      if (name != folder) {
        _errors.add('$_skillsSrc/$folder: "name" must equal the folder name');
      }
      if (name != null &&
          (name.length > _nameMax ||
              !RegExp(r'^[a-z0-9]+(-[a-z0-9]+)*$').hasMatch(name))) {
        _errors.add(
          '$_skillsSrc/$folder: "name" must be lowercase letters, digits and single hyphens, max $_nameMax',
        );
      }
      if (description == null || description.isEmpty) {
        _errors.add('$_skillsSrc/$folder: "description" is required');
      } else if (description.length > _descriptionMax) {
        _errors.add(
          '$_skillsSrc/$folder: "description" is ${description.length} chars (max $_descriptionMax)',
        );
      }
    }
    for (final f in d.listSync(recursive: true).whereType<File>()) {
      final rel = _rel(f.path).substring(_skillsSrc.length + 1);
      if (_base(rel) == '.DS_Store') continue;
      out['.claude/skills/$rel'] = f.readAsBytesSync();
    }
  }
}

// ---------------------------------------------------------------- managed outputs

List<String> _existingManagedFiles() {
  final result = <String>[];
  void flat(String dir, String ext) {
    final d = Directory(dir);
    if (!d.existsSync()) return;
    for (final f in d.listSync().whereType<File>()) {
      final b = _base(f.path);
      if (b.startsWith(_prefix) && b.endsWith(ext)) result.add(_rel(f.path));
    }
  }

  flat('.cursor/rules', '.mdc');
  flat('.claude/rules', '.md');
  flat('.agents/rules', '.md');
  final skills = Directory('.claude/skills');
  if (skills.existsSync()) {
    for (final d in skills.listSync().whereType<Directory>()) {
      if (!_base(d.path).startsWith(_prefix)) continue;
      for (final f in d.listSync(recursive: true).whereType<File>()) {
        result.add(_rel(f.path));
      }
    }
  }
  return result;
}

void _removeEmptyDirs(Directory root) {
  if (!root.existsSync()) return;
  for (final d in root.listSync().whereType<Directory>()) {
    if (!_base(d.path).startsWith(_prefix)) continue;
    _pruneEmpty(d);
  }
}

bool _pruneEmpty(Directory d) {
  var empty = true;
  for (final e in d.listSync()) {
    if (e is Directory) {
      if (!_pruneEmpty(e)) empty = false;
    } else {
      empty = false;
    }
  }
  if (empty) d.deleteSync();
  return empty;
}

// ---------------------------------------------------------------- frontmatter (minimal YAML subset)

class _Doc {
  _Doc(this.values, this.body);
  final Map<String, Object> values; // String or List<String>
  final String body;
  String? scalar(String k) => values[k] is String ? values[k] as String : null;
  List<String> list(String k) =>
      values[k] is List<String> ? values[k] as List<String> : const [];
}

/// Supports `key: value`, `key: "quoted"`, and `key:` followed by `  - item` lines.
_Doc? _parseFrontmatter(String text, String src) {
  final lines = text.split('\n');
  if (lines.isEmpty || lines.first.trim() != '---') {
    _errors.add('$src: must start with a "---" frontmatter block');
    return null;
  }
  final end = lines.indexWhere((l) => l.trim() == '---', 1);
  if (end < 0) {
    _errors.add('$src: frontmatter block is not closed');
    return null;
  }
  final values = <String, Object>{};
  String? listKey;
  for (final raw in lines.sublist(1, end)) {
    if (raw.trim().isEmpty || raw.trimLeft().startsWith('#')) continue;
    final item = RegExp(r'^\s+-\s+(.*)$').firstMatch(raw);
    if (item != null && listKey != null) {
      (values[listKey] as List<String>).add(_unquote(item.group(1)!.trim()));
      continue;
    }
    final kv = RegExp(r'^([A-Za-z_][\w-]*):\s*(.*)$').firstMatch(raw);
    if (kv == null) {
      _errors.add('$src: cannot parse frontmatter line "$raw"');
      continue;
    }
    final key = kv.group(1)!;
    final value = kv.group(2)!.trim();
    if (value.isEmpty) {
      values[key] = <String>[];
      listKey = key;
    } else {
      values[key] = _unquote(value);
      listKey = null;
    }
  }
  return _Doc(values, lines.sublist(end + 1).join('\n'));
}

String _unquote(String v) {
  if (v.length >= 2 &&
      ((v.startsWith('"') && v.endsWith('"')) ||
          (v.startsWith("'") && v.endsWith("'")))) {
    return v.substring(1, v.length - 1).replaceAll(r'\"', '"');
  }
  return v;
}

String _yamlString(String v) =>
    '"${v.replaceAll(r'\', r'\\').replaceAll('"', r'\"')}"';

// ---------------------------------------------------------------- helpers

String _normalize(String s) => s.replaceAll('\r\n', '\n');
List<int> _utf8(String s) => utf8.encode(s);
String _rel(String p) {
  var r = p.replaceAll('\\', '/');
  if (r.startsWith('./')) r = r.substring(2);
  return r;
}

String _base(String p) => _rel(p).split('/').last;

bool _sameContent(List<int> a, List<int> b) {
  // Compare text with CRLF normalized so Windows checkouts (core.autocrlf) do not fail the check.
  String t(List<int> x) {
    try {
      return _normalize(utf8.decode(x));
    } on FormatException {
      return String.fromCharCodes(x);
    }
  }

  if (a.length == b.length) {
    var same = true;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) {
        same = false;
        break;
      }
    }
    if (same) return true;
  }
  return t(a) == t(b);
}
