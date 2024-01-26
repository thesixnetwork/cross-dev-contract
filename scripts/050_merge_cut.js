const fs = require("fs");
const _ = require('lodash');
const { contractCall } = require("../lib/contract")

const Web3 = require("web3");


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

        for (let i = 0; i < contractFuncAbi.length; i++) {
            const func = contractFuncAbi[i];
            const b4 = web3.eth.abi.encodeFunctionSignature(func)
            const currentFacetAddress = await contractCall("DiamondLoupeFacet",_.get(deployData,"CrossDev.deployed_address"),
                "facetAddress",[b4],env.rpc_endpoint
            )
            if(currentFacetAddress == deployedAddress) {
                console.log(b4,"matched, skipped")
            }else {
                console.log(b4,"different, what's next ?")
            }
        }

        // cut.push({
        //     facetAddress: deployedAddress,
        //     action: (_action? _action : FacetCutAction.Add),
        //     functionSelectors: contractFuncSig
        // })

        // const dimondCutContract = new caver.contract(IDIAMOND_CUT.abi,_.get(deployData,"NFTStore.deployed_address"))
    
        // dimondCutContract.methods.diamondCut(cut,ZERO_ADDRESS,[]).send({ from: env.from, gas: 5000000 }).then(console.log)
    }
}

main(process.env.network, process.env.facetName, process.env._action)