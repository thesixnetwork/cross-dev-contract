const _ = require("lodash")
const fs = require('fs');
const hardhat = require("hardhat");

const _isDeployed  = (_contractConfig) => {
  if(_contractConfig.deployed_address && _contractConfig.deployed_address.length >0 ) {
    return true
  }
  return false
}

const _deploy = async (deployData,_deployConfig) => {
  
  if(!_isDeployed(_deployConfig)) {
    console.log("_deployConfig",_deployConfig)
    const _arguments = _deployConfig.deploy.arguments.map( key => {
      console.log("key",key)
      return _.get(deployData,key)
    })
    const contract = await hardhat.ethers.getContractFactory(_deployConfig.deploy.artifact);
    console.log(_deployConfig.deploy.artifact, ..._arguments)
    const c = await contract.deploy(..._arguments);
    await c.waitForDeployment();
    console.log(`Deployed ${_deployConfig.deploy.artifact} contract to: ${c.target}`);
    
    _deployConfig.deployed_address = c.target
  }else {
    console.log(_deployConfig.deploy.artifact)
    const contract = await hardhat.ethers.getContractFactory(_deployConfig.deploy.artifact);
  }
}

const main = async (network) => {
    const fileName = "deploy_data_"+network+".json"
    const deployData = require("../"+fileName)

    // Deploy All facets
    for (let i = 0; i < Object.keys(deployData).length; i++) {
        const facetName = Object.keys(deployData)[i];
        if(_.get(deployData,facetName+".is_facet",false)){
        const facet = _.get(deployData,facetName)
        await _deploy(deployData, facet)
        fs.writeFileSync("./"+fileName, JSON.stringify(deployData,null,4));
        }
    
    }

    // Deploy NFTStore
    const contract = await hardhat.ethers.getContractFactory(deployData.CrossDev.deploy.artifact);
    const _arguments = deployData.CrossDev.deploy.arguments.map( key => {
        console.log("key",key)
        return _.get(deployData,key)
      })
    const c = await contract.deploy(..._arguments);
    await c.waitForDeployment();
    console.log(`Deployed ${deployData.CrossDev.deploy.artifact} contract to: ${c.target}`);
    deployData.CrossDev.deployed_address = c.target;


    // First time sync
    fs.writeFileSync("./"+fileName, JSON.stringify(deployData,null,4));

}

main(process.env.network);