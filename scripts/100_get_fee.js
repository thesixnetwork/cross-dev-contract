
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

    result = await contractSend(
        "ManagerFaucet",
        deployData.CrossDev.deployed_address,
        "setV2Router",
        [
            "0x4f9f5CC1a17E6DAd2d8DCc68308770B80Cd93E51"
        ],
        env.rpc_endpoint,
        mnemonic,
        env.from
    )
    console.log(result)

    // result = await contractCall(
    //     "UniswapFacet",
    //     deployData.CrossDev.deployed_address,
    //     "calculateFeeAndRemain",
    //     [
    //         "1000000000000000000"
    //     ],
    //     env.rpc_endpoint
    // )

    // console.log(result);


}

main(process.env.network)