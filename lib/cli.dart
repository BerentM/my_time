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
    argParser.addSeparator("message${' ' * 7}What have you been doing?");
    argParser.addOption(
      "path",
      abbr: "p",
      help: "CSV file path.",
      defaultsTo: "${"${today.month}".padLeft(2, "0")}${today.year}.csv",
    );
    argParser.addOption("date",
        abbr: "d",
        help: "Provide valid date [YYYY-MM-DD].",
        defaultsTo:
            "${today.year}-${"${today.month}".padLeft(2, "0")}-${"${today.day}".padLeft(2, "0")}");
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
      final newRow = [
        argResults?["date"],
        argResults?["time"],
        argResults?.rest.join(),
      ].join(";");
      // blindly creating file - it will leave it untouched if file exists
      File(path).createSync();

      final contents = await File(path).readAsLines();
      var i = 0;
      while (i < contents.length) {
        if (contents[i].split(";")[0] == argResults?["date"]) {
          break;
        }
        i++;
      }

      // because of brake in while loop new row will be added if loop exists faster
      i < contents.length ? contents[i] = newRow : contents.add(newRow);
      contents.sort();
      await File(path).writeAsString(contents.join("\n"));
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
    argParser.addOption(
      "path",
      abbr: "p",
      help: "CSV file path.",
      defaultsTo: "${"${today.month}".padLeft(2, "0")}${today.year}.csv",
    );
    argParser.addFlag(
      "time",
      abbr: "t",
      help: "Show time summary.",
    );
    argParser.addFlag(
      "all",
      abbr: "a",
      help: "Show whole file.",
    );
  }

  @override
  void run() {
    print(argResults?.arguments);
  }
}
