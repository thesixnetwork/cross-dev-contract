const fs = require("fs");
const _ = require('lodash');
const Web3 = require("web3");
const FacetCutAction = { Add: 0, Replace: 1, Remove: 2 }
const ZERO_ADDRESS = "0x0000000000000000000000000000000000000000"

const IDIAMOND_CUT = require("../artifacts/contracts/interfaces/IDiamondCut.sol/IDiamondCut.json")

const appArgs = process.argv.slice(2);

const main = async(network,facetName,_action) => {
    const env = require(`../.${network}.env.json`);
    const mnemonic = fs.readFileSync("./.secret").toString().trim();
    
    const web3 = new Web3(Web3.givenProvider || env.rpc_endpoint);
    const account = web3.eth.accounts.privateKeyToAccount(mnemonic);
    web3.eth.accounts.wallet.add(account);   

    console.log(`Reading deploy data for ${network}\n`)
    const fileName = "deploy_data_"+network+".json"
    const deployData = require("../"+fileName)

    if(_.get(deployData,facetName+".is_facet",false)) {
        const deployedAddress = _.get(deployData,facetName+".deployed_address")
        if(deployedAddress.length==0) {
            console.log("The facet has not been deployed yet")
            return
        }
        const cut = []
        let contract = require(`../artifacts/contracts/facets/${facetName}.sol/${facetName}.json`)
        let contractFuncAbi = contract.abi.filter(i => i.type === "function")
        let contractFuncSig = []
        contractFuncSig = contractFuncAbi.map(func => {
            const b4 = web3.eth.abi.encodeFunctionSignature(func)
            console.log(b4,func.name)
            return b4
        })

        cut.push({
            facetAddress: (_action && _action == FacetCutAction.Remove? ZERO_ADDRESS :deployedAddress ),
            action: (_action? _action : FacetCutAction.Add),
            functionSelectors: contractFuncSig
        })
        console.log(cut)
        const dimondCutContract = new web3.eth.Contract(IDIAMOND_CUT.abi,_.get(deployData,"CrossDev.deployed_address"))
        const gasPrice = await web3.eth.getGasPrice()
        console.log(gasPrice)
    
        dimondCutContract.methods.diamondCut(cut,ZERO_ADDRESS,[]).send({ from: env.from, gas: 5000000, gasPrice: gasPrice }).then(console.log)
    }
}

main(process.env.network, process.env.facetName, process.env._action)