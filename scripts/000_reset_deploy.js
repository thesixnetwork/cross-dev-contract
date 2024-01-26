const fs = require("fs");
const _ = require('lodash');


const main = async(network) => {

    console.log(`Reading deploy data for ${network}\n`)
    const fileName = "deploy_data_"+network+".json"
    const deployData = require("../"+fileName)

    for (let i = 0; i < Object.keys(deployData).length; i++) {
        const key = Object.keys(deployData)[i];
        if(_.get(deployData,key+".deployed_address","").length > 0) {
            _.set(deployData,key+".deployed_address","")
        }

        if(_.get(deployData,key+".initialized",false)) {
            _.set(deployData,key+".initialized",false)
        }
    }

    for (let i = 0; i < deployData.post_send.length; i++) {
        const sending = deployData.post_send[i];
        if(_.get(sending,"initialized",false)) {
            _.set(sending,"initialized",false)
        }
    }

    _.set(deployData,"Bridge.deployed_address","")
    _.set(deployData,"facets",[])

    // Write file back
    fs.writeFileSync("./" + fileName, JSON.stringify(deployData, null, 4));
}

main(process.env.network)