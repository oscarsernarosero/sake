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
            <div class="column">
              <h1>Welcome to your DeFi Credit Score & Lending Platform</h1>
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
              <h2 align="left">Current Active Loans</h2>
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
          <br></br>
          <div class="row">
            <h2 align="left"> Start a New Loan </h2>
          </div>
        </div>
      </div>
    );
  }
}

export default App;
