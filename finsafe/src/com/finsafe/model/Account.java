package com.finsafe.model;

import com.finsafe.exception.InSufficientFundsException;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

public class Account {

    private final String accountId;
    private final String accountHolder;
    private double balance;

    private final ArrayList<String> transactionHistory;
    private static final int MAX_HISTORY = 5;

    private static final DateTimeFormatter FORMATTER =
        DateTimeFormatter.ofPattern("dd-MM-yyyy HH:mm:ss");

    public Account(String accountId, String accountHolder, double initialBalance) {
        if (initialBalance < 0) {
            throw new IllegalArgumentException("Initial balance cannot be negative.");
        }

        this.accountId     = accountId;
        this.accountHolder = accountHolder;
        this.balance       = initialBalance;

        this.transactionHistory = new ArrayList<>();

        logTransaction("OPENED", initialBalance, initialBalance);
    }

    public void processTransaction(double amount) throws InSufficientFundsException {
        if (amount <= 0) {
            throw new IllegalArgumentException(
                "Withdrawal amtt must be positive. Received: ₹" + amount
            );
        }

        if (amount > balance) {
            throw new InSufficientFundsException(amount, balance);
        }

        balance -= amount;
        logTransaction("DEBIT", amount, balance);
        System.out.printf("   ₹%.2f debited. New balance: ₹%.2f%n", amount, balance);
    }

    public void deposit(double amount) {
        if (amount <= 0) {
            throw new IllegalArgumentException(
                "Deposit amt must be positive. Received: ₹" + amount
            );
        }
        balance += amount;
        logTransaction("CREDIT", amount, balance);
        System.out.printf("   ₹%.2f credited. New balance: ₹%.2f%n", amount, balance);
    }

    public void printMiniStatement() {
        System.out.println();
        System.out.printf( "     MINI STATEMENT                      Acct: %-12s║%n", accountId);
        System.out.printf( "     Holder : %-47s║%n", accountHolder);
        System.out.printf( "     Balance: ₹%-46.2f║%n", balance);
        System.out.println("  ------------------------------------------------------------");
        System.out.println("     DATE & TIME           TYPE    AMOUNT        BALANCE      ");
        System.out.println("  ------------------------------------------------------------");

        if (transactionHistory.isEmpty()) {
            System.out.println("                 No transactions on record.                  ");
        } else {
            List<String> recent = transactionHistory.subList(
                Math.max(0, transactionHistory.size() - MAX_HISTORY),
                transactionHistory.size()
            );
            for (String entry : recent) {
                System.out.println("     " + entry + "   ");
            }
        }

        System.out.println("------------------------------------------------");
        System.out.println();
    }

    private void logTransaction(String type, double amount, double balanceAfter) {
        String timestamp = LocalDateTime.now().format(FORMATTER);

        String entry = String.format("%-19s  %-7s ₹%-12.2f ₹%-10.2f",
            timestamp, type, amount, balanceAfter);

        transactionHistory.add(entry);

        if (transactionHistory.size() > MAX_HISTORY) {
            transactionHistory.remove(0);
        }
    }

    public String getAccountId()     { return accountId; }
    public String getAccountHolder() { return accountHolder; }
    public double getBalance()       { return balance; }
}








/**
 * CONCEPT: Encapsulation
 * RULE: Fields are PRIVATE. Outside code uses PUBLIC methods to interact.
 *
 * WHY? Imagine if `balance` were public:
 *   account.balance = 1000000;  // Anyone can set it directly! Dangerous!
 *
 * With encapsulation:
 *   account.deposit(1000000);   // Goes through validation logic. Safe!
 */