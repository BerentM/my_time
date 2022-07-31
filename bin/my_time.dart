import 'dart:io';
import 'package:args/args.dart';
import 'package:my_time/my_time.dart' as my_time;
import 'package:my_time/cli.dart' as cli;

void main(List<String> arguments) {
  var parser = cli.main();
  try {
    var parsed = parser.parse(arguments);
    print('Hello world: ${my_time.calculate()}!');
    if ((parsed.command?.name != null) & parsed.wasParsed("help")) {
      displayHelp(parser.commands[parsed.command!.name]!);
    } else if (parsed.wasParsed("help")) {
      displayHelp(parser);
    } else {
      stdout.writeln(parsed.command!.name);
      stdout.writeln(parsed.command!["path"]);
    }
  } catch (e) {
    stderr.writeln(e);
    stderr.writeln("Please refer --help for further assistance.");
    exitCode = 2;
  }
}

void displayHelp(ArgParser parser) {
  stdout.writeln(parser.usage);
  for (var k in parser.commands.keys) {
    stdout.writeln();
    stdout.writeln(k);
    stdout.writeln(parser.commands[k]?.usage);
  }
}
