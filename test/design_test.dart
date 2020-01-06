import 'package:tuie/ui_elements/design.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Seasonal Design', () async {
    //Check that the correct design is found for each season
    int _currentYear = DateTime.now().year;
    DateTime _spring = new DateTime.utc(_currentYear, 4, 1);
    DateTime _summer = new DateTime.utc(_currentYear, 7, 1);
    DateTime _autumn = new DateTime.utc(_currentYear, 10, 1);
    DateTime _winter = new DateTime.utc(_currentYear, 12, 1);

    expect(setSeasonalTheme(fakeCurrentYear: _spring), 'spring');
    expect(setSeasonalTheme(fakeCurrentYear: _summer), 'summer');
    expect(setSeasonalTheme(fakeCurrentYear: _autumn), 'autumn');
    expect(setSeasonalTheme(fakeCurrentYear: _winter), 'winter');
  });
}
