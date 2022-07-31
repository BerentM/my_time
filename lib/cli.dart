library cli;

import 'package:args/args.dart';

ArgParser main() {
  var today = DateTime.now();
  var parser = ArgParser();
  parser.addFlag(
    "help",
    abbr: "h",
    help: "Display help menu.",
    negatable: false,
  );

  var show = parser.addCommand("show");
  show.addOption(
    "path",
    abbr: "p",
    help: "CSV file path.",
    defaultsTo: "${"${today.month}".padLeft(2, "0")}${today.year}.csv",
  );

  var add = parser.addCommand("add");
  add.addOption(
    "path",
    abbr: "p",
    help: "CSV file path.",
    defaultsTo: "${"${today.month}".padLeft(2, "0")}${today.year}.csv",
  );

  return parser;
}
