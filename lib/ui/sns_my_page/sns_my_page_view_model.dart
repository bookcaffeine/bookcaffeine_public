import 'package:bookcaffeine/data/model/home_state.dart';
import 'package:bookcaffeine/data/repository/sns_my_page_repository.dart';
import 'package:bookcaffeine/data/repository/user_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SnsMyPageViewModel extends AutoDisposeFamilyNotifier<HomeState, String> {
  @override
  HomeState build(String arg) {
    fetchData(arg);

    return HomeState(
      currentBooks: [],
      upcomingBooks: [],
      finishedBook: [],
      yearlyReadBooks: [],
      monthlyReadBooks: [],
      totalReadBooks: [],
    );
  }

  final userRepository = UserRepository();
  final snsMyPageRepository = SnsMyPageRepository();

  // 모든 데이터 최신화
  Future<void> fetchData(userId) async {
    // 통계(count) - snsMyPageRepository
    fetchMonthlyReadBooks(userId);
    fetchYearlyReadBooks(userId);
    fetchTotalReadBooks(userId);

    // 상태 별 책 정보 - userRepository
    fetchCurrentBooks(userId);
    fetchUpcomingBooks(userId);
    fetchFinishedBooks(userId);
  }

  /// 월간 독서 read
  Future<void> fetchMonthlyReadBooks(String userId) async {
    final getMonthlyReadBooks =
        await snsMyPageRepository.fetchMonthlyReadBooks(userId);

    state = state.copyWith(
      monthlyReadBooks: getMonthlyReadBooks ?? [],
    );
  }

  /// 연간 독서 read
  Future<void> fetchYearlyReadBooks(String userId) async {
    final getYearlyReadBooks =
        await snsMyPageRepository.fetchYearlyReadBooks(userId);

    state = state.copyWith(
      yearlyReadBooks: getYearlyReadBooks ?? [],
    );
  }

  /// 누적 독서 read
  Future<void> fetchTotalReadBooks(String userId) async {
    final getTotalReadBooks =
        await snsMyPageRepository.fetchTotalReadBooks(userId);

    state = state.copyWith(
      totalReadBooks: getTotalReadBooks ?? [],
    );
  }

  /// 읽고 있는 책 read
  Future<void> fetchCurrentBooks(String? userId) async {
    final getCurrentBooks =
        await userRepository.fetchCurrentBooks(userId ?? '');

    state = state.copyWith(
      currentBooks: getCurrentBooks ?? [],
    );
  }

  /// 읽고 싶은 책 read
  Future<void> fetchUpcomingBooks(String? userId) async {
    final getUpcomingBooks =
        await userRepository.fetchUpcomingBooks(userId ?? '');

    state = state.copyWith(
      upcomingBooks: getUpcomingBooks ?? [],
    );
  }

  /// 다 읽은 책 read
  Future<void> fetchFinishedBooks(String? userId) async {
    final getFinishedBooks =
        await userRepository.fetchFinishedBooks(userId ?? '');

    state = state.copyWith(
      finishedBook: getFinishedBooks ?? [],
    );
  }

  Future<void> clearState() async {
    state = HomeState(
      currentBooks: [],
      upcomingBooks: [],
      finishedBook: [],
      yearlyReadBooks: [],
      monthlyReadBooks: [],
      totalReadBooks: [],
    );
  }
}

final snsMyPageViewModelProvider =
    NotifierProvider.autoDispose.family<SnsMyPageViewModel, HomeState, String>(
  () => SnsMyPageViewModel(),
);
