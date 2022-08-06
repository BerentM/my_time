import 'dart:io';

import 'package:args/args.dart';

Future<List<String>> readFile(String path) async {
  final contents = await File(path).readAsLines();
  contents.sort();
  return contents;
}

void parseAllFlag(ArgResults res, List<String> contents) {
  if (res["verbose"] == true) {
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

String calculateEarnings(double hours, String hourlyWage) {
  // 0.88 because of PPE tax
  return ((hours * double.parse(hourlyWage)) * 0.88).toStringAsFixed(2);
}

void parseNonVerboseEarnings(ArgResults res, List<String> contents) {
  var timeSum = 0.0;
  for (var line in contents) {
    timeSum += double.parse(line.split(";")[1]);
  }
  stdout.writeln(calculateEarnings(timeSum, res["earnings"]));
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
        .writeln("Earned:\t${calculateEarnings(timeSum, res['earnings'])} PLN");
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
  if (res["all"] == true) {
    parseAllFlag(res, contents);
  }
  if ((res["verbose"] == false) & (res["earnings"] != null)) {
    parseNonVerboseEarnings(res, contents);
  }
}
