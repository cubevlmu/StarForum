class FlarumPage<T> {
  const FlarumPage({
    required this.items,
    this.nextUrl,
    this.prevUrl,
    this.total,
  });

  final List<T> items;
  final String? nextUrl;
  final String? prevUrl;
  final int? total;

  bool get hasMore => nextUrl != null && nextUrl!.isNotEmpty;
}
