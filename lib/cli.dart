library cli;

import 'package:args/command_runner.dart';
import 'dart:io';

import 'package:my_time/my_time.dart';

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
    var formattedMonth = "${today.month}".padLeft(2, "0");
    var formattedDay = "${today.day}".padLeft(2, "0");

    argParser.addSeparator("message${' ' * 7}What have you been doing?");
    argParser.addOption(
      "path",
      abbr: "p",
      help: "CSV file path.",
      defaultsTo: "$formattedMonth${today.year}.csv",
    );
    argParser.addOption("date",
        abbr: "d",
        help: "Provide valid date [YYYY-MM-DD].",
        defaultsTo: "${today.year}-$formattedMonth-$formattedDay");
    argParser.addOption(
      "time",
      abbr: "t",
      help: "How many hours have you worked?",
      defaultsTo: "8",
    );
  }

  @override
  void run() async {
    var path = argResults?["path"];
    if (path != null) {
      parseAdd(argResults!);
    }
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
    var formattedMonth = "${today.month}".padLeft(2, "0");

    argParser.addOption(
      "path",
      abbr: "p",
      help: "CSV file path.",
      defaultsTo: "$formattedMonth${today.year}.csv",
    );
    argParser.addOption(
      "earnings",
      abbr: "e",
      help: "Your hourly wage in PLN",
    );
    argParser.addFlag(
      "time",
      abbr: "t",
      help: "Show time summary.",
      negatable: false,
    );
    argParser.addFlag(
      "all",
      abbr: "a",
      help: "Show whole file.",
      negatable: false,
    );
    argParser.addFlag(
      "verbose",
      abbr: "v",
      help: "Output more descriptive information.",
      negatable: false,
    );
  }

  @override
  void run() async {
    var path = argResults?["path"];
    if (path != null) {
      parseShow(argResults!);
    }
  }
}
