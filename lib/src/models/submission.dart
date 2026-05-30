enum SubmissionStatus {
  pending,
  running,
  passed,
  failed,
  error,
}

enum Verdict {
  accepted,
  rejected,
  none,
}

enum CheckerStatus {
  pending,
  running,
  passed,
  failed,
  error,
}

const _notSet = Object();

class Submission {
  const Submission({
    required this.id,
    required this.assignmentId,
    required this.assignmentTitle,
    required this.candidateId,
    required this.candidateEmail,
    required this.candidateName,
    required this.createdAt,
    required this.score,
    required this.status,
    required this.verdict,
    this.completedAt,
  });

  final String id;
  final String assignmentId;
  final String candidateId;
  final String candidateName;
  final String candidateEmail;
  final String assignmentTitle;
  final DateTime createdAt;
  final DateTime? completedAt;
  final int? score;
  final SubmissionStatus status;
  final Verdict verdict;

  Submission copyWith({
    Object? completedAt = _notSet,
    Object? score = _notSet,
    SubmissionStatus? status,
    Verdict? verdict,
  }) {
    return Submission(
      id: id,
      assignmentId: assignmentId,
      assignmentTitle: assignmentTitle,
      candidateId: candidateId,
      candidateEmail: candidateEmail,
      candidateName: candidateName,
      createdAt: createdAt,
      completedAt: identical(completedAt, _notSet) ? this.completedAt : completedAt as DateTime?,
      score: identical(score, _notSet) ? this.score : score as int?,
      status: status ?? this.status,
      verdict: verdict ?? this.verdict,
    );
  }
}

class CheckResult {
  const CheckResult({
    required this.checker,
    required this.durationMs,
    required this.log,
    required this.message,
    required this.score,
    required this.status,
  });

  final String checker;
  final CheckerStatus status;
  final int score;
  final String message;
  final String log;
  final int durationMs;
}

class TimelineEvent {
  const TimelineEvent({
    required this.label,
    required this.time,
    required this.tone,
  });

  final String label;
  final DateTime time;
  final TimelineTone tone;
}

enum TimelineTone {
  done,
  active,
  muted,
}

class AiReview {
  const AiReview({
    required this.good,
    required this.improvements,
    required this.summary,
  });

  final String summary;
  final List<String> good;
  final List<String> improvements;
}

class DashboardStats {
  const DashboardStats({
    required this.averageScore,
    required this.awaiting,
    required this.passRate,
    required this.total,
  });

  final int total;
  final int averageScore;
  final double passRate;
  final int awaiting;
}
