# FinSafe — Transaction Validator

> A Core Java console application that simulates a digital wallet with balance validation, custom exceptions, and audit logging.

## Project Structure

```
finsafe/
└── src/
    └── com/
        └── finsafe/
            ├── exception/
            │   └── InSufficientFundsException.java   ← Custom checked exception
            ├── model/
            │   └── Account.java                      ← Encapsulation + business logic
            ├── service/
            │   └── AuditLogger.java                  ← Audit trail (SRP)
            └── app/
                └── FinSafeApp.java                   ← Main entry point + UI
```

---

##  How to Run

```bash
# 1. Navigate to the src directory
cd finsafe/src

# 2. Compile all files
javac com/finsafe/exception/InSufficientFundsException.java \
      com/finsafe/model/Account.java \
      com/finsafe/service/AuditLogger.java \
      com/finsafe/app/FinSafeApp.java

# 3. Run
java com.finsafe.app.FinSafeApp
```


## File-by-File definition

### `InSufficientFundsException.java`
Custom **checked** exception thrown when a withdrawal exceeds the balance. Stores `requestedAmount` and `availableBalance` as fields so callers can extract structured data — not just a string.

### `Account.java`
Core domain class. All fields are `private`. Balance changes only through `deposit()` and `processTransaction()`. Transaction history is capped at 5 entries using an `ArrayList`. Throws both `IllegalArgumentException` (unchecked) and `InSufficientFundsException` (checked).

### `AuditLogger.java`
Records every event — successes and failures — using an `ArrayList<String>`. Uses an inner `enum` for event type. Demonstrates the **Single Responsibility Principle**: logging is its only job.

### `FinSafeApp.java`
Entry point. Owns the main loop, menu rendering, and all `try-catch-finally` blocks. Demonstrates how to call methods that `throw` checked exceptions and how to handle multiple exception types differently.



---

## Core Concepts 


| **Encapsulation** | `Account.java` — private fields, public methods |
| **Custom Exception** | `InSufficientFundsException.java` — extends Exception |
| **Checked vs Unchecked Exceptions** | `InSufficientFunds` (checked) vs `IllegalArgumentException` (unchecked) |
| **try-catch-finally** | `FinSafeApp.handleWithdrawal()` |
| **ArrayList** | `Account.transactionHistory`, `AuditLogger.auditLog` |
| **enum** | `AuditLogger.EventType` |
| **Static fields & methods** | `MAX_HISTORY`, utility methods |
| **Access Modifiers** | private / public / final used  |

---