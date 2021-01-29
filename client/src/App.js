import React, { Component } from "react";
import CreditTokenContract from "./contracts/CreditToken.json";
import LoanContract from "./contracts/Loan.json";
import LoanAgent from "./contracts/LoanAgent.json";
import getWeb3 from "./getWeb3";

import "./App.css";

const creditTokenAddress = "0x0Af46820AEB180757A473B443B02fc511f4feffe"

class App extends Component {
  state = { creditTokenBalance: 0, web3: null, accounts: null, contract: null };

  componentDidMount = async () => {
    try {
      // Get network provider and web3 instance.
      const web3 = await getWeb3();

      // Use web3 to get the user's accounts.
      const accounts = await web3.eth.getAccounts();
      

      // Get the contract instance.
      const networkId = await web3.eth.net.getId();
      const deployedNetwork = CreditTokenContract.networks[networkId];
      const instance = new web3.eth.Contract(
        CreditTokenContract.abi,
        deployedNetwork && deployedNetwork.address,
      );
      // Set web3, accounts, and contract to the state, and then proceed with an
      // example of interacting with the contract's methods.
      this.setState({ web3, accounts, contract: instance });

      var userAddress = accounts[0];
      document.getElementById('userAddress').innerHTML = userAddress;
      var contract = instance;
      contract.options.address=creditTokenAddress;
      this.setState({ creditTokenBalance: await contract.methods.balanceOf(accounts[0]).call({ from: accounts[0] }) })

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
              <h1>Welcome to Saké 🍶  Your DeFi Credit Score & Lending Platform </h1>
              <p align="left"><strong>User: </strong><div id="userAddress" align="left"></div></p>
            </div>
            <div class="column2">
              <p>Current Interest Rate:</p>
              <p>Credit Token Balance: <strong> {this.state.creditTokenBalance} </strong></p>
              <p>Ethereum Balance:</p>
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
            <div class="column20">
                Click the button to check your Credit Score associated with your current attached Web3 wallet
              </div>
              <div class="column20">
              <p>
                <button id="selfclick" onClick={this.checkScore}>Check Your Score </button>
              </p>
              </div>
              <div class="column20">
              <p>
                Or Enter an Ethereum wallet address and click below the Credit Score associated with that wallet
              </p>
              <input type="text" id="addressBar" ></input>
              </div>
              <div class="column20">
              <p>
                <button id="selfclick" onClick={this.checkScore2}>Check Their Score </button>
              </p>
              </div>
              <div class="column20">
              <p>
                <text align="center">Your Credit Token Balance: <strong>{this.state.creditTokenBalance}</strong> </text>
              </p>
              </div>
          </div>
        </div>
      </div>
    );
  }
}

export default App;
