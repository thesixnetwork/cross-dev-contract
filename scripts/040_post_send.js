const fs = require("fs");
const _ = require('lodash');
const Web3 = require("web3")

const { contractSend } = require("../lib/contract")

const _loadValue = (_value, _key) => {
    switch (typeof _key) {
      case "string":
        return _.get(_value, _key);
      case "object":
        const returnObject = {};
        for (let i = 0; i < Object.keys(_key).length; i++) {
          const key = Object.keys(_key)[i];
          returnObject[key] = _.get(_value, _key[key]);
        }
        return returnObject;
      default:
        break;
    }
  };

const main = async(network) => {
    const env = require(`../.${network}.env.json`);
    const mnemonic = fs.readFileSync("./.secret").toString().trim();
    
    const web3 = new Web3(Web3.givenProvider || env.rpc_endpoint);
    const account = web3.eth.accounts.privateKeyToAccount(mnemonic);
    web3.eth.accounts.wallet.add(account);

    console.log(`Reading deploy data for ${network}\n`)
    const fileName = "deploy_data_"+network+".json"
    const deployData = require("../"+fileName)

    for (let i = 0; i < deployData.post_send.length; i++) {
        const call = deployData.post_send[i];
        if(call.initialized) {
            console.log("Already initialized.")
        }else {
            let params = call.params.map(value=>_loadValue(deployData,value))
            // call.params.map(value=>_.get(deployData,value))
          console.log("facet_name", call.facet_name,"function_name",call.function_name,"params",params)
            const result = await contractSend(
                call.facet_name,
                _.get(deployData,call.address),
                call.function_name,
                params,
                env.rpc_endpoint,
                mnemonic,
                env.from
            )
            if(result.status) {
                console.log("OK")
                call.initialized = true;
                // Write file back
                fs.writeFileSync("./" + fileName, JSON.stringify(deployData, null, 4));
            }
        }
    }
}

main(process.env.network)