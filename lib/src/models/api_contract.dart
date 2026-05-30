import 'submission.dart';

/// DTO-слой повторяет имена полей из OpenAPI и отделяет контракт backend от UI-моделей.
class ApiSubmissionDto {
  const ApiSubmissionDto({
    required this.assignmentId,
    required this.assignmentTitle,
    required this.candidateFullName,
    required this.candidateId,
    required this.createdAt,
    required this.id,
    required this.status,
    this.candidateEmail,
    this.completedAt,
    this.totalScore,
    this.verdict,
  });

  final String id;
  final String assignmentId;
  final String assignmentTitle;
  final String candidateId;
  final String candidateFullName;
  final String? candidateEmail;
  final String status;
  final int? totalScore;
  final String? verdict;
  final DateTime createdAt;
  final DateTime? completedAt;

  factory ApiSubmissionDto.fromJson(Map<String, Object?> json) {
    return ApiSubmissionDto(
      assignmentId: json['assignmentId'].toString(),
      assignmentTitle: json['assignmentTitle'].toString(),
      candidateFullName: json['candidateFullName'].toString(),
      candidateId: json['candidateId'].toString(),
      candidateEmail: json['candidateEmail'] as String?,
      completedAt: _dateOrNull(json['completedAt']),
      createdAt: DateTime.parse(json['createdAt'].toString()),
      id: json['id'].toString(),
      status: json['status'].toString(),
      totalScore: _intOrNull(json['totalScore']),
      verdict: json['verdict'] as String?,
    );
  }

  Map<String, Object?> toJson() {
    final json = <String, Object?>{
      'id': id,
      'assignmentId': assignmentId,
      'assignmentTitle': assignmentTitle,
      'candidateId': candidateId,
      'candidateFullName': candidateFullName,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
    if (candidateEmail != null) json['candidateEmail'] = candidateEmail;
    if (totalScore != null) json['totalScore'] = totalScore;
    if (verdict != null) json['verdict'] = verdict;
    if (completedAt != null) json['completedAt'] = completedAt!.toIso8601String();
    return json;
  }

  Submission toDomain() {
    return Submission(
      id: id,
      assignmentId: assignmentId,
      assignmentTitle: assignmentTitle,
      candidateId: candidateId,
      candidateEmail: candidateEmail ?? '',
      candidateName: candidateFullName,
      completedAt: completedAt,
      createdAt: createdAt,
      score: totalScore,
      status: _submissionStatus(status, totalScore),
      verdict: _verdict(verdict),
    );
  }
}

/// OpenAPI CheckResult: id, checkerType, status, score/log and timestamps.
class ApiCheckResultDto {
  const ApiCheckResultDto({
    required this.checkerType,
    required this.id,
    required this.startedAt,
    required this.status,
    this.finishedAt,
    this.log,
    this.score,
  });

  final String id;
  final String checkerType;
  final String status;
  final int? score;
  final String? log;
  final DateTime startedAt;
  final DateTime? finishedAt;

  factory ApiCheckResultDto.fromJson(Map<String, Object?> json) {
    return ApiCheckResultDto(
      checkerType: json['checkerType'].toString(),
      finishedAt: _dateOrNull(json['finishedAt']),
      id: json['id'].toString(),
      log: json['log'] as String?,
      score: _intOrNull(json['score']),
      startedAt: DateTime.parse(json['startedAt'].toString()),
      status: json['status'].toString(),
    );
  }

  CheckResult toDomain() {
    return CheckResult(
      checker: checkerType,
      durationMs: finishedAt == null ? 0 : finishedAt!.difference(startedAt).inMilliseconds,
      log: log ?? 'Лог чекера отсутствует',
      message: _checkerMessage(status),
      score: score ?? 0,
      status: _checkerStatus(status),
    );
  }
}

class ApiAiReviewDto {
  const ApiAiReviewDto({
    required this.available,
    this.recommendations,
    this.strengths,
    this.summary,
    this.weaknesses,
  });

  final bool available;
  final String? summary;
  final List<String>? strengths;
  final List<String>? weaknesses;
  final List<String>? recommendations;

  AiReview toDomain() {
    return AiReview(
      summary: summary ?? 'AI-анализ пока недоступен.',
      good: strengths ?? const [],
      improvements: [...?weaknesses, ...?recommendations],
    );
  }
}

class ApiVerdictRequest {
  const ApiVerdictRequest({required this.verdict, this.comment});

  final Verdict verdict;
  final String? comment;

  Map<String, Object?> toJson() {
    return {
      'verdict': verdict == Verdict.accepted ? 'ACCEPTED' : 'REJECTED',
      if (comment != null) 'comment': comment,
    };
  }
}

class ApiStatsDto {
  const ApiStatsDto({
    required this.averageScore,
    required this.passRate,
    required this.totalSubmissions,
  });

  final int totalSubmissions;
  final int averageScore;
  final double passRate;

  DashboardStats toDomain(int awaiting) {
    return DashboardStats(
      averageScore: averageScore,
      awaiting: awaiting,
      passRate: passRate,
      total: totalSubmissions,
    );
  }
}

int? _intOrNull(Object? value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.round();
  return int.tryParse(value.toString());
}

DateTime? _dateOrNull(Object? value) {
  if (value == null) return null;
  final text = value.toString();
  if (text.isEmpty) return null;
  return DateTime.tryParse(text);
}

SubmissionStatus _submissionStatus(String status, int? score) {
  return switch (status) {
    'PENDING' => SubmissionStatus.pending,
    'RUNNING' => SubmissionStatus.running,
    'ERROR' => SubmissionStatus.error,
    'DONE' => score != null && score >= 60 ? SubmissionStatus.passed : SubmissionStatus.failed,
    _ => SubmissionStatus.error,
  };
}

Verdict _verdict(String? verdict) {
  return switch (verdict) {
    'ACCEPTED' => Verdict.accepted,
    'REJECTED' => Verdict.rejected,
    _ => Verdict.none,
  };
}

CheckerStatus _checkerStatus(String status) {
  return switch (status) {
    'PENDING' => CheckerStatus.pending,
    'RUNNING' => CheckerStatus.running,
    'PASSED' => CheckerStatus.passed,
    'FAILED' => CheckerStatus.failed,
    _ => CheckerStatus.error,
  };
}

String _checkerMessage(String status) {
  return switch (status) {
    'PASSED' => 'Проверка успешно пройдена',
    'FAILED' => 'Есть предупреждения',
    'RUNNING' => 'Проверка выполняется',
    'PENDING' => 'Ожидает запуска',
    _ => 'Ошибка выполнения чекера',
  };
}
