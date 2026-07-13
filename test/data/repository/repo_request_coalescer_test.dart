import 'package:flutter_test/flutter_test.dart';
import 'package:star_forum/data/repository/repo_result.dart';

void main() {
  test('coalesces matching requests by default', () async {
    final coalescer = RepoRequestCoalescer();
    var calls = 0;
    Future<int> request() async {
      calls += 1;
      await Future<void>.delayed(const Duration(milliseconds: 1));
      return calls;
    }

    final values = await Future.wait([
      coalescer.run('same', request),
      coalescer.run('same', request),
    ]);

    expect(values, [1, 1]);
    expect(calls, 1);
  });

  test('runs requests independently when coalescing is disabled', () async {
    final coalescer = RepoRequestCoalescer();
    var calls = 0;
    Future<int> request() async {
      calls += 1;
      return calls;
    }

    final values = await Future.wait([
      coalescer.run('same', request, coalesce: false),
      coalescer.run('same', request, coalesce: false),
    ]);

    expect(values, [1, 2]);
    expect(calls, 2);
  });
}
