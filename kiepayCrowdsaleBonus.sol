pragma solidity ^0.4.18;

interface token {
    function transfer(address receiver, uint amount) public;
}

contract KEPCrowdsale {

    uint256 public amountRaised;
    address private beneficiary;
    address private contractAdmin;
//  price of tokens per ether
    uint256 public price;
    token public tokenReward;
    
    event FundTransfer(address backer, uint amount, bool isContribution);

//  Constructor function 
    function KEPCrowdsale(address ifSuccessfulSendTo,
    address contractAdministrator,
    uint256 priceOfTokensPerEther,
    address addressOfTokenUsedAsReward) public {
        beneficiary = ifSuccessfulSendTo;
        contractAdmin = contractAdministrator;
        price = priceOfTokensPerEther;
        tokenReward = token(addressOfTokenUsedAsReward);
    }

//  function without name is the default function that is called whenever anyone sends funds to a contract
    function () payable private {
        uint amount = msg.value;
        amountRaised += amount;
        uint tokenAmount = amount * price;
        uint bonusAmount;

        if (amount >= 100 ether) {
            // 100 % extra tokens
            bonusAmount = tokenAmount;
            tokenReward.transfer(msg.sender, tokenAmount + bonusAmount);
        } else if (amount >= 90 ether) {
            // 90 % extra tokens
            bonusAmount = tokenAmount * 90 / 100;
            tokenReward.transfer(msg.sender, tokenAmount + bonusAmount);
        } else if (amount >= 80 ether) {
            // 80 % extra tokens
            bonusAmount = tokenAmount * 80 / 100;
            tokenReward.transfer(msg.sender, tokenAmount + bonusAmount);
        } else if (amount >= 70 ether) {
            // 70 % extra tokens
            bonusAmount = tokenAmount * 70 / 100;
            tokenReward.transfer(msg.sender, tokenAmount + bonusAmount);
        } else if (amount >= 60 ether) {
            // 60 % extra tokens
            bonusAmount = tokenAmount * 60 / 100;
            tokenReward.transfer(msg.sender, tokenAmount + bonusAmount);
        } else if (amount >= 50 ether) {
            // 50 % extra tokens
            bonusAmount = tokenAmount * 50 / 100;
            tokenReward.transfer(msg.sender, tokenAmount + bonusAmount);
        } else {
            tokenReward.transfer(msg.sender, tokenAmount);   
        }
        FundTransfer(msg.sender, amount, true);
        beneficiary.transfer(amount); // Transfer all the ethers amount to the beneficiary account
    }

    function updatePricePerToken(uint256 _newPrice) public {
        require(msg.sender == contractAdmin);
        price = _newPrice;
    }

    function closeTokenSale(uint256 _tokenAmount) public {
        require(msg.sender == contractAdmin);
        tokenReward.transfer(contractAdmin, _tokenAmount * 1 ether);
    }

}