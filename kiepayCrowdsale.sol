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
    mapping(address => uint256) public balanceOf;
   
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
        balanceOf[msg.sender] += amount;
        amountRaised += amount;
        tokenReward.transfer(msg.sender, amount * price);
        FundTransfer(msg.sender, amount, true);
        beneficiary.transfer(amount); // Transfer all the ethers amount to the beneficiary account
    }

    function updatePricePerToken(uint256 _newPrice) public {
        require(msg.sender == contractAdmin);
        price = _newPrice;
    }

}