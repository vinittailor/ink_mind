import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ink_mind/core/routes/app_router.dart';
import 'package:ink_mind/core/widgets/loading_indicator.dart';
import 'package:ink_mind/features/chat/presentation/cubit/chat_cubit.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onAskPressed() {
    final query = _controller.text;
    context.read<ChatCubit>().ask(query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('InkMind — RAG Chat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.photo_camera_outlined),
            tooltip: 'On-Device Classifier',
            onPressed: () => context.push(AppRoutes.classifier),
          ),
          IconButton(
            icon: const Icon(Icons.note_add_outlined),
            tooltip: 'Notes',
            onPressed: () => context.push(AppRoutes.notes),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Ask Gemini a question about your notes...',
              ),
              onSubmitted: (_) => _onAskPressed(),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _onAskPressed,
                child: const Text('Ask'),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: BlocBuilder<ChatCubit, ChatState>(
                  builder: (context, state) {
                    return switch (state) {
                      ChatInitial() => const Center(
                          child: Text(
                            'Type a question above and tap Ask.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ChatSearchingNotes() => const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            LoadingIndicator(),
                            SizedBox(height: 12),
                            Text('Searching your notes...'),
                          ],
                        ),
                      ChatLoading() => const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            LoadingIndicator(),
                            SizedBox(height: 12),
                            Text('Generating answer...'),
                          ],
                        ),
                      ChatStreaming(:final partialText, :final sources) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              partialText,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            if (sources.isNotEmpty) ...[
                              const SizedBox(height: 24),
                              const Divider(),
                              const SizedBox(height: 8),
                              Text(
                                'Sources retrieved from your notes (${sources.length}):',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.lightBlueAccent,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...sources.map(
                                (source) => Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Text(
                                      source,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ChatError(:final message) => Text(
                          message,
                          style: const TextStyle(color: Colors.red),
                        ),
                    };
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
