class Endpoints {
  static const String baseURL = "https://api-mys-prod.levnext.com/parents/";
  static const String login = "auth/login";
  static const String loginOtpSend = "auth/login-otp/send";
  static const String loginOtpVerify = "auth/login-otp/verify";
  static const String refreshToken = "auth/refresh-token";

  /// `POST` — `/auth/logout` (full: `{baseURL}auth/logout`). Invalidates the session server-side.
  static const String logout = "auth/logout";

  /// `POST` — sign out every session except the current one (or all others per API).
  static const String authLogoutAll = 'auth/logout-all';

  static const String forgotPassword = "auth/forgot-password";
  static const String forgetPassword = "auth/forget-password";
  static const String resetPassword = "auth/reset-password";
  static const String verifyOtp = "auth/verify-otp";
  static const String resendOtp = "auth/resend-otp";
  static const String changePassword = "auth/change-password";

  /// `GET` — list active login sessions for the authenticated parent.
  static const String authSessions = 'auth/sessions';

  // Student endpoints
  static const String getStudents = "student/get-students";
  static String selectStudent(int studentId) =>
      "student/select-student/$studentId";

  /// Academic sessions available for the parent / selected student context (`GET`).
  static const String studentAvailableSessions = 'student/available-sessions';

  /// Switch active academic session for the current student (`POST`).
  static String studentChangeSession(int classStudentId) =>
      'student/change-session/$classStudentId';
  static const String studentAttendance = "student/attendance";

  /// Full profile for the selected student (session).
  static const String studentProfile = 'student/profile';

  /// Gender, blood groups, religions, etc. for profile forms.
  static const String studentProfileMeta = 'student/profile/meta';

  static const String studentProfileBasic = 'student/profile/basic';
  static const String studentProfileAcademic = 'student/profile/academic';
  static const String studentProfileFather = 'student/profile/father';
  static const String studentProfileMother = 'student/profile/mother';
  static const String studentProfileGuardian = 'student/profile/guardian';
  static const String studentProfilePhoto = 'student/profile/photo';
  static const String studentProfileDocuments = 'student/profile/documents';

  static String studentProfileDocument(int documentId) =>
      'student/profile/documents/$documentId';

  /// Recent notifications / messages (`limit`, `offset` query params).
  static const String recentNotifications = 'student/recent-notifications';

  /// Daily homework list; date format `yyyy-MM-dd`.
  static String homework(String yyyyMmDd) => 'homework/$yyyyMmDd';

  /// Submit homework — `POST` multipart: `assignment_student_id`, `description`,
  /// optional `file_image`, `pdf_file`, `audio_file`.
  static const String assignmentSubmit = 'assignment/submit';

  /// Fee structure for the selected student (requires auth + selected student context).
  static const String feeFeeStructure = 'fee/fee-structure';

  /// Per–fee-period breakdown (payment detail).
  static String feeDetails(int feePeriodId) => 'fee/details/$feePeriodId';

  static const String feePaymentHistory = 'fee/payment-history';
  static const String feePaymentConfig = 'fee/payment-config';
  static const String feeInitiatePayment = 'fee/initiate-payment';
  static const String feeUpdatePayment = 'fee/update-payment';

  /// Pending fee breakdown for selected student; query `limit`, optional `cursor`.
  static const String studentPendingFee = 'student/pending-fee';

  /// Holiday calendar: query `month` (1–12), `year`, optional `limit`.
  static const String calenderHolidays = 'calender';

  /// Daily timetable for the selected student; `limit` is optional.
  static String timetableByDate(String yyyyMmDd) => 'timetable/$yyyyMmDd';

  /// Datesheets list; query `limit`, optional `next_cursor`.
  static const String datesheets = 'datesheets';

  /// Syllabus list; query `limit`, optional `next_cursor`.
  static const String syllabus = 'syllabus';

  /// Class test results; query `limit`, optional `next_cursor`.
  static const String classTestResults = 'results/class-test';

  /// Exam results; query `limit`, optional `next_cursor`.
  static const String examResults = 'results/exam';

  /// Parent feedback — `POST` multipart: `rating`, `feedback_type`, `subject`,
  /// `description`, optional `attachment`.
  static const String feedback = 'feedback';

  /// Notice board — `GET` query: `limit`, optional `cursor` (same pattern as syllabus/datesheets).
  static const String notice = 'notice';

  /// Event gallery — `GET` query: `limit`, optional `cursor`.
  static const String eventGallery = 'event-gallery';

  /// Live classes by date — `GET live-class/{yyyy-MM-dd}?limit=...`
  static String liveClassByDate(String yyyyMmDd) => 'live-class/$yyyyMmDd';

  /// Leave list (`GET /leave/list?limit=10`)
  static const String leaveList = 'leave/list';

  /// Leave types for selected student (`GET /leave/types`)
  static const String leaveTypes = 'leave/types';

  /// Leave detail by id (`GET /leave/{leaveId}`)
  static String leaveDetail(int leaveId) => 'leave/$leaveId';

  /// Apply leave (`POST /leave/apply`)
  static const String leaveApply = 'leave/apply';

  /// Outpass list (`GET /outpass/list?limit=10`)
  static const String outpassList = 'outpass/list';

  /// Outpass detail (`GET /outpass/{outpassId}`)
  static String outpassDetail(int outpassId) => 'outpass/$outpassId';

  /// Outpass apply (`POST /outpass/apply`)
  static const String outpassApply = 'outpass/apply';

  /// Outpass reasons (`GET /outpass/reasons`)
  static const String outpassReasons = 'outpass/reasons';
}
