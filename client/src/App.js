import React, { Component } from "react";
import CreditTokenContract from "./contracts/CreditToken.json";
import LoanContract from "./contracts/Loan.json";
import LoanAgent from "./contracts/LoanAgent.json";
import getWeb3 from "./getWeb3";

import "./App.css";

const creditTokenAddress = "0x80cDF946c1c86B7eee50743E2bc9a6d7d9ed597A"

class App extends Component {
  state = { creditTokenBalance: 0, web3: null, accounts: null, contract: null, ethBalance: 0 };

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

      const loanContractInstance = new web3.eth.Contract(
        LoanContract.abi,
        LoanContract.networks[this.networkId] && LoanContract.networks[this.networkId].address
      )

      const loanAgentInstance = new web3.eth.Contract(
        LoanAgent.abi,
        LoanAgent.networks[this.networkId] && LoanAgent.networks[this.networkId].address
      )

      // Set web3, accounts, and contract to the state, and then proceed with an
      // example of interacting with the contract's methods.
      this.setState({ web3, accounts, contract: creditTokenInstance });

      // "Let" OR "Const" ARE WAYS TO DECLARE VARIABLES NOW
      var userAddress = accounts[0];
      document.getElementById('userAddress').innerHTML = userAddress;

      // "Let" OR "Const" ARE WAYS TO DECLARE VARIABLES NOW
      var creditTokenContract = creditTokenInstance;
      creditTokenContract.options.address = creditTokenAddress;

      // MAYBE MAKE THIS A "CONST" VARIABLE?
      let balanceOfUser = await web3.eth.getBalance(userAddress);
      let balanceOfUserInEth = web3.utils.fromWei(balanceOfUser, "ether");
      
      this.setState({
        creditTokenBalance: await creditTokenContract.methods.balanceOf(userAddress).call({ from: userAddress }),
        ethBalance: balanceOfUserInEth
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
                <th>Contract Address</th>
                <th>Amount Loaned</th>
                <th>Leverage Provided</th>
                <th>Credit Tokens Used</th>
                <th>Interest Rate</th>
                <th>Maturity Date</th>
                <th>Remaining Balance</th>
                <th>Payment</th>
              </tr>
              <tr>
                <td>Trading Leverage</td>
                <td>0x0Af46820AEB180757A473B443B02fc511f4feffe</td>
                <td>100.000000 (ETH)</td>
                <td>10.000000 (ETH)</td>
                <td>550 (CT)</td>
                <td>10.5%</td>
                <td>Mar 3th, 2021 (615 Blocks)</td>
                <td>100.00000000 (ETH)</td>
                <td><button id="selfclick" onClick={this.checkScore}>Pay Now </button></td>
              </tr>
              <tr>
                <td>Car Loan</td>
                <td>0x5f7ff00f9a9eb1746ba3e598b011c37d90947536</td>
                <td>8.200000 (ETH)</td>
                <td>2.000000 (ETH)</td>
                <td>150 (CT)</td>
                <td>5.5%</td>
                <td>Feb 8th, 2021 (325 Blocks)</td>
                <td>3.128339 (ETH)</td>
                <td><button id="selfclick" onClick={this.checkScore}>Pay Now </button></td>
              </tr>
              <tr>
                <td>Mining Bills</td>
                <td>0x5CC55D91a7C360ce494c5405e3E6B0518173A069</td>
                <td>1.200000 (ETH)</td>
                <td>0.2400000 (ETH)</td>
                <td>50 (CT)</td>
                <td>6.9%</td>
                <td>Feb 1th, 2021 (137 Blocks)</td>
                <td>0.198559 (ETH)</td>
                <td><button id="selfclick" onClick={this.checkScore}>Pay Now </button></td>
              </tr>
              <tr>
                <td>ASIC Hardware</td>
                <td>0x0Af46820AEB180757A473B443B02fc511f4feffe</td>
                <td>5.500000 (ETH)</td>
                <td>0.500000 (ETH)</td>
                <td>450 (CT)</td>
                <td>12.0%</td>
                <td>April 9th, 2021 (1125 Blocks)</td>
                <td>5.500000 (ETH)</td>
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
                Amount to be Loaned
                <br></br>
                <input type="text" id="loanAmountBar" ></input>
              </div>
              <div class="column15">
                Duration of the Loan
                <br></br>
                <input type="text" id="loanDurationBar" ></input>
              </div>
              <div class="column15">
                Amount of CreditTokens to Lock
                <br></br>
                <input type="text" id="loanDurationBar" ></input>
              </div>
              <div class="column15">
              <p>
                <button class="loanbtn" id="selfclick" onClick={this.checkScore2}>Calculate Loan</button>
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
