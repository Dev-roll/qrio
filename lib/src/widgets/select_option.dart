import 'package:flutter/material.dart';

class SelectOption<T> {
  final String label;
  final T value;
  final String? description;

  SelectOption({required this.label, required this.value, this.description});
}

class SelectOptionGroup<T> {
  final String title;
  final List<SelectOption<T>> options;
  final String? description;
  final IconData? icon;

  SelectOptionGroup({
    required this.title,
    required this.options,
    this.description,
    this.icon,
  });

  SelectOption<T> getOptionFromValue(T value) {
    for (var e in options) {
      if (e.value == value) return e;
    }
    throw Error();
  }

  T getValueFromLabel(String label) {
    for (var e in options) {
      if (e.label == label) return e.value;
    }
    throw Error();
  }

  String getLabelFromValue(T value) {
    for (var e in options) {
      if (e.value == value) return e.label;
    }
    throw Error();
  }
}
