class SelectStudentTourHelper {
  const SelectStudentTourHelper._();

  static bool shouldScheduleTour({
    required bool isLoading,
    required bool hasStudents,
    required bool isTourScheduled,
    bool tourAlreadySeen = false,
    bool tourStarted = false,
  }) {
    return !isLoading &&
        hasStudents &&
        !isTourScheduled &&
        !tourAlreadySeen &&
        !tourStarted;
  }
}
