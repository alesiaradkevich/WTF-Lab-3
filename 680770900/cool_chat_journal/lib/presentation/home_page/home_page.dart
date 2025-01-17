import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../data/models/chat.dart';
import '../chat_editor_page/chat_editor_page.dart';
import '../chat_page/chat_page.dart';
import '../settings_page/settings_cubit.dart';
import '../settings_page/settings_page.dart';
import 'home_cubit.dart';
import 'widgets/manage_panel_dialog.dart';

class HomePage extends StatefulWidget {
  final User? user;

  const HomePage({
    required this.user,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _dateFormat = DateFormat.yMMMMd('en_US');

  void _openManagePanel(BuildContext context, Chat chat) {
    showModalBottomSheet(
      context: context,
      builder: (context) => ManagePanelDialog(
        chat: chat,
        onDeleteChat: () => GetIt.I<HomeCubit>().deleteChat(chat.id),
        onSwitchChatPinning: () => GetIt.I<HomeCubit>().switchChatPinning(chat),
        onEditChat: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatEditorPage(
              sourceChat: chat,
            ),
          ),
        ),
      ),
    );
  }

  Widget _createChatCard(BuildContext context, Chat chat) {
    return Card(
      child: InkWell(
        onLongPress: () => _openManagePanel(context, chat),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(
              chatId: chat.id,
              chatName: chat.name,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ListTile(
            leading: Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  padding: const EdgeInsets.all(10.0),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: Icon(
                    IconData(chat.iconCode, fontFamily: 'MaterialIcons'),
                    color: Colors.black,
                  ),
                ),
                if (chat.isPinned)
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.push_pin,
                      size: 20,
                    ),
                  ),
              ],
            ),
            title: Text(chat.name),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    context.read<HomeCubit>().subscribeChatsStream();
    context.read<SettingsCubit>().initSettings();
  }

  @override
  void dispose() {
    context.read<HomeCubit>().unsubscribeChatsStream();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: theme.primaryColor,
              ),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  _dateFormat.format(DateTime.now()),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 25.0,
                  ),
                ),
              ),
            ),
            InkWell(
              child: const ListTile(
                leading: Icon(Icons.redeem),
                title: Text('Help spread the world'),
              ),
              onTap: () {
                Navigator.pop(context);
                Share.share('Keep track of your life with Chat Journal,'
                    ' a simple and elegant chat-based journal/notes'
                    'application that makes journaling/note-taking fun,'
                    'easy, quick and effortless. '
                    'https://play.google.com/store/apps/details?'
                    'id=com.agiletelescope.chatjournal');
              },
            ),
            InkWell(
                child: const ListTile(
                  leading: Icon(Icons.settings_outlined),
                  title: Text('Settings'),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SettingsPage(),
                    ),
                  );
                }),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text('Cool Chat Journal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.color_lens_outlined),
            onPressed: () => context.read<SettingsCubit>().switchThemeType(),
          ),
        ],
      ),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) => ListView.builder(
          itemCount: state.chats.length,
          itemBuilder: (context, index) =>
              _createChatCard(context, state.chats[index]),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ChatEditorPage(),
          ),
        ),
      ),
    );
  }
}
