import '../../data/entities/event_db.dart';
import '../../domain/models/category.dart';
import '../../domain/models/chat.dart';
import '../../domain/models/event.dart';
import '../entities/chat_db.dart';

class ConverterDB {
  static Chat entity2Chat(ChatDB chatDB) {
    return Chat(
      id: chatDB.id,
      title: chatDB.title,
      iconNumber: chatDB.iconNumber,
      events: [],
      creationTime: chatDB.creationTime,
      isPin: chatDB.isPin == 1,
      isArchive: chatDB.isArchive == 1,
      lastEvent: chatDB.lastEvent,
      lastUpdate: chatDB.lastUpdate,
    );
  }

  static ChatDB chat2Entity(Chat chat) {
    return ChatDB(
      id: chat.id,
      title: chat.title,
      iconNumber: chat.iconNumber,
      creationTime: chat.creationTime,
      isPin: chat.isPin ? 1 : 0,
      isArchive: chat.isArchive ? 1 : 0,
      lastEvent: chat.lastEvent,
      lastUpdate: chat.lastUpdate,
    );
  }

  static Event entity2Event(EventDB eventDB) {
    return Event(
      id: eventDB.id,
      chatId: eventDB.chatId,
      message: eventDB.message,
      creationTime: eventDB.creationTime,
      isFavorite: eventDB.isFavorite == 1,
      photoPath: eventDB.photoPath,
      category: Category.model(eventDB.categoryName),
    );
  }

  static EventDB event2Entity(Event event) {
    return EventDB(
      id: event.id,
      chatId: event.chatId,
      message: event.message,
      creationTime: event.creationTime,
      isFavorite: event.isFavorite ? 1 : 0,
      photoPath: event.photoPath ?? '',
      categoryName: event.category?.title ?? '',
    );
  }
}
