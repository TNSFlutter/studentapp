import 'package:flutter_test/flutter_test.dart';
import 'package:studentapp/helpers/select_student_tour_helper.dart';

void main() {
  group('SelectStudentTourHelper.shouldScheduleTour', () {
    test(
      'starts only after the student list is ready and not already scheduled',
      () {
        expect(
          SelectStudentTourHelper.shouldScheduleTour(
            isLoading: false,
            hasStudents: true,
            isTourScheduled: false,
          ),
          isTrue,
        );

        expect(
          SelectStudentTourHelper.shouldScheduleTour(
            isLoading: true,
            hasStudents: true,
            isTourScheduled: false,
          ),
          isFalse,
        );

        expect(
          SelectStudentTourHelper.shouldScheduleTour(
            isLoading: false,
            hasStudents: false,
            isTourScheduled: false,
          ),
          isFalse,
        );

        expect(
          SelectStudentTourHelper.shouldScheduleTour(
            isLoading: false,
            hasStudents: true,
            isTourScheduled: true,
          ),
          isFalse,
        );

        expect(
          SelectStudentTourHelper.shouldScheduleTour(
            isLoading: false,
            hasStudents: true,
            isTourScheduled: false,
            tourAlreadySeen: true,
          ),
          isFalse,
        );

        expect(
          SelectStudentTourHelper.shouldScheduleTour(
            isLoading: false,
            hasStudents: true,
            isTourScheduled: false,
            tourStarted: true,
          ),
          isFalse,
        );
      },
    );
  });
}
