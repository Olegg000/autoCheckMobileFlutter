import 'package:autocheck_flutter/src/models/submission.dart';
import 'package:autocheck_flutter/src/services/app_logger.dart';
import 'package:autocheck_flutter/src/services/backend_repository.dart'
    show BackendRepository;
import 'package:autocheck_flutter/src/theme/app_theme.dart';
import 'package:autocheck_flutter/src/widgets/app_chrome.dart';
import 'package:autocheck_flutter/src/widgets/tech_components.dart';
import 'package:autocheck_flutter/src/widgets/tech_icon.dart';
import 'package:flutter/material.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final _repository = BackendRepository.instance;

  late Future<StatisticsData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<StatisticsData> _load() async {
    AppLogger.info('StatisticsScreen', 'Statistics load started');
    final data = await _repository.statistics();
    AppLogger.debug('StatisticsScreen', 'Statistics load completed',
        {'total': data.stats.total});
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return AppChrome(
      selected: 'statistics',
      onDashboard: () =>
          Navigator.of(context).popUntil((route) => route.isFirst),
      onStatistics: () {},
      child: FutureBuilder<StatisticsData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return TechPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TechLabel('Statistics error'),
                  SizedBox(height: 12),
                  Text(
                    snapshot.error.toString().replaceFirst('Exception: ', ''),
                    style: TextStyle(color: Color(0xFFFF7A3D), height: 1.45),
                  ),
                  SizedBox(height: 20),
                  TechButton(
                    icon: TechIconType.refresh,
                    label: 'Повторить',
                    onPressed: () => setState(() => _future = _load()),
                    variant: TechButtonVariant.secondary,
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData) {
            return TechPanel(
              child: SizedBox(
                height: 220,
                child: Center(
                  child: CircularProgressIndicator(
                      color: AppColors.accent, strokeWidth: 1.5),
                ),
              ),
            );
          }

          final data = snapshot.data!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TechLabel('Sprint-4 / telemetry'),
              SizedBox(height: 18),
              Text('Статистика',
                  style: Theme.of(context).textTheme.displayLarge),
              SizedBox(height: 20),
              Text(
                'Метрики AutoCheck и рейтинг кандидатов из реального backend.',
                style: TextStyle(
                    color: AppColors.muted, fontSize: 16, height: 1.55),
              ),
              SizedBox(height: 48),
              _MetricGrid(stats: data.stats),
              SizedBox(height: 32),
              LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 980;
                  final chart = _DailyChart(items: data.dailyCounts);
                  final ranking = _TopCandidates(items: data.topCandidates);
                  if (!wide) {
                    return Column(
                      children: [
                        chart,
                        SizedBox(height: 28),
                        ranking,
                      ],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: chart),
                      SizedBox(width: 28),
                      Expanded(flex: 2, child: ranking),
                    ],
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.stats});

  final DashboardStats stats;

  @override
  Widget build(BuildContext context) {
    final cards = [
      MetricCard(
          icon: TechIconType.chart,
          label: 'Всего проверок',
          value: stats.total.toString(),
          delta: 'backend total'),
      MetricCard(
          icon: TechIconType.activity,
          label: 'Средний балл',
          value: stats.averageScore.toString(),
          delta: 'done only'),
      MetricCard(
          icon: TechIconType.shield,
          label: 'Процент прохождения',
          value: '${stats.passRate.toStringAsFixed(1)}%',
          delta: 'accepted / total'),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 920
            ? 3
            : constraints.maxWidth >= 620
                ? 2
                : 1;
        final cardWidth = (constraints.maxWidth - (columns - 1) * 20) / columns;
        return Wrap(
          spacing: 20,
          runSpacing: 20,
          children: cards
              .map((card) => SizedBox(width: cardWidth, child: card))
              .toList(),
        );
      },
    );
  }
}

class _DailyChart extends StatelessWidget {
  const _DailyChart({required this.items});

  final List<DailyCount> items;

  @override
  Widget build(BuildContext context) {
    final visible = items.take(14).toList();
    final maxCount = visible.fold<int>(
        1, (max, item) => item.count > max ? item.count : max);
    return TechPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TechLabel('Runtime chart'),
          SizedBox(height: 10),
          Text('Динамика проверок',
              style: Theme.of(context).textTheme.titleLarge),
          SizedBox(height: 28),
          SizedBox(
            height: 260,
            child: visible.isEmpty
                ? Center(
                    child: Text('Пока нет данных',
                        style: TextStyle(color: AppColors.muted)))
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: visible.map((item) {
                      final height = 28 + (item.count / maxCount) * 190;
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(item.count.toString(),
                                  style: TechText.label
                                      .copyWith(color: AppColors.text)),
                              SizedBox(height: 8),
                              Container(
                                height: height,
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.accent.withValues(alpha: 0.18),
                                  border: Border.all(
                                      color: AppColors.accent
                                          .withValues(alpha: 0.55)),
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                  item.date.length >= 5
                                      ? item.date
                                          .substring(item.date.length - 5)
                                      : item.date,
                                  style: TechText.label),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

class _TopCandidates extends StatelessWidget {
  const _TopCandidates({required this.items});

  final List<TopCandidate> items;

  @override
  Widget build(BuildContext context) {
    return TechPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TechLabel('Candidate ranking'),
          SizedBox(height: 10),
          Text('Топ кандидатов', style: Theme.of(context).textTheme.titleLarge),
          SizedBox(height: 24),
          if (items.isEmpty)
            Text('Пока нет кандидатов',
                style: TextStyle(color: AppColors.muted))
          else
            ...items.take(10).map(
              (candidate) {
                final index = items.indexOf(candidate) + 1;
                return Container(
                  margin: EdgeInsets.only(bottom: 12),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: AppColors.panelDeep,
                      border: Border.all(color: AppColors.border)),
                  child: Row(
                    children: [
                      Text(index.toString().padLeft(2, '0'),
                          style:
                              TechText.label.copyWith(color: AppColors.accent)),
                      SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          candidate.fullName,
                          style: TextStyle(
                              color: AppColors.text,
                              fontWeight: FontWeight.w800),
                        ),
                      ),
                      Text(
                        candidate.bestScore.toStringAsFixed(1),
                        style: TextStyle(
                          color: scoreColor(candidate.bestScore.round()),
                          fontFamily: 'monospace',
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
