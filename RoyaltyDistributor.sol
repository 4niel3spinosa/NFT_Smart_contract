// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0;

contract RoyaltyDistributor {

    address public royaltyDistributorAdd;
    address public admin;

    address public nftHolder;
    uint256 public weeklyAmount;

    uint256 public percentageDistribute = 95;

    constructor() {
        admin = msg.sender;

    }

    receive() external payable {}

    // ========== MODIFIERS ==========

    modifier onlyOwner() {
        require(msg.sender == admin, "Ownable: caller is not the owner");
        _;
    }

    // ========== SETTERS ========== 

    function setPercentageDistribute(uint256 _percentage) public onlyOwner {
        percentageDistribute = _percentage;
    }

    // ========== FUNCTIONS ========== 

    function sendRewardsNFTHolders() public onlyOwner {
        
        uint256 numHolders;

        (bool succes_holder, ) = payable(nftHolder).call{
            value: (weeklyAmount * percentageDistribute) / 100
        }("");
        require(succes_holder, "Could not transfer funds to developpers.");
    }


}
