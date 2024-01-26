
const fs = require("fs");
const _ = require('lodash');

const { contractSend, contractCall } = require("../lib/contract")
const Web3 = require("web3");

const main = async (network) => {
    const env = require(`../.${network}.env.json`);
    const mnemonic = fs.readFileSync("./.secret").toString().trim();

    const web3 = new Web3(Web3.givenProvider || env.rpc_endpoint);
    const account = web3.eth.accounts.privateKeyToAccount(mnemonic);
    web3.eth.accounts.wallet.add(account);

    console.log(`Reading deploy data for ${network}\n`)
    const fileName = "deploy_data_" + network + ".json"
    const deployData = require("../" + fileName)

    let result

    // result = await contractSend(
    //     "AccessFacet",
    //     deployData.NFTStore.deployed_address,
    //     "setAddressForRole",
    //     [
    //         "ITEM.ADMIN",
    //         "0xED350352eb3C509D0D8A70aE0BC01B173EbA41D7"
    //     ],
    //     env.rpc_endpoint,
    //     mnemonic,
    //     env.from
    // )
    // console.log(result)

    result = await contractCall(
        "UniswapFacet",
        deployData.CrossDev.deployed_address,
        "calculateFeeAndRemain",
        [
            "1000000000000000000"
        ],
        env.rpc_endpoint
    )

    console.log(result);


}

main(process.env.network)