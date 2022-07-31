library cli;

import 'package:args/command_runner.dart';
import 'dart:io';

void main(List<String> args) {
  var runner = CommandRunner("my_time", """
== Quick Start ${'=' * 44}
If you want add task 'today's task'
my_time.exe add today's task

If you want to display current month tasks
my_time.exe show
${'=' * 59} """);
  runner.addCommand(AddCommand());
  runner.addCommand(ShowCommand());

  runner.run(args).catchError((error) {
    print(error);
    exit(64); // Exit code 64 indicates a usage error.
  });
}

class AddCommand extends Command {
  // The [name] and [description] properties must be defined by every
  // subclass.
  var today = DateTime.now();
  @override
  final name = "add";
  @override
  final description = "Add new row to CSV file.";

  AddCommand() {
    argParser.addOption(
      "path",
      abbr: "p",
      help: "CSV file path.",
      defaultsTo: "${"${today.month}".padLeft(2, "0")}${today.year}.csv",
    );
  }

  @override
  void run() {
    print(argResults?.arguments);
  }
}

class ShowCommand extends Command {
  // The [name] and [description] properties must be defined by every
  // subclass.
  var today = DateTime.now();
  @override
  final name = "show";
  @override
  final description = "Show CSV file contents.";

  ShowCommand() {
    argParser.addOption(
      "path",
      abbr: "p",
      help: "CSV file path.",
      defaultsTo: "${"${today.month}".padLeft(2, "0")}${today.year}.csv",
    );
  }

  @override
  void run() {
    print(argResults?.arguments);
  }
}

//   runner.argParser.addSeparator("""
// """);