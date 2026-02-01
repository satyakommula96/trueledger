# Database Performance

TrueLedger is designed to remain fast even with thousands of transactions. Here's how we optimize for performance.

## 🚀 Optimization Strategies

### 1. Indexing
We use indexes on columns frequently used in `WHERE` clauses and `ORDER BY` operations:
- `date` columns in `variable_expenses` and `income_sources`.
- `category` in `variable_expenses` for aggregation.

### 2. Batching
When seeding data or importing backups, we use SQLite **Transactions** and **Batches**:
```dart
final batch = database.batch();
for (var item in items) {
  batch.insert(table, item);
}
await batch.commit(noResult: true);
```
Batching reduces the number of disk sync operations, speeding up imports by up to 100x compared to individual inserts.

### 3. Asynchronous Operations
All database operations are offloaded to an asynchronous execution pool via `sqflite`, ensuring the UI thread remains jank-free even during complex aggregations.

### 4. WASM Performance (Web)
On the web, we use `sqlite3.wasm` which is highly optimized:
- Employs **IndexedDB** for persistence.
- Provides near-native speed for most CRUD operations.
- **Tip**: Large queries (>10k rows) on the web should still be chunked to avoid blocking the main JS thread for too long.

## 📈 Benchmarking
We track the performance of critical queries:
- **Dashboard Load**: Aggregates 6 months of data (<50ms on modern devices).
- **History View**: Paginated or chunked fetching for deep history.
- **Search**: Optimized using the `LIKE` operator on indexed columns.
