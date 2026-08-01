/// AUCTE — Real-Time Dashboard Statistics & Analytics Model.
library;

class DashboardStatsModel {
  const DashboardStatsModel({
    required this.searchCount,
    required this.mappingCount,
    required this.fhirCount,
    required this.bundleCount,
    required this.unreadNotificationsCount,
    required this.systemDistribution,
    required this.topDiseases,
    required this.sevenDayTrend,
  });

  final int searchCount;
  final int mappingCount;
  final int fhirCount;
  final int bundleCount;
  final int unreadNotificationsCount;

  /// Map of AYUSH system name to percentage (0.0 to 1.0)
  final Map<String, double> systemDistribution;

  /// List of top searched terms: [{'name': String, 'count': int, 'ratio': double}]
  final List<Map<String, dynamic>> topDiseases;

  /// 7-day search count trend points
  final List<double> sevenDayTrend;

  static const empty = DashboardStatsModel(
    searchCount: 0,
    mappingCount: 0,
    fhirCount: 0,
    bundleCount: 0,
    unreadNotificationsCount: 0,
    systemDistribution: {},
    topDiseases: [],
    sevenDayTrend: [0, 0, 0, 0, 0, 0, 0],
  );

  bool get isEmpty =>
      searchCount == 0 &&
      mappingCount == 0 &&
      fhirCount == 0 &&
      bundleCount == 0;
}
