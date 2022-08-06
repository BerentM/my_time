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
      // TODO: add argument type checks, time needs to be numeric type
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
    // TODO: refactor it, move below spaghetti to separate functions
    var path = argResults?["path"];
    if (path != null) {
      final contents = await File(path).readAsLines();
      contents.sort();
      if (argResults?["time"] == true) {
        var timeSum = 0.0;
        for (var line in contents) {
          timeSum += double.parse(line.split(";")[1]);
        }
        if (argResults?["verbose"] == true) {
          final daysReported = contents.length;
          final meanTime = timeSum / contents.length;
          final firstReportedDay = DateTime.parse(contents[0].split(";")[0]);
          final firstMonthDay = DateTime(
            firstReportedDay.year,
            firstReportedDay.month,
            1,
          );
          final lastReportedDay = DateTime.parse(
            contents[contents.length - 1].split(";")[0],
          );
          final lastDayOfMonth = DateTime(
            lastReportedDay.year,
            lastReportedDay.month + 1,
            0,
          );
          final possibleDaysCount =
              lastDayOfMonth.difference(firstMonthDay).inDays + 1;
          final daysList = List.generate(
            possibleDaysCount,
            (i) => DateTime(
              firstMonthDay.year,
              firstMonthDay.month,
              firstMonthDay.day + (i),
            ),
          );
          var workingDays = 0;
          for (var day in daysList) {
            if (day.weekday < 6) {
              workingDays += 1;
            }
          }

          stdout.writeln("\tSummary");
          stdout.writeln(
            "Total:\t$timeSum ${timeSum < 2 ? 'hour' : 'hours'}",
          );
          if (argResults?["earnings"] != null) {
            // 0.88 because of PPE tax
            final earnings =
                (timeSum * double.parse(argResults?["earnings"])) * 0.88;
            stdout.writeln("Earned:\t${earnings.toStringAsFixed(2)} PLN");
          }
          stdout.writeln(
            "Mean:\t${meanTime.toStringAsFixed(2)} ${meanTime < 2 ? 'hour/day' : 'hours/day'}",
          );
          stdout.writeln(
            "Days:\t$daysReported/$workingDays days",
          );
        } else {
          stdout.writeln(timeSum);
        }
      }
      if (argResults?["all"] == true) {
        if (argResults?["verbose"] == true) {
          stdout.writeln("Day\t\tHours\tDescription");
          for (var line in contents) {
            var lineList = line.split(";");
            stdout.writeln(lineList.join("\t"));
          }
        } else {
          for (var line in contents) {
            stdout.writeln(line);
          }
        }
      }
      if ((argResults?["verbose"] == false) &
          (argResults?["earnings"] != null)) {
        var timeSum = 0.0;
        for (var line in contents) {
          timeSum += double.parse(line.split(";")[1]);
        }
        stdout.writeln(
            ((timeSum * double.parse(argResults?["earnings"])) * 0.88)
                .toStringAsFixed(2));
      }
    }
  }
}
