import React, { Component } from "react";
import CreditTokenContract from "./contracts/CreditToken.json";
import LoanContract from "./contracts/Loan.json";
import LoanAgent from "./contracts/LoanAgent.json";
import getWeb3 from "./getWeb3";

import "./App.css";


class App extends Component {
  state = { storageValue: 0, web3: null, accounts: null, contract: null };

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
    contract.options.address="0x42701283Fd609123AeBfde7e8aC433b0C7190E4E"
    // Stores a given value, 5 by default.
    var response = ""
    await contract.methods.balanceOf(accounts[0]).call({ from: accounts[0] })
    .then(function(result){
      response = result / 1000
    });
    console.log(response)
    // Get the value from the contract to prove it worked.
    //const response = await contract.methods.get().call();

    // Update state with the result.
    this.setState({ storageValue: response });
  };

  checkScore2 = async () => {
    const { accounts, contract } = this.state;
    contract.options.address="0x42701283Fd609123AeBfde7e8aC433b0C7190E4E";
    var addressBarEntry = document.getElementById("addressBar").value;
    console.log(addressBarEntry);
    // Stores a given value, 5 by default.
    var response = "";
    await contract.methods.balanceOf(addressBarEntry).call({ from: accounts[0] })
    .then(function(result){
      response = result / 1000
    });
    console.log(response);
    // Get the value from the contract to prove it worked.
    //const response = await contract.methods.get().call();

    // Update state with the result.
    this.setState({ storageValue: response });
  };

  render() {
    if (!this.state.web3) {
      return <div>Loading Web3, accounts, and contract...</div>;
    }
    return (
      <div className="App">
        <h1>Welcome to you DeFi Credit Score</h1>
        <p>The original home to your Crypto Credit Score</p>
        <h2>Get Your Score Below</h2>
        <p>
          Click the button below to check your Credit Score associated with your current attached Web3 wallet
        </p>
        <p>
          <button id="selfclick" onClick={this.checkScore}>Check Your Score </button>
        </p>

        <p>
          Or Enter an Ethereum wallet address and click below the Credit Score associated with that wallet
        </p>
        <input
          type="text"
          id="addressBar"
        />
        <p>
          <button id="selfclick" onClick={this.checkScore2}>Check Their Score </button>
        </p>
        <p></p>
        <div>Your Score is: <strong>{this.state.storageValue}</strong></div>
      </div>
    );
  }
}

export default App;
