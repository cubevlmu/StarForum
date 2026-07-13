import 'package:flutter_test/flutter_test.dart';
import 'package:star_forum/data/perf/perf_config.dart';
import 'package:star_forum/data/perf/perf_log.dart';
import 'package:star_forum/data/perf/perf_metrics.dart';
import 'package:star_forum/utils/html_utils.dart';

void main() {
  setUp(() {
    PerfConfig.enabled = true;
    PerfMetrics.reset();
  });

  tearDown(() {
    PerfMetrics.reset();
    PerfConfig.reset();
  });

  test('aggregates duration, counters and cache ratio', () {
    PerfLog.repository('feed', elapsedUs: 100, success: true);
    PerfLog.repository('feed', elapsedUs: 300, success: false);
    PerfLog.cache('feed', hit: true);
    PerfLog.cache('feed', hit: false);

    final snapshot = PerfLog.snapshot();
    final duration = snapshot.durations['repository.feed']!;
    expect(duration.count, 2);
    expect(duration.totalUs, 400);
    expect(duration.maxUs, 300);
    expect(duration.averageUs, 200);
    expect(snapshot.ratio('cache.feed.hits', 'cache.feed.requests'), 0.5);
  });

  test('normalizes request ids and records HTML cache hits', () {
    PerfLog.request('GET /api/discussions/123', requestMs: 10);
    const html = '<p>perf-metrics-cache-value</p>';
    htmlToPlainText(html);
    htmlToPlainText(html);

    final snapshot = PerfLog.snapshot();
    expect(snapshot.durations, contains('network.GET /api/discussions/:id'));
    expect(snapshot.cacheHitRate('html.plainText'), 0.5);
  });
}
