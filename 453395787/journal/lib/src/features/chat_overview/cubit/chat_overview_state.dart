part of 'chat_overview_cubit.dart';

@freezed
class ChatOverviewState with _$ChatOverviewState {
  const factory ChatOverviewState({
    required ChatViewList chats,
  }) = _ChatOverviewState;
}