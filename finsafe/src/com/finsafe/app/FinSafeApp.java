package com.finsafe.app;

import com.finsafe.exception.InSufficientFundsException;
import com.finsafe.model.Account;
import com.finsafe.service.AuditLogger;
import com.finsafe.service.AuditLogger.EventType;

import java.util.InputMismatchException;
import java.util.Scanner;

public class FinSafeApp {
    private static final Scanner scanner = new Scanner(System.in);
    private static AuditLogger auditLogger;
    private static Account account;

    public static void main(String[] args) {
        auditLogger = new AuditLogger();

        account = setupAccount();
        auditLogger.log(
            account.getAccountId(),
            "ACCOUNT_OPENED",
            "Holder: " + account.getAccountHolder() + " | Opening Balance: " + account.getBalance(),
            EventType.INFO
        );

        boolean running = true;
        while (running) {
            printMenu();
            int choice = readIntSafely("  Enter choice (1-6): ");

            switch (choice) {
                case 1 -> handleDeposit();
                case 2 -> handleWithdrawal();
                case 3 -> {
                    account.printMiniStatement();
                    auditLogger.log(account.getAccountId(), "MINI_STATEMENT_VIEWED",
                        "Balance: " + account.getBalance(), EventType.INFO);
                }
                case 4 -> auditLogger.printAuditTrail();
                case 5 -> printBalance();
                case 6 -> {
                    System.out.println("\n  Thank you for using FinSafe. Goodbye!\n");
                    running = false;
                }
                default -> System.out.println("  Invalid option. Enter 1 to 6.\n");
            }
        }

        scanner.close();
    }

    private static void handleDeposit() {
        System.out.println("\n  -- DEPOSIT ---------------------------------------------");
        double amount = readDoubleSafely("  Enter deposit amount (Rs): ");

        try {
            account.deposit(amount);
            auditLogger.log(account.getAccountId(), "DEPOSIT",
                "Amount: Rs" + String.format("%.2f", amount)
                + " | New Balance: Rs" + String.format("%.2f", account.getBalance()),
                EventType.SUCCESS);

        } catch (IllegalArgumentException e) {
            System.out.println("  Deposit failed: " + e.getMessage());
            auditLogger.log(account.getAccountId(), "DEPOSIT_FAILED",
                e.getMessage(), EventType.FAILURE);
        }
        System.out.println();
    }

    private static void handleWithdrawal() {
        System.out.println("\n  -- WITHDRAWAL ------------------------------------------");
        double amount = readDoubleSafely("  Enter withdrawal amount (Rs): ");

        try {
            account.processTransaction(amount);

            auditLogger.log(account.getAccountId(), "WITHDRAWAL",
                "Amount: Rs" + String.format("%.2f", amount)
                + " | New Balance: Rs" + String.format("%.2f", account.getBalance()),
                EventType.SUCCESS);

        } catch (InSufficientFundsException e) {
            System.out.println("  " + e.getMessage());
            System.out.printf("  Top up at least Rs%.2f to complete this transaction.%n",
                e.getShortfall());
            auditLogger.log(account.getAccountId(), "WITHDRAWAL_FAILED_OVERDRAFT",
                "Requested: Rs" + e.getRequestedAmount()
                + " | Available: Rs" + e.getAvailableBalance(),
                EventType.FAILURE);

        } catch (IllegalArgumentException e) {
            System.out.println(" Invalid amount: " + e.getMessage());
            auditLogger.log(account.getAccountId(), "WITHDRAWAL_FAILED_INVALID",
                e.getMessage(), EventType.FAILURE);

        } finally {
            System.out.printf(" Current Balance: Rs%.2f%n", account.getBalance());
        }
        System.out.println();
    }

    private static void printBalance() {
        System.out.println();
        System.out.println("  +----------------------------------+");
        System.out.printf( "  |  Account   : %-18s |%n", account.getAccountId());
        System.out.printf( "  |  Holder    : %-18s |%n", account.getAccountHolder());
        System.out.printf( "  |  Balance   : Rs%-16.2f |%n", account.getBalance());
        System.out.println("  +----------------------------------+");
        System.out.println();
    }

    private static Account setupAccount() {
        System.out.println("  -- NEW ACCOUNT SETUP ------------------------------------------");
        System.out.print("  Enter your name: ");
        String name = scanner.nextLine().trim();
        double openingBalance = readDoubleSafely("  Enter opening balance (Rs): ");
        String accountId = "ACC-" + (int)(Math.random() * 9000 + 1000);

        Account acc = new Account(accountId, name, openingBalance);
        System.out.printf("%n Account created! ID: %s%n%n", accountId);
        return acc;
    }

    private static int readIntSafely(String prompt) {
        System.out.print(prompt);
        try {
            int value = scanner.nextInt();
            scanner.nextLine();
            return value;
        } catch (InputMismatchException e) {
            scanner.nextLine();
            return -1;
        }
    }

    private static double readDoubleSafely(String prompt) {
        System.out.print(prompt);
        try {
            double value = scanner.nextDouble();
            scanner.nextLine();
            return value;
        } catch (InputMismatchException e) {
            System.out.println("  Please enter a valid number.");
            scanner.nextLine();
            return 0.0;
        }
    }

    private static void printMenu() {
        System.out.println();
        System.out.println("              MAIN MENU             ");
        System.out.println("  -----------------------------------");
        System.out.println("  |  1. Deposit                     |");
        System.out.println("  |  2. Withdraw / Spend            |");
        System.out.println("  |  3. Mini Statement (last 5)     |");
        System.out.println("  |  4. Full Audit Trail            |");
        System.out.println("  |  5. Check Balance               |");
        System.out.println("  |  6. Exit                        |");
        System.out.println("  -----------------------------------");
    }
}