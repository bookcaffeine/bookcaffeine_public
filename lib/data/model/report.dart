// ReportItem 클래스 정의
class ReportItem {
  final String postId;
  final DateTime reportedAt;

  ReportItem({
    required this.postId,
    required this.reportedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'postId': postId,
      'reportedAt': reportedAt.toIso8601String(),
    };
  }
}

// Report 클래스 정의
class Report {
  final List<ReportItem> postId; // ReportItem을 리스트로 저장
  final String reporterId;

  Report({
    required this.postId,
    required this.reporterId,
  });

  Map<String, dynamic> toJson() {
    return {
      'postId': postId
          .map((item) => item.toJson())
          .toList(), // ReportItem을 Map으로 변환하여 리스트로 저장
    };
  }
}
