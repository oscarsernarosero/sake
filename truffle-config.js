const path = require("path");
require("dotenv").config({path: "./.env"});
const HDWalletProvider = require("@truffle/hdwallet-provider");
const Mnemonic = process.env.MNEMONIC;
const Account = 0;

module.exports = {
  // See <http://truffleframework.com/docs/advanced/configuration>
  // to customize your Truffle configuration!
  contracts_build_directory: path.join(__dirname, "client/src/contracts"),
  networks: {
    develop: {
      port: 8545
    },
    kovan: {
      provider: function() {
        return new HDWalletProvider(Mnemonic, "https://kovan.infura.io/v3/815744ee1c864950b1827a90b16006f6", Account)
      },
      network_id: 42
    },
    ropsten: {
      provider: function() {
        return new HDWalletProvider(Mnemonic, "https://ropsten.infura.io/v3/491ffd9a994941089a5e348aba1bb061", Account)
      },
      network_id: 3
    }
  },
  compilers: {
    solc: {
      version: "^0.8.0", // A version or constraint - Ex. "^0.5.0"
                         // Can also be set to "native" to use a native solc
      docker: false, // Use a version obtained through docker
      parser: "solcjs",  // Leverages solc-js purely for speedy parsing
      }
  },
};
