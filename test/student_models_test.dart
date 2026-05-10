import 'package:flutter_test/flutter_test.dart';
import 'package:studentapp/models/student_models.dart';

void main() {
  group('SelectStudentResponse', () {
    test('accepts top-level success with non-map data payload', () {
      final response = SelectStudentResponse.fromJson({
        'success': true,
        'message': 'Student selected successfully',
        'data': <dynamic>[],
      });

      expect(response.success, isTrue);
      expect(response.data.success, isTrue);
      expect(response.message, 'Student selected successfully');
    });
  });
}
