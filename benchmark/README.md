# Data layer benchmark

This benchmark does not start the app, connect to a forum, or modify the normal
`forum.db` file.

Run the default workload:

```powershell
flutter test benchmark/data_layer_benchmark_test.dart --reporter expanded
```

Run a larger workload:

```powershell
flutter test benchmark/data_layer_benchmark_test.dart --reporter expanded `
  --dart-define=BENCH_ROWS=20000 `
  --dart-define=BENCH_ITERATIONS=500
```

Measure production-like file I/O through Drift's background SQLite isolate:

```powershell
flutter test benchmark/data_layer_benchmark_test.dart --reporter expanded `
  --dart-define=BENCH_STORAGE=file `
  --dart-define=BENCH_ROWS=20000 `
  --dart-define=BENCH_ITERATIONS=500
```

`BENCH_STORAGE=memory` is best for finding query, mapping, and allocation
costs. `BENCH_STORAGE=file` is best for measuring write latency on the target
machine. File mode creates and removes a temporary database automatically.

Send back all output lines containing:

- `BENCH_CONFIG`
- `BENCH_SEED`
- `BENCH_EXPLAIN`
- `BENCH_RESULT`
- `BENCH_CHECK`

Compare `p50Us` for typical latency and `p95Us` for tail latency. A growing
`rssDeltaKb` across repeated runs can indicate retained allocations, but a
single RSS delta is only a diagnostic signal because Dart garbage collection is
not deterministic.

## Runtime metrics

Debug builds aggregate repository, network, JSON parsing, Drift, cache,
coalescing, hydration, HTML, frame, image-cache, and SQLite-size metrics through
`PerfLog`. Use `PerfLog.snapshot()` for assertions or debugger inspection and
`PerfLog.printSnapshot()` to emit count, average, maximum, and total timings.

Cache and request-coalescing ratios are available from
`snapshot.cacheHitRate(name)` and `snapshot.coalescingHitRate(name)`.

## Network layer benchmark

The network benchmark starts a loopback HTTP server. It does not connect to a
real forum. It compares JSON transformers, verifies connection reuse after an
idle period, and checks concurrent GET coalescing.

```powershell
flutter test benchmark/network_layer_benchmark_test.dart --reporter expanded `
  --dart-define=BENCH_ITERATIONS=200 `
  --dart-define=BENCH_IDLE_SECONDS=4
```
