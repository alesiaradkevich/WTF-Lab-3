import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';

import '../../data/models/models.dart';
import '../../data/repository/categories_repository.dart';
import '../../data/repository/events_repository.dart';
import '../../data/repository/tags_repository.dart';

part 'chat_state.dart';

typedef EventsSubscription = StreamSubscription<List<Event>>;
typedef CategoriesSubscription = StreamSubscription<List<Category>>;
typedef TagsSubscription = StreamSubscription<List<Tag>>;

class ChatCubit extends Cubit<ChatState> {
  ChatCubit() : super(const ChatState(chatId: '-'));

  void subscribeStreams() {
    final eventsSubscription =
        GetIt.I<EventsRepository>().eventsStream.listen(_setEvents);

    final categoriesSubscription =
        GetIt.I<CategoriesRepository>().categoriesStream.listen(_setCategories);

    final tagsSubscription =
        GetIt.I<TagsRepository>().tagsStream.listen(_setTags);

    emit(
      state.copyWith(
        eventsSubscription:
            _NullWrapper<EventsSubscription?>(eventsSubscription),
        categoriesSubscription:
            _NullWrapper<CategoriesSubscription?>(categoriesSubscription),
        tagsSubscription: _NullWrapper<TagsSubscription?>(tagsSubscription),
      ),
    );
  }

  void unsubscribeStreams() {
    state.eventsSubscription?.cancel();
    state.categoriesSubscription?.cancel();
    state.tagsSubscription?.cancel();

    emit(
      state.copyWith(
        eventsSubscription: const _NullWrapper<EventsSubscription?>(null),
        tagsSubscription: const _NullWrapper<TagsSubscription?>(null),
        categoriesSubscription:
            const _NullWrapper<CategoriesSubscription?>(null),
      ),
    );
  }

  Future<void> readImage(Event event) async {
    try {
      final Uint8List image;
      if (state.images?[event.id] != null) {
        image = state.images![event.id]!;
      } else {
        image = await GetIt.I<EventsRepository>().readImage(event);
      }

      final events = state.events.where((e) => e.id != event.id).toList()
        ..add(event.copyWith(image: NullWrapper<Uint8List>(image)));

      _sortEvents(events);

      emit(
        state.copyWith(
          events: events,
        ),
      );
    } catch (_) {}
  }

  void addNewEvent(Event event) async {
    final events = List<Event>.from(state.events)..add(event);
    _sortEvents(events);

    final _NullWrapper<Map<String, Uint8List>?>? imagesWrapper;
    if (event.image != null) {
      final images = Map<String, Uint8List>.from(
        state.images ?? <String, Uint8List>{},
      );
      images[event.id] = event.image!;

      imagesWrapper = _NullWrapper<Map<String, Uint8List>>(images);
    } else {
      imagesWrapper = null;
    }

    emit(state.copyWith(
      events: events,
      images: imagesWrapper,
    ));

    await GetIt.I<EventsRepository>().addEvent(event);
  }

  void deleteEvent(Event event) async {
    final events = state.events.where((e) => e.id != event.id).toList();
    _sortEvents(events);
    emit(state.copyWith(events: events));

    await GetIt.I<EventsRepository>().deleteEvent(event);
  }

  void editEvent(Event event) async {
    final events = state.events.where((e) => e.id != event.id).toList()
      ..add(event);
    _sortEvents(events);
    emit(state.copyWith(events: events));

    await GetIt.I<EventsRepository>().updateEvent(event);
  }

  void deleteSelectedEvents() {
    for (final eventId in state.selectedEventsIds) {
      deleteEvent(state.events.firstWhere((e) => e.id == eventId));
    }
  }

  void transferSelectedEvents(String destinationChat) async {
    final events = state.events
        .where((event) => state.selectedEventsIds.contains(event.id))
        .map(
          (event) => event.copyWith(
            chatId: destinationChat,
          ),
        )
        .toList();

    await GetIt.I<EventsRepository>().updateEvents(events);

    emit(state.copyWith(events: events));
  }

  void copySelectedEvents() {
    var copiedText = '';

    final selectedEvents = state.events.where(
      (event) =>
          state.selectedEventsIds.contains(event.id) && event.image == null,
    );

    for (final event in selectedEvents) {
      copiedText += '${event.content}\n';
    }

    Clipboard.setData(
      ClipboardData(
        text: copiedText,
      ),
    );
  }

  void switchEventFavorite(String eventId) {
    final event = state.events.firstWhere((event) => event.id == eventId);
    editEvent(
      event.copyWith(isFavorite: !event.isFavorite),
    );
  }

  void switchSelectedEventsFavorite() {
    final events = state.events
        .map(
          (event) => state.selectedEventsIds.contains(event.id)
              ? event.copyWith(isFavorite: !event.isFavorite)
              : event,
        )
        .toList();

    emit(state.copyWith(events: events));
  }

  void addNewTag(String tag) async {
    await GetIt.I<TagsRepository>().addTag(tag);
  }

  void deleteTag(Tag tag) async {
    await GetIt.I<TagsRepository>().deleteLink(tag.id);
  }

  void switchSelectStatus(String eventId) {
    final selectedEventsIds = List<String>.from(state.selectedEventsIds);

    if (selectedEventsIds.contains(eventId)) {
      selectedEventsIds.remove(eventId);
    } else {
      selectedEventsIds.add(eventId);
    }

    emit(state.copyWith(selectedEventsIds: selectedEventsIds));
  }

  void toggleEditMode() {
    emit(state.copyWith(isEditMode: !state.isEditMode));
  }

  void toggleFavoriteMode() {
    emit(state.copyWith(isFavoriteMode: !state.isFavoriteMode));
  }

  void changeShowCategories(bool showCategories) {
    emit(state.copyWith(showCategories: showCategories));
  }

  void changeShowTags(bool showTags) {
    emit(state.copyWith(showTags: showTags));
  }

  void changeText(String text) {
    emit(state.copyWith(text: text));
  }

  void selectCategory(String? categoryId) {
    emit(
      state.copyWith(
        selectedCategoryId: _NullWrapper<String?>(categoryId),
      ),
    );
  }

  void loadChat(String chatId) {
    emit(state.copyWith(chatId: chatId));
  }

  void resetSelection() {
    emit(state.copyWith(selectedEventsIds: const []));
  }

  void _sortEvents(List<Event> events) {
    events.sort((a, b) => a.changeTime.compareTo(b.changeTime));
  }

  bool _isUpdate(List<Event> newEvents) {
    if (state.events.isEmpty) return true;

    for (final event in state.events) {
      if (!newEvents.contains(event)) return true;
    }

    return false;
  }

  void _setEvents(List<Event> events) async {
    final chatsEvents =
        events.where((event) => event.chatId == state.chatId).toList();
    _sortEvents(chatsEvents);

    if (_isUpdate(chatsEvents)) {
      emit(state.copyWith(events: chatsEvents));
    }
  }

  void _setCategories(List<Category> categories) async {
    emit(state.copyWith(categories: categories));
  }

  void _setTags(List<Tag> tags) async {
    emit(state.copyWith(tags: tags));
  }
}
