network=mainnet_base

# Initialize variables with default values
deploy=false

# Parse command-line options manually
while [ $# -gt 0 ]; do
  case "$1" in
    --deploy)
      shift
      if [ "$1" == "true" ]; then
        deploy=true
      elif [ "$1" == "false" ]; then
        deploy=false
      else
        echo "Invalid value for --deploy: $1"
        exit 1
      fi
      shift
      ;;
    *)
      echo "Invalid option: $1"
      exit 1
      ;;
  esac
done

# Check the value of the deploy flag
if [ "$deploy" = true ]; then
  echo "Deploying..."
  
  # Clean all deployment data
  network=$network npx hardhat run scripts/000_reset_deploy.js

  # Deploy all Contract
  network=$network npx hardhat run --network $network scripts/001_deploy_contract.js

  # network=testnet_blast npx hardhat run --network testnet_blast scripts/100_get_fee.js

  # Initialize cuts
  network=$network npx hardhat run scripts/010_initial_cuts.js
fi

: <<'DIAMOND_CUT_ACTION_COMMENT'
This script is for action to existing cut
Add = 0, Replace = 1, and Remove = 2

# network=$network facetName="OwnershipFacet" _action=0 npx hardhat run scripts/020_cut_diamond.js
# network=$network facetName="DiamondLoupeFacet" _action=0 npx hardhat run scripts/020_cut_diamond.js
# network=$network facetName="AccessFacet" _action=0 npx hardhat run scripts/020_cut_diamond.js
# network=$network facetName="ManagerFacet" _action=0 npx hardhat run scripts/020_cut_diamond.js
# network=$network facetName="UniswapFacet" _action=0 npx hardhat run scripts/020_cut_diamond.js
DIAMOND_CUT_ACTION_COMMENT

# Get facets function bytes
network=$network npx hardhat run scripts/030_load_facets.js

if [ "$deploy" = true ]; then
  network=$network npx hardhat run scripts/040_post_send.js
fi


# Verify facets function has been added
network=$network facetName="OwnershipFacet" _action=0 npx hardhat run scripts/050_merge_cut.js
network=$network facetName="DiamondLoupeFacet" _action=0 npx hardhat run scripts/050_merge_cut.js
network=$network facetName="AccessFacet" _action=0 npx hardhat run scripts/050_merge_cut.js
network=$network facetName="ManagerFacet" _action=0 npx hardhat run scripts/050_merge_cut.js
network=$network facetName="UniswapFacet" _action=0 npx hardhat run scripts/050_merge_cut.js