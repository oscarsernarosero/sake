import React, { Component } from "react";
import CreditTokenContract from "./contracts/CreditToken.json";
import LoanContract from "./contracts/Loan.json";
import LendingPool from "./contracts/LendingPool.json";
import getWeb3 from "./getWeb3";

import "./App.css";

const creditTokenAddress = "0x80cDF946c1c86B7eee50743E2bc9a6d7d9ed597A";
const lendingPoolAddress = "0x3a7039693a8097215c7f91be86eB751211cEF664";

class App extends Component {
  state = {
    creditTokenBalance: 0,
    web3: null,
    accounts: null,
    contract: null,
    lendingPoolContract: null,
    loanContractOne: null,
    ethBalance: 0,
    loansOfBorrowerOne: null,
    loanAmountOne: null,
    creditTokensRequiredOne: null,
    interestRateOne: null,
    creationTimeOne: null,
    loanTermOne: null,
    remainingBalanceOne: null,
    interestOfPayment: null,
    lendingPoolBalance: null
  };

  componentDidMount = async () => {
    try {
      // Get network provider and web3 instance.
      const web3 = await getWeb3();

      // Use web3 to get the user's accounts.
      const accounts = await web3.eth.getAccounts();
      
      // Get networkId
      const networkId = await web3.eth.net.getId();

      // Create contract instances.
      const creditTokenInstance = new web3.eth.Contract(
        CreditTokenContract.abi,
        CreditTokenContract.networks[networkId] && CreditTokenContract.networks[networkId].address,
      );

      const lendingPoolInstance = new web3.eth.Contract(
        LendingPool.abi,
        LendingPool.networks[this.networkId] && LendingPool.networks[this.networkId].address
      )

      // Set web3, accounts, and contract to the state, and then proceed with an
      // example of interacting with the contract's methods.
      this.setState({
        web3,
        accounts,
        contract: creditTokenInstance,
        lendingPoolContract: lendingPoolInstance
      });

      // Pull first account of MetaMask, and save to variable
      var userAddress = accounts[0];
      document.getElementById('userAddress').innerHTML = userAddress;

      // Create more contract instances
      var creditTokenContract = creditTokenInstance;
      creditTokenContract.options.address = creditTokenAddress;

      var lendingPoolContract = lendingPoolInstance;
      lendingPoolContract.options.address = lendingPoolAddress;

      // Get balance of account 1 in MetaMask
      let balanceOfUser = await web3.eth.getBalance(userAddress);
      let balanceOfUserInEth = web3.utils.fromWei(balanceOfUser, "ether");

      let creditTokenBalanceInWei = await creditTokenContract.methods.balanceOf(userAddress).call({ from: userAddress });
      let creditTokenBalance = web3.utils.fromWei(creditTokenBalanceInWei, "kwei");
      
      // Set state of user's ETH and CreditToken balance, and active loans
      this.setState({
        creditTokenBalance: creditTokenBalance,
        ethBalance: balanceOfUserInEth,
        loansOfBorrower: await lendingPoolContract.methods.loansOfBorrower(userAddress, 0).call({ from: userAddress }),
        lendingPoolBalance: await web3.utils.fromWei(await lendingPoolContract.methods.getBalance().call({ from: userAddress }), "ether")
     })

     // Create contract instance
      const loanContractInstance = new web3.eth.Contract(
        LoanContract.abi,
        LoanContract.networks[networkId] && await LoanContract.networks[this.networkId].address
      );

      var loanContract = loanContractInstance;
      loanContract.options.address = this.state.loansOfBorrower;

      this.setState({
        loanContract: loanContract,
      })
      

      // Set state of details of active contract
      this.setState({
        loanAmount: await web3.utils.fromWei(await loanContract.methods.loanAmount().call({ from: userAddress }), "ether"),
        creditTokensRequired: (await loanContract.methods.creditTokensRequired().call({ from: userAddress }))/1000,
        interestRate: await loanContract.methods.interestRate().call({ from: userAddress }),
        creationTime: await loanContract.methods.creationTime().call({ from: userAddress }),
        loanTerm: await loanContract.methods.loanTerm().call({ from: userAddress }),
        remainingBalance: await web3.utils.fromWei(await loanContract.methods.howMuchToPayOff().call({ from: userAddress }), "ether"),
        interestOfPayment: await loanContract.methods.calculateInteresestsofPayment().call({ from: userAddress })
      })


    } catch (error) {
      // Catch any errors for any of the above operations.
      alert(
        `Failed to load web3, accounts, or contract. Check console for details.`,
      );
      console.error(error);
    }
  };

