// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol"; // Import the ERC20 contract
import "@openzeppelin/contracts/access/Ownable.sol";

// Define the ERC20Token contract
contract ERC20Token is ERC20 {
    constructor() ERC20("Story", "LUV") {
        _mint(msg.sender, 1000000 * (10**uint256(decimals())));
    }
}

contract Vendor is Ownable {
    ERC20Token private theon; // Update this to use your actual ERC20Token contract
    uint256 public tokensPerMatic = 100;
    event BuyTokens(
        address buyer,
        uint256 amountOfMATIC,
        uint256 amountOfTokens
    );

    constructor() {
        // Deploy and initialize your ERC20Token contract
        theon = new ERC20Token();
    }

    function buyTokens() public payable returns (uint256 tokenAmount) {
        require(msg.value > 0, "You need to send some MATIC to proceed");
        uint256 amountToBuy = msg.value * tokensPerMatic;

        uint256 vendorBalance = theon.balanceOf(address(this));
        require(vendorBalance >= amountToBuy, "Vendor has insufficient tokens");

        bool sent = theon.transfer(msg.sender, amountToBuy);
        require(sent, "Failed to transfer token to user");

        emit BuyTokens(msg.sender, msg.value, amountToBuy);
        return amountToBuy;
    }

    function sellTokens(uint256 tokenAmountToSell) public {
        require(
            tokenAmountToSell > 0,
            "Specify an amount of token greater than zero"
        );

        uint256 userBalance = theon.balanceOf(msg.sender);
        require(
            userBalance >= tokenAmountToSell,
            "You have insufficient tokens"
        );

        uint256 amountOfMATICToTransfer = tokenAmountToSell / tokensPerMatic;
        uint256 ownerMATICBalance = address(this).balance;
        require(
            ownerMATICBalance >= amountOfMATICToTransfer,
            "Vendor has insufficient funds"
        );
        bool sent = theon.transferFrom(
            msg.sender,
            address(this),
            tokenAmountToSell
        );
        require(sent, "Failed to transfer tokens from user to vendor");

        (sent, ) = msg.sender.call{value: amountOfMATICToTransfer}("");
        require(sent, "Failed to send MATIC to the user");
    }

    function withdraw() public onlyOwner {
        uint256 ownerBalance = address(this).balance;
        require(ownerBalance > 0, "No MATIC present in Vendor");
        (bool sent, ) = msg.sender.call{value: address(this).balance}("");
        require(sent, "Failed to withdraw");
    }
}
