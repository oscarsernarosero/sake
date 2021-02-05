import React, { Component } from "react";
import CreditTokenContract from "./contracts/CreditToken.json";
import LoanContract from "./contracts/Loan.json";
import LendingPool from "./contracts/LendingPool.json";
import getWeb3 from "./getWeb3";

import "./App.css";

const creditTokenAddress = "0x80cDF946c1c86B7eee50743E2bc9a6d7d9ed597A";
const lendingPoolAddress = "0x80CE1549e027eB853242B344b91C78a683B35088";
const loanContractAddress = "0xD0D55fcF0858706a61A20B434e44ca59de34B6B5";

class App extends Component {
  state = {
    creditTokenBalance: 0,
    web3: null,
    accounts: null,
    contract: null,
    lendingPoolContract: null,
    ethBalance: 0,
    loansOfBorrower: null,
    loanAmount: null
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

      var userAddress = accounts[0];
      document.getElementById('userAddress').innerHTML = userAddress;

      var creditTokenContract = creditTokenInstance;
      creditTokenContract.options.address = creditTokenAddress;

      var lendingPoolContract = lendingPoolInstance;
      lendingPoolContract.options.address = lendingPoolAddress;

      // MAYBE MAKE THIS A "CONST" VARIABLE?
      let balanceOfUser = await web3.eth.getBalance(userAddress);
      let balanceOfUserInEth = web3.utils.fromWei(balanceOfUser, "ether");
      
      this.setState({
        creditTokenBalance: await creditTokenContract.methods.balanceOf(userAddress).call({ from: userAddress }),
        ethBalance: balanceOfUserInEth,
        loansOfBorrower: await lendingPoolContract.methods.loansOfBorrower(userAddress, 0).call({ from: userAddress })
     })

      const loanContractInstance = new web3.eth.Contract(
        LoanContract.abi,
        LoanContract.networks[networkId] && await LoanContract.networks[this.networkId].address
      );

      var loanContract = loanContractInstance;
      loanContract.options.address = loanContractAddress;

      this.setState({
        loanAmount: await loanContract.methods.loanAmount().call({ from: userAddress })
      })


    } catch (error) {
      // Catch any errors for any of the above operations.
      alert(
        `Failed to load web3, accounts, or contract. Check console for details.`,
      );
      console.error(error);
    }
  };
  
  checkScore = async () => {
    const { accounts, contract } = this.state;
    contract.options.address=creditTokenAddress
    var response = ""
    await contract.methods.balanceOf(accounts[0]).call({ from: accounts[0] })
    .then(function(result){
      response = result / 1000
    });
    // Get the value from the contract to prove it worked.
    //const response = await contract.methods.function().call();

    // Update state with the result.
    this.setState({ creditTokenBalance: response });
  };

  checkScore2 = async () => {
    const { accounts, contract } = this.state;
    contract.options.address=creditTokenAddress;
    var addressBarEntry = document.getElementById("addressBar").value;
    console.log(addressBarEntry);
    var response = "";
    await contract.methods.balanceOf(addressBarEntry).call({ from: accounts[0] })
    .then(function(result){
      response = result / 1000
    });
 
    this.setState({ creditTokenBalance: response });
  };

  handleCreateLoan = async () => {
    let collateralRequired = document.getElementById("collateralAmountBar").value;
    let borrower = this.state.accounts[0];
    let creditTokensRequired = document.getElementById("creditTokenStakingBar").value;
    let loanAmount = document.getElementById("loanAmountBar").value;
    let loanLength = document.getElementById("loanLengthBar").value;
    let interestRate = document.getElementById("loanInterestBar").value;

    await this.state.lendingPoolContract.methods.createLoan(
      collateralRequired,
      borrower,
      creditTokensRequired,
      loanAmount,
      loanLength,
      interestRate
    ).send({ from: this.state.accounts[0] })
  }

  render() {
    
    if (!this.state.web3) {
      return <div>Loading Web3, accounts, and contract...</div>;
    }
    return (
      <div className="App">
        <div class="body">
          <div class="row">
            <div class="column75">
              <h1>Welcome to Saké 🍶 Your DeFi Credit Score & Lending Platform </h1>
              <p align="left"><strong>User: </strong><div id="userAddress" align="left"></div></p>
            </div>
            <div class="column2">
              <p>Current Interest Rate: </p>
              <p>Credit Token Balance: <strong> {this.state.creditTokenBalance} </strong></p>
              <p>Ethereum Balance: <strong>{this.state.ethBalance} ETH</strong></p>
              </div>
          </div>
          <br></br>
          <div class="row">
              <h2 align="left"><u>Current Active Loans</u></h2>
              <table id="loans">
              <tr>
                <th>Nickname</th>
                <th>Loan Address</th>
                <th>Amount Loaned</th>
                <th>Credit Tokens Staked</th>
                <th>Interest Rate</th>
                <th>Maturity Date</th>
                <th>Remaining Balance</th>
                <th>Payment</th>
              </tr>
              <tr>
                <td> </td>
                <td>{this.state.loansOfBorrower}</td>
                <td>{this.state.loanAmount}</td>
                <td> </td>
                <td> </td>
                <td> </td>
                <td> </td>
                <td> </td>
                <td><button id="selfclick" onClick={this.checkScore}>Pay Now </button></td>
              </tr>
              </table>
          </div>
          <br></br>
          <div class="row">
            <h2 align="left"><u>Start a New Loan</u></h2>
            <div class="column15">
                Loan Nickname
                <br></br>
                <input type="text" id="loanNicknameBar" ></input>
              </div>
              <div class="column15">
              Asset to Receive
                <br></br>
                <div>
                  <select>
                    <option value="ETH">Ethereum (ETH)</option>
                    <option value="BTC">Bitcoin (BTC)</option>
                    <option value="AAVE">AAVE (AAVE)</option>
                  </select>
                </div>
              </div>
              <div class="column15">
                Collateral Requied
                <br></br>
                <input type="text" id="collateralAmountBar" ></input>
              </div>
              <div class="column15">
                CreditToken Amount to Stake
                <br></br>
                <input type="text" id="creditTokenStakingBar" ></input>
              </div>
              <div class="column15">
                Loan Amount
                <br></br>
                <input type="text" id="loanAmountBar" ></input>
              </div>
              <div class="column15">
                Loan Length
                <br></br>
                <input type="text" id="loanLengthBar" ></input>
              </div>
              <div class="column15">
                Loan Interest Rate
                <br></br>
                <input type="text" id="loanInterestBar" ></input>
              </div>
              <div class="column15">
              <p>
                <button class="loanbtn" id="selfclick" onClick={this.handleCreateLoan}>Create Loan</button>
              </p>
              </div>
              <div class="row">
                <div class="column20">
                  <text align="center">Your Calculated Interest Rate: <div id="loanPercent"><strong>12%</strong></div></text>
                </div>
                <div class="column20">
                  <text align="center">Your Collateral Required: <div id="loanPercent"><strong>1.25 (ETH)</strong></div></text>
                </div>
                <div class="column20">
                  <text align="center">Total Cost of Loan: <div id="loanPercent"><strong>10.25 (ETH)</strong></div></text>
                </div>
                <div class="column25">
                  <text align="center">Contract Deposit Address: <div id="loanPercent"><strong>0x0Af46820AEB180757A473B443B02fc511f4feffe</strong></div></text>
                </div>
                <div class="column10">
              <p>
                <button align="right" class="acceptbtn" id="selfclick" onClick={this.checkScore2}>Accept Loan</button>
              </p>
              </div>
              </div>
          </div>
        </div>
      </div>
    );
  }
}

export default App;
