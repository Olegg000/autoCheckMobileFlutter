import 'dart:async';

import '../models/api_contract.dart';
import '../models/submission.dart';
import 'app_logger.dart';

/// Локальный mock backend: имитирует задержки сети и основные API-сценарии.
class MockRepository {
  MockRepository._();

  static final instance = MockRepository._();

  final List<Submission> _submissions = List.generate(
    32,
    (index) => ApiSubmissionDto.fromJson(_submissionPayload(index)).toDomain(),
  );

  Future<void> login(String email, String password) async {
    AppLogger.info('MockRepository', 'POST /auth/login', {'email': email});
    await Future<void>.delayed(const Duration(milliseconds: 460));
    final allowedEmail = email == 'expert@autocheck.ru' || email == 'candidate@autocheck.ru';
    if (!allowedEmail || password != 'password') {
      AppLogger.error('MockRepository', 'POST /auth/login failed', {'email': email});
      throw Exception('Неверный email или пароль');
    }
    AppLogger.debug('MockRepository', 'TokenResponse mocked', {'expiresIn': 86400000});
  }

  Future<DashboardStats> stats() async {
    AppLogger.info('MockRepository', 'GET /reports/stats');
    await Future<void>.delayed(const Duration(milliseconds: 360));
    final completed = _submissions.where((item) => item.score != null).toList();
    final accepted = _submissions.where((item) => item.verdict == Verdict.accepted).length;
    final average = completed.isEmpty
        ? 0
        : (completed.fold<int>(0, (sum, item) => sum + (item.score ?? 0)) / completed.length).round();

    final apiStats = ApiStatsDto(
      averageScore: average,
      passRate: accepted / _submissions.length * 100,
      totalSubmissions: _submissions.length,
    );
    return apiStats.toDomain(_awaitingCount());
  }

  Future<List<Submission>> submissions() async {
    AppLogger.info('MockRepository', 'GET /submissions');
    await Future<void>.delayed(const Duration(milliseconds: 420));
    return List.unmodifiable(_submissions);
  }

  Future<Submission> submissionById(String id) async {
    AppLogger.info('MockRepository', 'GET /submissions/{id}', {'submissionId': id});
    await Future<void>.delayed(const Duration(milliseconds: 260));
    return _submissions.firstWhere((item) => item.id == id);
  }

  Future<List<CheckResult>> results(String submissionId) async {
    AppLogger.info('MockRepository', 'GET /submissions/{id}/results', {'submissionId': submissionId});
    await Future<void>.delayed(const Duration(milliseconds: 280));
    const checkers = [
      'STATIC_ANALYSIS',
      'ARCHITECTURE',
      'BUILD',
      'TESTS',
      'DOCUMENTATION',
      'GIT_PRACTICES',
    ];

    return List.generate(checkers.length, (index) {
      final score = (68 + index * 5).clamp(0, 96).toInt();
      final startedAt = DateTime.now().subtract(Duration(milliseconds: 1200 + index * 520));
      return ApiCheckResultDto.fromJson({
        'id': '$submissionId-${checkers[index]}',
        'checkerType': checkers[index],
        'status': score >= 60 ? 'PASSED' : 'FAILED',
        'score': score,
        'log': [
          '[${checkers[index]}]: Запуск проверки',
          'Файл: solution-$submissionId.zip',
          'Результат: $score/100',
          score >= 80 ? 'Критичных замечаний нет.' : 'Есть предупреждения по тестам и документации.',
        ].join('\n'),
        'startedAt': startedAt.toIso8601String(),
        'finishedAt': DateTime.now().toIso8601String(),
      }).toDomain();
    });
  }

  Future<AiReview> aiReview(String submissionId) async {
    AppLogger.info('MockRepository', 'GET /submissions/{id}/ai-review', {'submissionId': submissionId});
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return const ApiAiReviewDto(
      available: true,
      summary: 'Решение соответствует заданию, но требует усилить обработку ошибок и тестовые сценарии.',
      strengths: [
        'Есть разделение на слои',
        'UI-компоненты переиспользуются',
        'Сетевой слой не смешан с представлением',
      ],
      weaknesses: [
        'Добавить unit-тесты на ошибки API',
        'Расширить README по запуску',
      ],
      recommendations: [
        'Добавить контекст в логи публичных методов',
      ],
    ).toDomain();
  }

