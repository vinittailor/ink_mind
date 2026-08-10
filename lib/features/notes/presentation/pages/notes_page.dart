import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ink_mind/core/widgets/loading_indicator.dart';
import 'package:ink_mind/features/notes/presentation/cubit/notes_cubit.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final _noteController = TextEditingController();
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSavePressed() {
    final text = _noteController.text;
    context.read<NotesCubit>().save(text);
  }

  void _onTestRetrievalPressed() {
    final query = _searchController.text;
    context.read<NotesCubit>().testRetrieval(query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Notes & Test Retrieval'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _noteController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Paste or write your notes here...\nText will be split into chunks and embedded.',
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _onSavePressed,
                child: const Text('Save & Process Chunks'),
              ),
            ),
            const Divider(height: 32),
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Enter test retrieval query...',
              ),
              onSubmitted: (_) => _onTestRetrievalPressed(),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.search),
                onPressed: _onTestRetrievalPressed,
                label: const Text('Test Retrieval'),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: BlocBuilder<NotesCubit, NotesState>(
                builder: (context, state) {
                  return switch (state) {
                    NotesIdle() => const Center(
                        child: Text(
                          'Write notes above or test retrieval.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    NotesSaving() => const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          LoadingIndicator(),
                          SizedBox(height: 12),
                          Text('Chunking text & generating embeddings...'),
                        ],
                      ),
                    NotesSaved(:final chunkCount) => Center(
                        child: Text(
                          'Saved $chunkCount chunks to local database!',
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    NotesRetrieving() => const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          LoadingIndicator(),
                          SizedBox(height: 12),
                          Text('Fetching query embedding & ranking chunks...'),
                        ],
                      ),
                    NotesRetrieved(:final chunks) => chunks.isEmpty
                        ? const Center(child: Text('No relevant chunks found.'))
                        : ListView.separated(
                            itemCount: chunks.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final chunk = chunks[index];
                              final scorePct = ((chunk.score ?? 0.0) * 100).toStringAsFixed(1);
                              return Card(
                                child: ListTile(
                                  title: Text(chunk.text),
                                  subtitle: Text(
                                    'Similarity Score: $scorePct%',
                                    style: const TextStyle(
                                      color: Colors.lightBlueAccent,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                    NotesError(:final message) => Text(
                        message,
                        style: const TextStyle(color: Colors.red),
                      ),
                  };
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
