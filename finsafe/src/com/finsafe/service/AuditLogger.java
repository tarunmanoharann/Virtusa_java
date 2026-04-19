package com.finsafe.service;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

public class AuditLogger {

    public enum EventType {
        SUCCESS, 
        FAILURE,   
        INFO       
    }
    private final ArrayList<String> auditLog = new ArrayList<>();

    private static final DateTimeFormatter FORMATTER =
        DateTimeFormatter.ofPattern("dd-MM-yyyy HH:mm:ss");
    public void log(String accountId, String action, String details, EventType type) {
        String icon = switch (type) {
            case SUCCESS -> "Success";
            case FAILURE -> "Failure";
            case INFO    -> "Info   ";
        };

        String entry = String.format("[%s] %s | Acct: %s | %s | %s",
            LocalDateTime.now().format(FORMATTER), icon, accountId, action, details);

        auditLog.add(entry);
    }

    public void printAuditTrail() {
        System.out.println();
        System.out.println(" FULL AUDIT TRAIL");
        System.out.println(" ───────────────────────────────────");

        if (auditLog.isEmpty()) {
            System.out.println("  No audit records found.");
        } else {
            for (String entry : auditLog) {
                System.out.println("  " + entry);
            }
        }
        System.out.println();
    }

    public List<String> getAuditLog() {
        return new ArrayList<>(auditLog);
    }
}









/**
 * ============================================================
 * CONCEPT: Single Responsibility Principle (SRP) + enum
 * ============================================================
 *
 * SRP = A class should have ONE job / ONE reason to change.
 *
 * Account's job  → manage money (balance, deposit, withdraw)
 * AuditLogger's job → record every event for compliance/debugging
 *
 * By separating these, we can change how logging works (e.g., write to
 * a file, or send to a database) without touching Account at all.
 *
 * CONCEPT: enum (Enumeration)
 * ----------------------------
 * An enum is a special class with a fixed set of named constants.
 * Use it when a variable can only be ONE of a small set of values.
 *
 * WHY not just use Strings?
 *   log("SUCCESS")  → typo-prone: "SUCESS", "success", "Success" all differ
 *   log(EventType.SUCCESS) → compiler catches typos instantly ✅
 */
