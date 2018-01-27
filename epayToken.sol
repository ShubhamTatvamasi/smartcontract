pragma solidity ^0.4.16;

contract EPAY {
    // Public variables of the token
    string public name = "EthPayCash";
    string public symbol = "EPAY";
    uint256 public totalSupply = 100000;

    /* This creates an array with all balances */
    mapping (address => uint256) public balanceOf;

    // This generates a public event on the blockchain that will notify clients
    event Transfer(address indexed from, address indexed to, uint256 value);

    /* Initializes contract with initial supply tokens to the creator of the contract */
    function EPAY() public {
        balanceOf[msg.sender] = totalSupply;              // Give the creator all initial tokens
    }

    /* Send coins */
    function transfer(address _to, uint256 _value) public {
        require(balanceOf[msg.sender] >= _value);           // Check if the sender has enough
        require(balanceOf[_to] + _value >= balanceOf[_to]); // Check for overflows
        balanceOf[msg.sender] -= _value;                    // Subtract from the sender
        balanceOf[_to] += _value;                           // Add the same to the recipient
        Transfer(msg.sender, _to, _value);
    }
}
