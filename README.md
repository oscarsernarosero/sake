# Sake CreditToken

## Credit tokens designed to facilitate undercollaterized loans in the Defi lending space.

Decentralized lending platforms, most notably AAVE, have recently begun to tackle the problem of providing undercollaterized loans without the cumbersome vetting process seen in the traditional finance space.  The problem is a complex one because it puts the trustless nature of the blockchain at odds with the need to measure the counterparty risk that determines the price of a loan.  

> Ultimately we believe that the "Know Your Customer" (KYC) systems currently used in traditional finance will continue to exist in some form for larger loan amounts, but that smaller uncollateralized loans will be accessed through a credit system that is tied to a user's online identity only.

As a first step towards creating such a online credit system, we have created the CreditToken (CT).  Instead of the traditional credit score that we are accustomed to dealing with currently, users will hold CreditTokens which they must stake in order to access a lending pool's funds.  The more CreditTokens the user has available to stake, the better terms a lender will be willing to offer to the borrower.  When a user complies with the terms of the loan, their CreditTokens are returned to them, plus an additional "boost" to reflect their improved credit rating.

# Smart Contracts and User Experience

## This project currenty consists of 3 smart contracts that the end user interacts with through the front end.

# This section needs fleshing out

- CreditToken.sol
    - mint to Address
    - whitelist addresses

- LendingPool.sol
    - create custom risk parameters
    - fund loan contract

- Loan.sol
    - individual loan contract

- Front End Gif here

# Future Steps 

This project's aim was only to create the CreditToken and demonstrate how it can be used to determine an applicant's ability to access a loan pool with given risk parameters.  There are several additional tools that will be needed to create a fully functioning Defi credit system.  Some of these are:

- Ability to tie a wallet to a user's id and Defit credit history
    - List of potential projects that could be tied into to accomplish this

- Ability to scan Defi platform's history to see an address's creditworthiness in the past
    - Graph protocol?

- Others