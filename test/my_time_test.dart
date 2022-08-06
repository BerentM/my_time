import 'package:my_time/my_time.dart';
import 'package:test/test.dart';

void main() {
  test('firstDayOfMonth', () {
    expect(firstDayOfMonth("2022-08-01"), DateTime(2022, 8, 1));
    expect(firstDayOfMonth("2022-08-06"), DateTime(2022, 8, 1));
    expect(firstDayOfMonth("2022-08-32"), DateTime(2022, 9, 1));
  });
  test('lastDayOfMonth', () {
    expect(lastDayOfMonth("2022-08-01"), DateTime(2022, 8, 31));
    expect(lastDayOfMonth("2022-08-06"), DateTime(2022, 8, 31));
    expect(lastDayOfMonth("2022-08-32"), DateTime(2022, 9, 30));
  });
  test('countWorkingDays', () {
    expect(
      countWorkingDays(DateTime(2022, 08, 01), DateTime(2022, 08, 31)),
      23,
    );
    expect(
      countWorkingDays(DateTime(2022, 07, 01), DateTime(2022, 07, 31)),
      21,
    );
    expect(
      countWorkingDays(DateTime(2022, 07, 01), DateTime(2022, 08, 31)),
      44,
    );
  });
}
