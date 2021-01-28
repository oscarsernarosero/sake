const path = require("path");
const solc = require("solc");
const fs = require("fs-extra");

// Go and delete contents of build/ to recompile files
const buildPath = path.resolve(__dirname, "build");
fs.removeSync(buildPath);

// Create path to CreditToken.sol, compile, and take contracts property
const creditTokenPath = path.resolve(__dirname, "contracts", "CreditToken.sol");
const source = fs.readFileSync(creditTokenPath, "utf8");
const output = solc.compile(source, 1).contracts; // THROWING ERROR
console.log("compiled CreditToken");


// re-create build/
fs.ensureDirSync(buildPath);

for (let contract in output) {
    fs.outputJsonSync(
        path.resolve(buildPath, contract + ".json"),
        output[contract]
    )
}