/// Generates a stable, deterministic 31-bit integer hash from a string.
/// This uses the DJB2 algorithm which is simple and fast.
int generateStableHash(String input) {
  int hash = 5381;
  for (int i = 0; i < input.length; i++) {
    hash = ((hash << 5) + hash) + input.codeUnitAt(i);
  }
  // Mask to 31-bit positive integer for compatibility with notification IDs
  return hash & 0x7FFFFFFF;
}
