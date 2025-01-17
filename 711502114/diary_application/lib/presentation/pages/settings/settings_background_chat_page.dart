import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import 'settings_cubit.dart';
import 'settings_state.dart';

class BackgroundChatImage extends StatelessWidget {
  final SettingsState state;

  const BackgroundChatImage({required this.state, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Background Image',
        ),
      ),
      body: Center(
        child: context.watch<SettingsCubit>().state.backgroundImage == ''
            ? _noBackgroundImage(context)
            : _showBackgroundImage(context),
      ),
    );
  }

  Widget _noBackgroundImage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Click the button below to set the Background Image',
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 20,
          ),
          MaterialButton(
            child: Text(
              'Pick an Image',
            ),
            onPressed: () async => await _pickImage(context),
          ),
        ],
      ),
    );
  }

  Widget _showBackgroundImage(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 250,
          width: 250,
          child: Image.file(
            File(context.watch<SettingsCubit>().state.backgroundImage),
          ),
        ),
        ListTile(
          title: Text(
            'Unset Image',
          ),
          leading: const Icon(Icons.delete),
          onTap: () => context.read<SettingsCubit>().setBackgroundImage(''),
        ),
        ListTile(
          title: Text(
            'Pick a new Image',
          ),
          leading: const Icon(Icons.image),
          onTap: () async => await _pickImage(context),
        ),
      ],
    );
  }

  Future<void> _pickImage(BuildContext context) async {
    final media = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (media != null) {
      final imagePath = media.path;
      context.read<SettingsCubit>().setBackgroundImage(imagePath);
    }
  }
}
