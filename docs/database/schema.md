# Database Schema

TrueLedger uses a relational database model to ensure data integrity and complex querying capabilities.

## 🗄️ Database Technology
- **Mobile & Desktop**: SQLite with **SQLCipher (AES-256)** encryption.
- **Web**: SQLite via **WASM** with IndexedDB persistence.

## 📋 Tables & Relationships

### 1. `income_sources`
Tracks money coming in.
- `id`: INTEGER PRIMARY KEY
- `source`: TEXT (e.g., "Salary")
- `amount`: INTEGER (Stored in subunit/cents if needed, currently direct)
- `date`: TEXT (ISO8601)

### 2. `variable_expenses`
Primary table for daily spending.
- `id`: INTEGER PRIMARY KEY
- `date`: TEXT (ISO8601)
- `amount`: INTEGER
- `category`: TEXT
- `note`: TEXT

### 3. `fixed_expenses`
Recurring bills.
- `id`: INTEGER PRIMARY KEY
- `name`: TEXT
- `amount`: INTEGER
- `category`: TEXT
- `date`: TEXT (ISO8601)

### 4. `investments`
Tracks assets.
- `id`: INTEGER PRIMARY KEY
- `name`: TEXT
- `amount`: INTEGER
- `active`: INTEGER (Boolean 0/1)
- `type`: TEXT (e.g., "Equity", "Mutual Fund")
- `date`: TEXT

### 5. `loans`
Tracks liabilities.
- `id`: INTEGER PRIMARY KEY
- `name`: TEXT
- `loan_type`: TEXT
- `total_amount`: INTEGER
- `remaining_amount`: INTEGER
- `emi`: INTEGER
- `interest_rate`: REAL
- `due_date`: TEXT
- `date`: TEXT

### 6. `credit_cards`
- `id`: INTEGER PRIMARY KEY
- `bank`: TEXT
- `credit_limit`: INTEGER
- `statement_balance`: INTEGER
- `min_due`: INTEGER
- `due_date`: TEXT
- `statement_date`: TEXT

### 7. `budgets`
- `id`: INTEGER PRIMARY KEY
- `category`: TEXT (Unique)
- `monthly_limit`: INTEGER

### 8. `saving_goals`
- `id`: INTEGER PRIMARY KEY
- `name`: TEXT
- `target_amount`: INTEGER
- `current_amount`: INTEGER
