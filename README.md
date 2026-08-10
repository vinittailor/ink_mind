# InkMind — On-Device Hybrid RAG & Image Classification in Flutter

InkMind is an advanced Flutter application that brings three modern mobile engineering techniques together into a single, cohesive product: **Retrieval-Augmented Generation (RAG)** over personal notes, **on-device image classification** via TensorFlow Lite, and **background Isolate processing** to keep the main UI thread at 60 FPS.

---

## Key Features

- 🤖 **Streaming AI Chat (RAG)** — Interactive RAG chat powered by Google's Gemini REST API with real-time response streaming over HTTP SSE.
- 📝 **Smart Notes & Text Chunking** — Automatic paragraph chunking, concurrent embedding generation, and local persistent storage.
- 💾 **Dual Selectable Storage Backends** — Toggle at startup between **SQLite** (`sqflite`) and **ObjectBox** (a native vector database using HNSW indexing) to benchmark vector retrieval performance directly.
- 🔍 **Hybrid Search (Semantic + Keyword via RRF)** — Parallelized semantic vector search and exact keyword matching merged using **Reciprocal Rank Fusion (RRF)** for high-precision retrieval.
- 🖼️ **On-Device Image Classification** — Offline MobileNet image classification using `tflite_flutter` with zero cloud network calls for inference.
- ⚡ **Background Dart Isolates** — Heavy operations (TFLite inference, cosine similarity vector scoring) are offloaded to background Dart isolates via `compute()` and `IsolateInterpreter` to prevent frame drops.

---

## Architecture & Design Patterns

InkMind follows strict **Clean Architecture** principles structured by feature (`chat`, `notes`, `classifier`), enforcing unidirectional data flow and clear separation of concerns:

- **State Management**: `flutter_bloc` (Cubit) for predictable, reactive UI state transitions.
- **Dependency Injection**: `get_it` service locator (`sl`) for interface-based dependency injection.
- **Networking**: Configured `dio` HTTP client with interceptors for API key injection and SSE byte streaming.
- **Functional Error Handling**: `fpdart`'s `Either<Failure, T>` return type on all domain use cases to eliminate raw unhandled exceptions in the presentation layer.

---

## Requirements

- **Flutter SDK**: `3.41.1` (stable channel)
- **Dart SDK**: `3.11.0` (stable)

---

## Getting Started

### 1. Prerequisites
Obtain a free Gemini API Key from [Google AI Studio](https://aistudio.google.com/).

### 2. Setup & Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/ink_mind.git
   cd ink_mind
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure Environment Variables:**
   Copy the `.env.example` template to `.env` in the project root:
   ```bash
   cp .env.example .env
   ```
   Open `.env` and set your Gemini API key:
   ```env
   GEMINI_API_KEY=your_actual_gemini_api_key_here
   ```
   *(Note: `.env` is git-ignored in `.gitignore` so your API key remains safe and never pushed to version control).*

4. **Run the App:**
   ```bash
   flutter run
   ```

---

## Project Structure Overview

```
lib/
├── core/
│   ├── constants/          # App constants & API endpoints
│   ├── database/           # SQLite & ObjectBox database initialization
│   ├── di/                 # injection_container.dart (GetIt service locator setup)
│   ├── errors/             # Sealed Failure hierarchy & data layer Exceptions
│   ├── network/            # Dio client factory & ApiKeyInterceptor
│   ├── routes/             # GoRouter navigation configuration
│   ├── theme/              # Dark mode theme tokens (AppColors, AppTextStyles)
│   └── utils/              # RRF utility, keyword search, text chunker, vector math
│
├── features/
│   ├── chat/               # Streaming Gemini RAG feature
│   │   ├── data/           # ChatRemoteDataSourceImpl (Dio SSE stream), ChatRepositoryImpl
│   │   ├── domain/         # AskQuestion use case, ChatRepository interface
│   │   └── presentation/   # ChatCubit, ChatPage UI
│   ├── notes/              # Notes CRUD & Hybrid Search feature
│   │   ├── data/           # SQLite & ObjectBox implementations, NotesLocalDataSource
│   │   ├── domain/         # NoteChunk entity, SaveNote & GetRelevantChunks use cases
│   │   └── presentation/   # NotesCubit, BackendSelectorPage, NotesPage
│   └── classifier/         # On-device TFLite Classification feature
│       ├── data/           # ClassifierLocalDataSourceImpl (TFLite IsolateInterpreter)
│       ├── domain/         # ClassifyImage use case, ClassifierRepository
│       └── presentation/   # ClassifierCubit, ClassifierPage UI
│
└── main.dart               # App entry point & dependency locator bootstrap
```
