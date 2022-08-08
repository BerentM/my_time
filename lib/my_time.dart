import 'dart:io';

import 'package:args/args.dart';

Future<List<String>> readFile(String path) async {
  final contents = await File(path).readAsLines();
  contents.sort();
  return contents;
}

void parseAllFlag(ArgResults res, List<String> contents) {
  stdout.writeln("Day\t\tHours\tDescription");
  for (var line in contents) {
    var lineList = line.split(";");
    stdout.writeln(lineList.join("\t"));
  }
}

dynamic calculateEarnings(double hours, double hourlyWage,
    {bool stringify = false}) {
  // 0.88 because of PPE tax
  if (hours <= 0) {
    throw ArgumentError("value need to be higher than 0", "hours");
  }
  if (hourlyWage <= 0) {
    throw ArgumentError("value need to be higher than 0", "hourlyWage");
  }
  final earnings = (hours * hourlyWage) * 0.88;
  return stringify ? (earnings).toStringAsFixed(2) : earnings;
}

void parseNonVerboseEarnings(ArgResults res, List<String> contents) {
  var timeSum = 0.0;
  for (var line in contents) {
    timeSum += double.parse(line.split(";")[1]);
  }
  stdout.writeln(calculateEarnings(timeSum, double.parse(res["earnings"])));
}

int countWorkingDays(DateTime start, DateTime end) {
  // generate list of days between first and last day of month
  final daysList = List.generate(
    end.difference(start).inDays + 1,
    (i) => DateTime(
      start.year,
      start.month,
      start.day + (i),
    ),
  );

  var workingDays = 0;
  for (var day in daysList) {
    if (day.weekday < 6) {
      workingDays += 1;
    }
  }

  return workingDays;
}

double calculateWorkingHours(List<String> contents) {
  var timeSum = 0.0;
  for (var line in contents) {
    timeSum += double.parse(line.split(";")[1]);
  }
  return timeSum;
}

DateTime firstDayOfMonth(String inputDate) {
  final firstReportedDay = DateTime.parse(inputDate);
  final firstDayOfMonth = DateTime(
    firstReportedDay.year,
    firstReportedDay.month,
    1,
  );

  return firstDayOfMonth;
}

DateTime lastDayOfMonth(String inputDate) {
  final lastReportedDay = DateTime.parse(inputDate);
  final lastDayOfMonth = DateTime(
    lastReportedDay.year,
    lastReportedDay.month + 1,
    0,
  );
  return lastDayOfMonth;
}

void timeOutputGeneration(
  double timeSum,
  ArgResults res,
  List<String> contents,
  DateTime firstDayOfMonth,
  DateTime lastDayOfMonth,
) {
  stdout.writeln("\tSummary");
  stdout.writeln(
    "Total:\t$timeSum ${timeSum < 2 ? 'hour' : 'hours'}",
  );
  if (res["earnings"] != null) {
    stdout
        .writeln("Earned:\t${calculateEarnings(timeSum, double.parse(res['earnings']))} PLN");
  }
  final meanTime = timeSum / contents.length;
  stdout.writeln(
    "Mean:\t${meanTime.toStringAsFixed(2)} ${meanTime < 2 ? 'hour/day' : 'hours/day'}",
  );
  stdout.writeln(
    "Days:\t${contents.length}/${countWorkingDays(firstDayOfMonth, lastDayOfMonth)}days",
  );
}

void parseTimeFlag(ArgResults res, List<String> contents) {
  var timeSum = calculateWorkingHours(contents);
  if (res["verbose"] == true) {
    timeOutputGeneration(
      timeSum,
      res,
      contents,
      firstDayOfMonth(contents[0].split(";")[0]),
      lastDayOfMonth(contents[contents.length - 1].split(";")[0]),
    );
  } else {
    stdout.writeln(timeSum);
  }
}

void parseShow(ArgResults res) async {
  var contents = await readFile(res["path"]);
  if (res["time"] == true) {
    parseTimeFlag(res, contents);
  }
  if ((res["all"] == true) | (res.arguments.isEmpty)) {
    parseAllFlag(res, contents);
  }
  if ((res["verbose"] == false) & (res["earnings"] != null)) {
    parseNonVerboseEarnings(res, contents);
  }
}

List<String>? prepareFileContents(
    ArgResults res, List<String> currentContents) {
  final newRow = [
    res["date"],
    res["time"],
    res.rest.join(" "),
  ].join(";");

  var i = 0;
  while (i < currentContents.length) {
    if (currentContents[i].split(";")[0] == res["date"]) {
      break;
    }
    i++;
  }

  // because of brake in while loop new row will be added if loop exists faster
  if (i < currentContents.length) {
    // TODO: think about changing  output depending on action
    // maybe return info about what has been changed
    if (currentContents[i] != newRow) {
      currentContents[i] = newRow;
      stdout.writeln("Row has been updated.");
    } else {
      stdout.writeln("File didn't change. You provided the same data.");
      return null;
    }
  } else {
    stdout.writeln("New row has been added.");
    currentContents.add(newRow);
  }

  currentContents.sort();

  return currentContents;
}

void parseAdd(ArgResults res) async {
  if (res.rest.isEmpty) {
    stderr.writeln("You need to pass message!");
    exit(64);
  }
  final path = res["path"];
  // blindly creating file - it will leave it untouched if file exists
  File(path).createSync();
  var contents = prepareFileContents(res, await File(path).readAsLines());
  if (contents != null) {
    await File(path).writeAsString(contents.join("\n"));
  }
}
