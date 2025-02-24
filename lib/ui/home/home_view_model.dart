import 'package:bookcaffeine/data/model/home_state.dart';
import 'package:bookcaffeine/data/repository/user_repository.dart';
import 'package:bookcaffeine/util/global_user_info.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeViewModel extends Notifier<HomeState> {
  @override
  HomeState build() {
    fetchData();
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

  // 모든 데이터 최신화
  Future<void> fetchData() async {
    GlobalUserInfo.getCurrentUserInfo();
    fetchCurrentBooks(GlobalUserInfo.uid);
    fetchUpcomingBooks(GlobalUserInfo.uid);
    fetchFinishedBooks(GlobalUserInfo.uid);
    fetchYearlyReadBooks();
    fetchMonthlyReadBooks();
    fetchTotalReadBooks();
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

  /// 연간 독서 read
  Future<void> fetchYearlyReadBooks() async {
    final getYearlyReadBooks = await userRepository.fetchYearlyReadBooks();

    state = state.copyWith(
      yearlyReadBooks: getYearlyReadBooks ?? [],
    );
  }

  /// 월간 독서 read
  Future<void> fetchMonthlyReadBooks() async {
    final getMonthlyReadBooks = await userRepository.fetchMonthlyReadBooks();

    state = state.copyWith(
      monthlyReadBooks: getMonthlyReadBooks ?? [],
    );
  }

  /// 누적 독서 read
  Future<void> fetchTotalReadBooks() async {
    final getTotalReadBooks = await userRepository.fetchTotalReadBooks();

    state = state.copyWith(
      totalReadBooks: getTotalReadBooks ?? [],
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

final homeViewModelProvider = NotifierProvider<HomeViewModel, HomeState>(
  () {
    return HomeViewModel();
  },
);
