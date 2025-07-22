import 'package:flutter_riverpod/flutter_riverpod.dart';

final fabExpandedProvider =
    StateNotifierProvider<FabExpandedNotifier, bool>((ref) {
  return FabExpandedNotifier();
});

class FabExpandedNotifier extends StateNotifier<bool> {
  FabExpandedNotifier() : super(false);

  void toggle() {
    state = !state;
  }

  void setExpanded(bool expanded) {
    state = expanded;
  }
}

final loadingProvider = StateNotifierProvider<LoadingNotifier, bool>((ref) {
  return LoadingNotifier();
});

class LoadingNotifier extends StateNotifier<bool> {
  LoadingNotifier() : super(false);

  void setLoading(bool loading) {
    state = loading;
  }
}

final searchProvider =
    StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  return SearchNotifier();
});

class SearchNotifier extends StateNotifier<SearchState> {
  SearchNotifier() : super(const SearchState());

  void setQuery(String query) {
    state = state.copyWith(query: query);
  }

  void setResults(List<Map<String, dynamic>> results) {
    state = state.copyWith(results: results);
  }

  void setSearching(bool searching) {
    state = state.copyWith(isSearching: searching);
  }

  void clearSearch() {
    state = const SearchState();
  }
}

class SearchState {
  final String query;
  final List<Map<String, dynamic>> results;
  final bool isSearching;

  const SearchState({
    this.query = '',
    this.results = const [],
    this.isSearching = false,
  });

  SearchState copyWith({
    String? query,
    List<Map<String, dynamic>>? results,
    bool? isSearching,
  }) {
    return SearchState(
      query: query ?? this.query,
      results: results ?? this.results,
      isSearching: isSearching ?? this.isSearching,
    );
  }
}
