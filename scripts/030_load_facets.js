const fs = require("fs");
const _ = require("lodash");
const Web3 = require("web3");

const FacetCutAction = { Add: 0, Replace: 1, Remove: 2 }
const ZERO_ADDRESS = "0x0000000000000000000000000000000000000000"

const DIAMOND_LOUPE = require("../artifacts/contracts/facets/DiamondLoupeFacet.sol/DiamondLoupeFacet.json")

const findFacetByAddress = (_deployData,_address) => {
    const web3 = new Web3();
    let facetName
    for (let i = 0; i < Object.keys(_deployData).length; i++) {
        const key = Object.keys(_deployData)[i];
        if(
            _.get(_deployData,`${key}.is_facet`,false) && 
            _.get(_deployData,`${key}.deployed_address`,"-").toLowerCase() === _address.toLowerCase()) {

            console.log("Found facet : ",key)
            facetName = key;
            break;
        }
    }
    if(!facetName) {
        return [undefined,{}]
    }
    // get all functions
    let contract = require(`../artifacts/contracts/facets/${facetName}.sol/${facetName}.json`)
    let contractFuncAbi = contract.abi.filter(i => i.type === "function")
    let contractFuncSigMap = {}
    contractFuncAbi.map(func => {
        const b4 = web3.eth.abi.encodeFunctionSignature(func)
        const funcInputs = func.inputs.map(value=>value.type).join(",")
        console.log(b4,func.name+`(${funcInputs})`)
        _.set(contractFuncSigMap,b4,func.name+`(${funcInputs})`)
        return b4
    })
    return [facetName,contractFuncSigMap]
}

const main = async(network) => {
    const env = require(`../.${network}.env.json`);
    const mnemonic = fs.readFileSync("./.secret").toString().trim();
    
    const web3 = new Web3(Web3.givenProvider || env.rpc_endpoint);
    const account = web3.eth.accounts.privateKeyToAccount(mnemonic);
    web3.eth.accounts.wallet.add(account);

    console.log(`Reading deploy data for ${network}\n`)
    const fileName = "deploy_data_"+network+".json"
    const deployData = require("../"+fileName)

    const storeAddr = deployData.CrossDev.deployed_address
    const loupeContract = new web3.eth.Contract(DIAMOND_LOUPE.abi,storeAddr)

    const facetsResult = await loupeContract.methods.facets().call()
    deployData.facets = []
    for (let i = 0; i < facetsResult.length; i++) {
        const facet = facetsResult[i];
        const [facetName,contractFuncSigMap] = findFacetByAddress(deployData,facet.facetAddress)
        deployData.facets.push({
            facet_name : facetName? facetName : "Unknown",
            facet_address : facet.facetAddress,
            function_selectors: facet.functionSelectors.map((selector)=>{
                return {
                    selector : selector,
                    function_signature : _.get(contractFuncSigMap,selector,"Unknown")
                }
            })
        })
    }


    // Write file back
    fs.writeFileSync("./" + fileName, JSON.stringify(deployData, null, 4));
}

main(process.env.network)