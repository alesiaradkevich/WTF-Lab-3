import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'package:my_final_project/entities/section.dart';

class SettingState extends Equatable {
  final List<Section> listSection;
  final bool isAdd;
  final ThemeData theme;
  final TextTheme textTheme;
  final String backgroundImage;
  final String bubbleAlignment;

  SettingState({
    this.isAdd = false,
    required this.listSection,
    required this.theme,
    required this.textTheme,
    required this.backgroundImage,
    required this.bubbleAlignment,
  });

  SettingState copyWith({
    List<Section>? listSection,
    bool? isAdd,
    ThemeData? theme,
    TextTheme? textTheme,
    String? backgroundImage,
    String? bubbleAlignment,
  }) {
    return SettingState(
      isAdd: isAdd ?? this.isAdd,
      listSection: listSection ?? this.listSection,
      theme: theme ?? this.theme,
      textTheme: textTheme ?? this.textTheme,
      backgroundImage: backgroundImage ?? this.backgroundImage,
      bubbleAlignment: bubbleAlignment ?? this.bubbleAlignment,
    );
  }

  @override
  List<Object?> get props => [
        listSection,
        isAdd,
        theme,
        textTheme,
        backgroundImage,
        bubbleAlignment,
      ];
}
