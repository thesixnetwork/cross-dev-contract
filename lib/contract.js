const Web3 = require("web3")
const _ = require("lodash")


const contractCall = (_contractName,_contractAddress,_functionName,_params,_rpcEndpoint,_from) => {
    const web3 = new Web3(_rpcEndpoint)
    const contract = new web3.eth.Contract(require(`../artifacts/contracts/facets/${_contractName}.sol/${_contractName}.json`).abi,_contractAddress)
    return _.invoke(contract.methods,_functionName,..._params).call((_from? {from:_from} : {}))
}

const contractSend = async(_contractName,_contractAddress,_functionName,_params,_rpcEndpoint,_mnemonic,_from) => {
    const web3 = new Web3(_rpcEndpoint)

    const account = web3.eth.accounts.privateKeyToAccount(_mnemonic);
    web3.eth.accounts.wallet.add(account);

    const contract = new web3.eth.Contract(require(`../artifacts/contracts/facets/${_contractName}.sol/${_contractName}.json`).abi,_contractAddress)
    const gas = await _.invoke(contract.methods,_functionName,..._params).estimateGas({ from: _from})
    console.log(gas)
    // ,gasPrice:web3.utils.toWei("30","gwei")
    return _.invoke(contract.methods,_functionName,..._params).send({ from: _from,gas:gas})
    // return _.invoke(contract.methods,_functionName,..._params).send({ from: _from,gas:gas,gasPrice:web3.utils.toWei("30","gwei")})
}

module.exports = {
    contractCall,
    contractSend
}