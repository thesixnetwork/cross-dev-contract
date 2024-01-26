const fs = require("fs");
const _ = require("lodash");
const Web3 = require("web3");

const FacetCutAction = { Add: 0, Replace: 1, Remove: 2 }
const ZERO_ADDRESS = "0x0000000000000000000000000000000000000000"

const IDIAMOND_CUT = require("../artifacts/contracts/interfaces/IDiamondCut.sol/IDiamondCut.json")


const main = async(network) => {
    const env = require(`../.${network}.env.json`);
    const mnemonic = fs.readFileSync("./.secret").toString().trim();
    
    const web3 = new Web3(Web3.givenProvider || env.rpc_endpoint);
    const account = web3.eth.accounts.privateKeyToAccount(mnemonic);
    web3.eth.accounts.wallet.add(account);   

    console.log(`Reading deploy data for ${network}\n`)
    const fileName = "deploy_data_"+network+".json"
    const deployData = require("../"+fileName)

    for (let i = 0; i < deployData.initial_cuts.length; i++) {
        const facetName = deployData.initial_cuts[i];
        const facet = _.get(deployData,facetName)
        const deployedAddress = _.get(facet,"deployed_address")
        console.log(facetName," inprogress : ",facet)
        if(deployedAddress.length==0) {
            console.log("The facet has not been deployed yet")
            continue
        }
        if(_.get(deployData,facetName+".initialized",false))
        {
            console.log("The facet has already been initialized")
            continue
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
            facetAddress: deployedAddress,
            action: FacetCutAction.Add,
            functionSelectors: contractFuncSig
        })

        const dimondCutContract = new web3.eth.Contract(IDIAMOND_CUT.abi,_.get(deployData,"CrossDev.deployed_address"))
        const gas = await dimondCutContract.methods.diamondCut(cut,ZERO_ADDRESS,[]).estimateGas({ from: env.from,})
        console.log("gas : ",gas)
        
        const result = await dimondCutContract.methods.diamondCut(cut,ZERO_ADDRESS,[]).send({ from: env.from, gas})
        if(result.status) {

            facet.initialized = true
            // Write file back
            fs.writeFileSync("./" + fileName, JSON.stringify(deployData, null, 4));
        }
    }

    
}

main(process.env.network)