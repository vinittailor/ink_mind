// get_it service locator — the single DI container for InkMind.
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:ink_mind/core/database/app_database.dart';
import 'package:ink_mind/core/network/dio_client.dart';
import 'package:ink_mind/core/network/network_info.dart';
import 'package:ink_mind/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:ink_mind/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:ink_mind/features/chat/domain/repositories/chat_repository.dart';
import 'package:ink_mind/features/chat/domain/usecases/ask_question.dart';
import 'package:ink_mind/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:ink_mind/features/classifier/data/datasources/classifier_local_data_source.dart';
import 'package:ink_mind/features/classifier/data/repositories/classifier_repository_impl.dart';
import 'package:ink_mind/features/classifier/domain/repositories/classifier_repository.dart';
import 'package:ink_mind/features/classifier/domain/usecases/classify_image.dart';
import 'package:ink_mind/features/classifier/presentation/cubit/classifier_cubit.dart';
import 'package:ink_mind/features/notes/data/datasources/notes_local_data_source.dart';
import 'package:ink_mind/features/notes/data/datasources/notes_remote_data_source.dart';
import 'package:ink_mind/features/notes/data/repositories/notes_repository_impl.dart';
import 'package:ink_mind/features/notes/domain/repositories/notes_repository.dart';
import 'package:ink_mind/features/notes/domain/usecases/get_relevant_chunks.dart';
import 'package:ink_mind/features/notes/domain/usecases/save_note.dart';
import 'package:ink_mind/features/notes/presentation/cubit/notes_cubit.dart';

import 'package:ink_mind/core/database/objectbox_database.dart';
import 'package:ink_mind/features/notes/data/repositories/notes_repository_objectbox_impl.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

enum StorageBackend {
  sqlite,
  objectbox,
}

/// The global service locator instance. Import this wherever you need DI.
final sl = GetIt.instance;

/// Registers all core and feature dependencies.
Future<void> initDependencies() async {
  // ── Environment Variables ───────────────────────────────────────────────────
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('[initDependencies] Notice: .env file not loaded ($e). Falling back to environment variables.');
  }

  // ── Core Infrastructure ──────────────────────────────────────────────────────
  sl.registerLazySingleton<Dio>(() => createDioClient());
  sl.registerLazySingleton<NetworkInfo>(() => const NetworkInfoImpl());
  sl.registerLazySingleton(() => AppDatabase());

  final objectBoxDb = await ObjectBoxDatabase.create();
  sl.registerSingleton<ObjectBoxDatabase>(objectBoxDb);

  // ── Features: Notes ─────────────────────────────────────────────────────────
  sl.registerFactory(
    () => NotesCubit(
      saveNote: sl(),
      getRelevantChunks: sl(),
    ),
  );
  sl.registerLazySingleton<NotesRemoteDataSource>(
    () => NotesRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<NotesLocalDataSource>(
    () => NotesLocalDataSourceImpl(sl()),
  );

  // Default to SQLite backend initially
  selectNotesBackend(StorageBackend.sqlite);

  // ── Features: Chat ──────────────────────────────────────────────────────────
  sl.registerFactory(
    () => ChatCubit(
      askQuestion: sl(),
      getRelevantChunks: sl(),
    ),
  );
  sl.registerLazySingleton(() => AskQuestion(sl()));
  sl.registerLazySingleton<ChatRepository>(() => ChatRepositoryImpl(sl()));
  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(sl()),
  );

  // ── Features: Classifier ────────────────────────────────────────────────────
  sl.registerFactory(() => ClassifierCubit(sl()));
  sl.registerLazySingleton(() => ClassifyImage(sl()));
  sl.registerLazySingleton<ClassifierRepository>(
    () => ClassifierRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<ClassifierLocalDataSource>(
    () => ClassifierLocalDataSourceImpl(),
  );
}

/// Dynamically registers the chosen [NotesRepository] implementation in GetIt.
void selectNotesBackend(StorageBackend backend) {
  if (sl.isRegistered<NotesRepository>()) {
    sl.unregister<NotesRepository>();
  }
  if (sl.isRegistered<SaveNote>()) {
    sl.unregister<SaveNote>();
  }
  if (sl.isRegistered<GetRelevantChunks>()) {
    sl.unregister<GetRelevantChunks>();
  }

  switch (backend) {
    case StorageBackend.sqlite:
      sl.registerLazySingleton<NotesRepository>(
        () => NotesRepositoryImpl(
          remoteDataSource: sl(),
          localDataSource: sl(),
        ),
      );
      break;
    case StorageBackend.objectbox:
      sl.registerLazySingleton<NotesRepository>(
        () => NotesRepositoryObjectBoxImpl(
          remoteDataSource: sl(),
          objectBoxDatabase: sl(),
        ),
      );
      break;
  }

  sl.registerLazySingleton(() => SaveNote(sl()));
  sl.registerLazySingleton(() => GetRelevantChunks(sl()));
}
