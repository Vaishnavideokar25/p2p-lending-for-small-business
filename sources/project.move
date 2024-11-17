module P2p_Lending_For_Small_Buisness::P2PLending {
    use aptos_framework::signer;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;

    /// Struct representing a loan request
    struct Loan has store, key {
        requested_amount: u64,     // Amount requested by borrower
        funded_amount: u64,        // Amount currently funded
        borrower: address,         // Borrower's address
        status: bool              // true if loan is active
    }

    /// Function to create a new loan request
    public fun create_loan(borrower: &signer, amount: u64) {
        let loan = Loan {
            requested_amount: amount,
            funded_amount: 0,
            borrower: signer::address_of(borrower),
            status: false
        };
        move_to(borrower, loan);
    }

    /// Function for lenders to fund a loan request
    public fun fund_loan(
        lender: &signer, 
        borrower_addr: address, 
        amount: u64
    ) acquires Loan {
        let loan = borrow_global_mut<Loan>(borrower_addr);
        
        assert!(loan.funded_amount < loan.requested_amount, 1);
        assert!(!loan.status, 2);
        
        let payment = coin::withdraw<AptosCoin>(lender, amount);
        coin::deposit<AptosCoin>(borrower_addr, payment);
        
        loan.funded_amount = loan.funded_amount + amount;
        if (loan.funded_amount == loan.requested_amount) {
            loan.status = true;
        };
    }
}