  // Function to call createLoan() from LendingPool.sol
  handleCreateLoan = async () => {
    let collateralRequired = 100000;
    let borrower = this.state.accounts[0];
    let creditTokensRequired = document.getElementById("creditTokenStakingBar").value;
    let loanAmount = document.getElementById("loanAmountBar").value;
    let loanLength = document.getElementById("loanLengthDropdown").value;
    let interestRate = 1000;

    await this.state.lendingPoolContract.methods.createLoan(
      collateralRequired,
      borrower,
      creditTokensRequired,
      loanAmount,
      loanLength,
      interestRate
    ).send({ from: this.state.accounts[0] })
  }

  /*

  handleAcceptLoan = async () => {
    await this.state.loanContract.methods.receive().send({ from: this.state.accounts[0] });
  }

  let collateralRequired = document.getElementById("collateralAmountBar").value;

  let interestRate = document.getElementById("loanInterestBar").value;


  <div class="column15">
                Collateral Required
                <br></br>
                <input type="text" id="collateralAmountBar" ></input>
              </div>


  <div class="column15">
                Loan Length
                <br></br>
                <input type="text" id="loanLengthBar" ></input>
              </div>
  

              <div class="column20">
                  <text align="center">Your Calculated Interest Rate: <strong>{this.state.interestOfPayment}</strong><div id="loanPercent"><strong></strong></div></text>
                </div>


                <div class="column15">
                Loan Interest Rate
                <br></br>
                <input type="text" id="loanInterestBar" ></input>
              </div>


              <div class="column20">
                  <text align="center">Total Cost of Loan: <div id="loanPercent"><strong></strong></div></text>
                </div>


                // Nickname details of loan
                <th>Nickname</th>

                <td> </td>

                <div class="column15">
                Loan Nickname
                <br></br>
                <input type="text" id="loanNicknameBar" ></input>
              </div>

              <td><button id="selfclick" onClick={this.handleAcceptLoan}>Start Loan</button></td>

  
  */

  render() {
    
    if (!this.state.web3) {
      return <div>Loading Web3, accounts, and contract...</div>;
    }
    return (
      <div className="App">
        <div class="body">
          <div class="row">
            <div class="column65">
              <h1 align="left">Welcome to Saké 🍶 Your DeFi Credit Score & Lending Platform </h1>
              <p align="left"><div><text align="center">Lending Pool Address: <strong>{lendingPoolAddress}</strong><div id="loanPercent"></div></text></div></p>
              <p align="left"><div> <text align="rightr">Lending Pool Balance: <strong>{this.state.lendingPoolBalance} ETH</strong><div id="loanPercent"></div></text> </div></p>
            </div>
            <p>
            </p>
            <div class="column2">
              <p>User: <strong><div id="userAddress"></div></strong></p>
              <p>User Balance: <strong>{this.state.ethBalance} ETH</strong></p>
              <p>User CreditToken Balance: <strong> {this.state.creditTokenBalance} </strong></p>
            </div>
          </div>
          <br></br>
          <div class="row">
              <h2 align="left"><u>Currently Active Loans</u></h2>
              <table id="loans">
                <tr>
                  <th>Loan Address</th>
                  <th>Loan Amount (ETH)</th>
                  <th>Staked Credit Tokens</th>
                  <th>Interest Rate</th>
                  <th>Block No. at Creation</th>
                  <th>Loan Length (Days)</th>
                  <th>Loan Remaining Balance (ETH)</th>
                </tr>
                <tr>
                  <td>{this.state.loansOfBorrower}</td>
                  <td>{this.state.loanAmount}</td>
                  <td>{this.state.creditTokensRequired}</td>
                  <td>{(this.state.interestRate) / 100}%</td>
                  <td>{this.state.creationTime}</td>
                  <td>{this.state.loanTerm}</td>
                  <td>{this.state.remainingBalance}</td>
                </tr>
              </table>
          </div>
          <br></br>
          <div class="row">
            <h2 align="left"><u>Start a New Loan</u></h2>
              <div class="column15">
                CreditToken Amount to Stake
                <br></br>
                <input type="text" id="creditTokenStakingBar" ></input>
              </div>
              <div class="column15">
                Loan Amount (Wei)
                <br></br>
                <input type="text" id="loanAmountBar" ></input>
              </div>
              <div class="column15">
                Loan Length
                <br></br>
                <div>
                  <select id="loanLengthDropdown">
                    <option value="1">One Day</option>
                    <option value="2">Two Days</option>
                    <option value="3">Three Days</option>
                  </select>
                </div>
              </div>
              <div class="column15">
              <p>
                <button class="loanbtn" id="selfclick" onClick={this.handleCreateLoan}>Create Loan</button>
              </p>
              </div>
              <div class="row">
                <div class="column20">
                  <text align="center">Calculated Interest Rate: <strong>10%</strong><div id="loanPercent"></div></text>
                </div>
                <div class="column20">
                  <text align="center">Collateral Required: <strong>0 ETH</strong><div id="loanPercent"></div></text>
                </div>
                <div class="column10">
              </div>
              </div>
          </div>
        </div>
      </div>
    );
  }
}

export default App;
