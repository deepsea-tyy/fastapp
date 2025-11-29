class TraderCard {
  final String username;
  final String avatarUrl;
  final int copyCount;
  final int maxCopyCount;
  final double profit30Days;
  final double roi30Days;
  final String chartImageUrl;

  TraderCard({
    required this.username,
    required this.avatarUrl,
    required this.copyCount,
    required this.maxCopyCount,
    required this.profit30Days,
    required this.roi30Days,
    required this.chartImageUrl,
  });
}