  Future<List<TimelineEvent>> timeline(Submission submission) async {
    AppLogger.info('MockRepository', 'Client timeline derived from Submission', {'submissionId': submission.id});
    await Future<void>.delayed(const Duration(milliseconds: 220));
    return [
      TimelineEvent(label: 'Решение загружено', time: submission.createdAt, tone: TimelineTone.done),
      TimelineEvent(label: 'Задача поставлена в очередь', time: submission.createdAt, tone: TimelineTone.done),
      TimelineEvent(
        label: 'Запущены чекеры',
        time: submission.createdAt.add(const Duration(minutes: 2)),
        tone: submission.status == SubmissionStatus.pending ? TimelineTone.active : TimelineTone.done,
      ),
      TimelineEvent(
        label: 'Результаты рассчитаны',
        time: submission.createdAt.add(const Duration(minutes: 7)),
        tone: submission.score == null ? TimelineTone.muted : TimelineTone.done,
      ),
    ];
  }

  Future<Submission> rerun(String id) async {
    AppLogger.info('MockRepository', 'POST /submissions/{id}/rerun', {'submissionId': id});
    await Future<void>.delayed(const Duration(milliseconds: 440));
    final index = _submissions.indexWhere((item) => item.id == id);
    final updated = _submissions[index].copyWith(
      completedAt: null,
      score: null,
      status: SubmissionStatus.running,
      verdict: Verdict.none,
    );
    _submissions[index] = updated;
    return updated;
  }

  Future<Submission> updateVerdict(String id, Verdict verdict) async {
    final payload = ApiVerdictRequest(verdict: verdict, comment: 'Вердикт выставлен экспертом').toJson();
    AppLogger.info('MockRepository', 'PUT /submissions/{id}/verdict', {'submissionId': id, 'body': payload});
    await Future<void>.delayed(const Duration(milliseconds: 380));
    final index = _submissions.indexWhere((item) => item.id == id);
    final updated = _submissions[index].copyWith(verdict: verdict);
    _submissions[index] = updated;
    return updated;
  }

  int _awaitingCount() {
    return _submissions
        .where(
          (item) => item.status == SubmissionStatus.pending || item.status == SubmissionStatus.running,
        )
        .length;
  }
}

Map<String, Object?> _submissionPayload(int index) {
  final status = switch (index % 5) {
    0 || 1 => 'DONE',
    2 => 'RUNNING',
    3 => 'PENDING',
    _ => 'ERROR',
  };
  final score = switch (status) {
    'PENDING' || 'RUNNING' => null,
    'ERROR' => 0,
    _ => index % 5 == 0 ? 72 + (index * 5) % 24 : 38 + (index * 7) % 18,
  };
  final createdAt = DateTime(2026, 5, 31, 8 + index % 9, 10 + index % 40);
  final fullName = switch (index % 4) {
    0 => 'Иван Петров',
    1 => 'Мария Соколова',
    2 => 'Артем Волков',
    _ => 'Дарья Ким',
  };
  final email = switch (index % 4) {
    0 => 'ivan.petrov@test.ru',
    1 => 'maria.sokolova@test.ru',
    2 => 'artem.volkov@test.ru',
    _ => 'daria.kim@test.ru',
  };

  return {
    'id': 's${index + 1}',
    'assignmentId': 'a${index % 3 + 1}',
    'assignmentTitle': switch (index % 3) {
      0 => 'Flutter Auth Screen',
      1 => 'Kotlin Candidate Board',
      _ => 'React Native Results',
    },
    'candidateId': 'c${index % 4 + 1}',
    'candidateFullName': fullName,
    'candidateEmail': email,
    'status': status,
    'createdAt': createdAt.toIso8601String(),
    if (score != null) 'totalScore': score,
    if (score != null && score >= 80) 'verdict': 'ACCEPTED',
    if (score != null && score < 50) 'verdict': 'REJECTED',
    if (score != null) 'completedAt': createdAt.add(const Duration(minutes: 7)).toIso8601String(),
  };
}
