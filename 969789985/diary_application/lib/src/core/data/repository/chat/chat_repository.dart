import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:rxdart/rxdart.dart';

import '../../../domain/api/chat/api_chat_provider.dart';
import '../../../domain/api/chat/api_chat_repository.dart';
import '../../../domain/models/local/chat/chat_model.dart';

class ChatRepository extends ApiChatRepository {
  ChatRepository({
    required ApiChatProvider provider,
  }) : _provider = provider;

  final ApiChatProvider _provider;

  @override
  ValueStream<IList<ChatModel>> get chats => _provider.chats
      .transform(_provider.chatsStreamTransform)
      .shareValueSeeded(
        _provider.chatsList(
          _provider.chats.value,
        ),
      );

  @override
  Future<void> add(ChatModel chat) async => await _provider.addChat(
        _provider.firebaseChat(chat),
      );

  @override
  Future<void> remove(ChatModel chat) async => await _provider.deleteChat(
        chat.id.toString(),
      );

  @override
  Future<void> update(ChatModel chat) async => await _provider.updateChat(
        _provider.firebaseChat(chat),
      );
}
