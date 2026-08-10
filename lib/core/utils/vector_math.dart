import 'dart:math';

/// Calculates the cosine similarity between two vector embeddings [a] and [b].
///
/// Returns a value between -1.0 and 1.0 (where 1.0 means identical orientation).
/// Returns 0.0 if vectors are empty, mismatched in length, or have zero magnitude.
double cosineSimilarity(List<double> a, List<double> b) {
  if (a.isEmpty || b.isEmpty || a.length != b.length) {
    return 0.0;
  }

  double dotProduct = 0.0;
  double normA = 0.0;
  double normB = 0.0;

  for (var i = 0; i < a.length; i++) {
    dotProduct += a[i] * b[i];
    normA += a[i] * a[i];
    normB += b[i] * b[i];
  }

  if (normA == 0.0 || normB == 0.0) {
    return 0.0;
  }

  return dotProduct / (sqrt(normA) * sqrt(normB));
}
