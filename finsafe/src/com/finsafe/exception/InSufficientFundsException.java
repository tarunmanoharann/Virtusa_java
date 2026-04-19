package com.finsafe.exception;


public class InSufficientFundsException extends Exception {
    private final double requestedAmount;
    private final double availableBalance;
    public InSufficientFundsException(double requestedAmount, double availableBalance) {
        super(String.format(
            "Insufficient funds! Requested: ₹%.2f | Available: ₹%.2f | Shortfall: ₹%.2f",
            requestedAmount,
            availableBalance,
            (requestedAmount - availableBalance)
        ));
        this.requestedAmount = requestedAmount;
        this.availableBalance = availableBalance;
    }
    public double getRequestedAmount()  { return requestedAmount; }
    public double getAvailableBalance() { return availableBalance; }
    public double getShortfall()        { return requestedAmount - availableBalance; }
}























/**
 * CHECKED vs UNCHECKED 
 *
 *  CHECKED   → extends Exception
 *    - Compiler FORCES caller to handle it (try-catch or throws declaration)
 *    - Use for: recoverable business situations (overdraft, file not found)
 *
 *  UNCHECKED → extends RuntimeException
 *    - Compiler does NOT force handling
 *    - Use for: programming bugs (null pointer, bad argument)
 *
 * We use CHECKED here because an overdraft is a BUSINESS RULE violation —
 * the caller MUST explicitly decide what to do. Money errors can't be silent!
 */