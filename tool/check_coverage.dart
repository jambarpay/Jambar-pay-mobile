import 'dart:io';

void main(List<String> arguments) {
  if (arguments.length != 2) {
    stderr.writeln('Usage: dart run tool/check_coverage.dart <lcov> <minimum>');
    exitCode = 64;
    return;
  }

  final report = File(arguments[0]);
  final minimum = double.tryParse(arguments[1]);
  if (!report.existsSync() || minimum == null) {
    stderr.writeln('Invalid coverage report or minimum percentage.');
    exitCode = 66;
    return;
  }

  var found = 0;
  var hit = 0;
  for (final line in report.readAsLinesSync()) {
    if (line.startsWith('LF:')) {
      found += int.parse(line.substring(3));
    } else if (line.startsWith('LH:')) {
      hit += int.parse(line.substring(3));
    }
  }

  final coverage = found == 0 ? 0.0 : hit * 100 / found;
  stdout.writeln(
    'Coverage: ${coverage.toStringAsFixed(2)}% ($hit/$found lines)',
  );
  if (coverage < minimum) {
    stderr.writeln(
      'Coverage is below the required ${minimum.toStringAsFixed(2)}%.',
    );
    exitCode = 1;
  }
}
