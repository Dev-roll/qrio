import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class QrioState {
  const QrioState({
    required this.selectedTabIndex,
    required this.isHistoryExpanded,
  });

  final int selectedTabIndex;
  final bool isHistoryExpanded;

  QrioState copyWith({
    int? selectedTabIndex,
    bool? isHistoryExpanded,
  }) {
    return QrioState(
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      isHistoryExpanded: isHistoryExpanded ?? this.isHistoryExpanded,
    );
  }
}

class QrioStateNotifier extends StateNotifier<QrioState> {
  QrioStateNotifier()
      : super(const QrioState(
          selectedTabIndex: 0,
          isHistoryExpanded: false,
        ));

  void setSelectedTabIndex(int value) {
    state = state.copyWith(selectedTabIndex: value);
  }

  void setIsHistoryExpanded(bool value) {
    state = state.copyWith(isHistoryExpanded: value);
  }
}
