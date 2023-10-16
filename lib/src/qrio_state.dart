import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class QrioState {
  const QrioState({
    required this.tabOffset,
    required this.isHistoryExpanded,
  });

  final double tabOffset;
  final bool isHistoryExpanded;

  QrioState copyWith({
    double? tabOffset,
    bool? isHistoryExpanded,
  }) {
    return QrioState(
      tabOffset: tabOffset ?? this.tabOffset,
      isHistoryExpanded: isHistoryExpanded ?? this.isHistoryExpanded,
    );
  }
}

class QrioStateNotifier extends StateNotifier<QrioState> {
  QrioStateNotifier()
      : super(const QrioState(
          tabOffset: 0,
          isHistoryExpanded: false,
        ));

  void setTabOffset(double value) {
    state = state.copyWith(tabOffset: value);
  }

  void setIsHistoryExpanded(bool value) {
    state = state.copyWith(isHistoryExpanded: value);
  }
}
