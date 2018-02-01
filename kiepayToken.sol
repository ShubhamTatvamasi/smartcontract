pragma solidity ^0.4.18;

contract kiepayToken {
    // Public variables of the token
    string public name = "Kiepay";
    string public symbol = "KEP";
    uint8 public decimals = 18;
    uint256 public totalSupply = 3000000000 * 1 ether; // 3 billion; 3,000,000,000

    /* This creates an array with all balances */
    mapping (address => uint256) public balanceOf;

    // This generates a public event on the blockchain that will notify clients
    event Transfer(address indexed from, address indexed to, uint256 value);

    /* Initializes contract with initial supply tokens to the creator of the contract */
    function kiepayToken() public {
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