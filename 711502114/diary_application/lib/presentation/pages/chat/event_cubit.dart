// ignore_for_file: omit_local_variable_types

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../domain/models/category.dart';
import '../../../domain/models/chat.dart';
import '../../../domain/models/event.dart';
import '../../../domain/repository/chat_repository_api.dart';
import '../../../domain/repository/event_repository_api.dart';
import 'event_state.dart';

class EventCubit extends Cubit<EventState> {
  final ChatRepositoryApi chatRepository;
  final EventRepositoryApi eventRepository;
  late final StreamSubscription<List<Event>> eventStream;

  EventCubit({
    required this.chatRepository,
    required this.eventRepository,
    String id = '0',
  }) : super(EventState(chatId: '0', events: [], selectedIndexes: [])) {
    _initStream();
  }

  void _initStream() {
    eventStream = eventRepository.eventStream.listen((event) {
      final events = event.where((e) => e.chatId == state.chatId).toList();
      events.sort((a, b) => a.creationTime.compareTo(b.creationTime));
      emit(state.copyWith(events: events));
    });
  }

  bool get favoriteMode => state.isFavoriteMode;

  bool get selectedMode => state.isSelectedMode;

  bool get editMode => state.isEditMode;

  bool get categoryMode => state.isCategoryMode;

  Category? get category => state.category;

  List<Event> get events => state.events;

  List<Event> get filterEvents => state.isFavoriteMode
      ? events.where((e) => e.isFavorite).toList()
      : events;

  void init(String chatId) async {
    final allEvents = await eventRepository.getEvents(chatId);
    final events = allEvents.where((e) => e.chatId == chatId).toList();
    emit(state.copyWith(chatId: chatId, events: events));
  }

  void changeFavorite() {
    state.isFavoriteMode = !state.isFavoriteMode;

    emit(state.copyWith(events: state.events));
  }

  void migrateEvents(Chat chat) {
    state.selectedIndexes.sort();

    final migrationEvents = <Event>[];
    for (int i in state.selectedIndexes) {
      migrationEvents.add(state.events[i]);
    }

    deleteMessage();

    for (Event event in migrationEvents) {
      final unselectedEvent = event.copyWith(isSelected: false);
      eventRepository.addEvent(event.copyWith(chatId: chat.id));
      chat.events.add(unselectedEvent);
    }

    emit(state.copyWith(events: state.events));
  }

  void startEditMode(TextEditingController fieldText) {
    state.isEditMode = true;
    fieldText.text = state.events[state.selectedIndexes.last].message;

    emit(state.copyWith(events: state.events));
  }

  void copyText() {
    state.selectedIndexes.sort();
    String? text;

    for (int i in state.selectedIndexes) {
      final message = state.events[i].message;
      if (text == null) {
        text = '$message\n';
      } else {
        text += '\n$message\n';
      }
    }

    Clipboard.setData(ClipboardData(text: text));

    finishEditMode();
  }

  void changeFavoriteStatus() {
    for (int i in state.selectedIndexes) {
      state.events[i] = state.events[i].copyWith(
        isFavorite: !state.events[i].isFavorite,
      );
      eventRepository.changeEvent(state.events[i]);
    }

    finishEditMode();
  }

  void deleteMessage() {
    state.selectedIndexes.sort();

    int shift = 0;
    for (int i in state.selectedIndexes) {
      final trashEvent = state.events[i + shift--];
      eventRepository.deleteEvent(trashEvent);
      state.events.remove(trashEvent);
    }

    finishEditMode(deleteMode: true);
  }

  void addEvent(String message, [String? path]) {
    final event = Event(
      id: '',
      chatId: state.chatId,
      message: message,
      creationTime: DateTime.now().toString(),
      photoPath: path,
      category: state.category,
    );
    state.events.add(event);
    eventRepository.addEvent(event);

    state.category = null;

    emit(state.copyWith(events: state.events));
  }

  void handleSelecting(int index) {
    if (state.selectedIndexes.isEmpty) {
      state.isSelectedMode = true;
      state.events[index] = state.events[index].copyWith(isSelected: true);

      state.selectedIndexes.add(index);
    } else if (!state.selectedIndexes.contains(index)) {
      state.events[index] = state.events[index].copyWith(isSelected: true);

      state.selectedIndexes.add(index);
    } else if (state.selectedIndexes.length == 1) {
      state.isSelectedMode = false;
      state.events[index] = state.events[index].copyWith(isSelected: false);

      state.selectedIndexes.remove(index);
    } else {
      state.events[index] = state.events[index].copyWith(isSelected: false);

      state.selectedIndexes.remove(index);
    }

    emit(state.copyWith(events: state.events));
  }

  void finishEditMode({
    TextEditingController? fieldText,
    bool deleteMode = false,
    bool editSuccess = false,
  }) {
    if (!deleteMode) {
      for (int i in state.selectedIndexes) {
        state.events[i] = state.events[i].copyWith(
          isSelected: false,
          category: state.category,
        );
      }
    }

    if (fieldText != null && editSuccess) {
      final index = state.selectedIndexes.last;
      state.events[index] = state.events[index].copyWith(
        message: fieldText.text,
      );
      eventRepository.changeEvent(state.events[index]);
    }

    state.isEditMode = false;
    state.isSelectedMode = false;

    state.category = null;

    state.selectedIndexes.clear();
    fieldText?.clear();

    emit(state.copyWith(events: state.events));
  }

  void openCategory() {
    state.isCategoryMode = true;

    emit(state.copyWith(events: state.events));
  }

  void closeCategory() {
    state.isCategoryMode = false;

    emit(state.copyWith(events: state.events));
  }

  void setCategory(Category? category) {
    state.category = category;

    closeCategory();
  }

  @override
  Future<void> close() {
    eventStream.cancel();
    return super.close();
  }
}
