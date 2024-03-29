// Copyright ZTips 2018
pragma solidity ^0.4.18;

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes32 _extraData) external; }

contract SafeMath {
     function safeMul(uint a, uint b) internal pure returns (uint) {
          uint c = a * b;
          assert(a == 0 || c / a == b);
          return c;
     }

     function safeSub(uint a, uint b) internal pure returns (uint) {
          assert(b <= a);
          return a - b;
     }

     function safeAdd(uint a, uint b) internal pure returns (uint) {
          uint c = a + b;
          assert(c>=a && c>=b);
          return c;
     }
}

// Standard token interface (ERC 20)
// https://github.com/ethereum/EIPs/issues/20
contract Token is SafeMath {
     // Functions:
     /// @return total amount of tokens
     function totalSupply() public constant returns (uint256 supply);

     /// @param _owner The address from which the balance will be retrieved
     /// @return The balance
     function balanceOf(address _owner) public constant returns (uint256 balance);

     /// @notice send `_value` token to `_to` from `msg.sender`
     /// @param _to The address of the recipient
     /// @param _value The amount of token to be transferred
     function transfer(address _to, uint256 _value) public returns(bool);

     /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
     /// @param _from The address of the sender
     /// @param _to The address of the recipient
     /// @param _value The amount of token to be transferred
     /// @return Whether the transfer was successful or not
     function transferFrom(address _from, address _to, uint256 _value) public returns(bool);

     /// @notice `msg.sender` approves `_addr` to spend `_value` tokens
     /// @param _spender The address of the account able to transfer the tokens
     /// @param _value The amount of wei to be approved for transfer
     /// @return Whether the approval was successful or not
     function approve(address _spender, uint256 _value) public returns (bool success);

     /// @param _owner The address of the account owning tokens
     /// @param _spender The address of the account able to transfer the tokens
     /// @return Amount of remaining tokens allowed to spent
     function allowance(address _owner, address _spender) public constant returns (uint256 remaining);

     // Events:
     event Transfer(address indexed _from, address indexed _to, uint256 _value);
     event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract StdToken is Token {
     // Fields:
     mapping(address => uint256) balances;
     mapping (address => mapping (address => uint256)) allowed;
     uint public supply = 0;

     // Functions:
     
     function transfer(address _to, uint256 _value) public returns(bool) {
          require(balances[msg.sender] >= _value);
          require(balances[_to] + _value > balances[_to]);

          balances[msg.sender] = safeSub(balances[msg.sender],_value);
          balances[_to] = safeAdd(balances[_to],_value);
          
          Transfer(msg.sender, _to, _value);
          return true;
     }

     function transferFrom(address _from, address _to, uint256 _value) public returns(bool){
          require(balances[_from] >= _value);
          require(allowed[_from][msg.sender] >= _value);
          require(balances[_to] + _value > balances[_to]);

          balances[_to] = safeAdd(balances[_to],_value);
          balances[_from] = safeSub(balances[_from],_value);
          allowed[_from][msg.sender] = safeSub(allowed[_from][msg.sender],_value);
          
          Transfer(_from, _to, _value);
          return true;
     }

    function approveAndCall(address _spender, uint256 _value, bytes32 _extraData) public returns (bool) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }

     function totalSupply() public constant returns (uint256) {
          return supply;
     }

     function balanceOf(address _owner) public constant returns (uint256) {
          return balances[_owner];
     }

     function approve(address _spender, uint256 _value) public returns (bool) {
          //  To change the approve amount you first have to reduce the addresses`
          //  allowance to zero by calling `approve(_spender, 0)` if it is not
          //  alr`eady 0 to mitigate the race condition described here:
          //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
          require((_value == 0) || (allowed[msg.sender][_spender] == 0));

          allowed[msg.sender][_spender] = _value;
          Approval(msg.sender, _spender, _value);

          return true;
     }

     function allowance(address _owner, address _spender) public constant returns (uint256) {
          return allowed[_owner][_spender];
     }
}

contract ZTipsToken is StdToken
{
/// Fields:
    string public constant name = "ZTips Token";
    string public constant symbol = "ZTPS";
    uint public constant decimals = 18;

    // 880 Million Total Supply 
    uint public constant TOTAL_SUPPLY = 880000000 * (1 ether / 1 wei);
    uint public constant DEVELOPERS_BONUS = 220000000 * (1 ether / 1 wei);
    uint public constant BOUNTY_CAMPAIGNS_TOKENS = 44000000 * (1 ether / 1 wei);

    // 308 Million - Activity Mining Token Supply Limit
    uint public constant ACTIVITY_MINING_TOKEN_SUPPLY_LIMIT = 308000000 * (1 ether / 1 wei);

    uint public constant PREICO_PRICE = 11000;  // per 1 Ether
    
    // 44 Million tokens sold during preICO
    uint public constant PREICO_TOKEN_SUPPLY_LIMIT = 44000000 * (1 ether / 1 wei);
    
    uint public constant ICO_PRICE1 = 10560;     // per 1 Ether
    uint public constant ICO_PRICE2 = 9680;     // per 1 Ether
    uint public constant ICO_PRICE3 = 9240;     // per 1 Ether
    uint public constant ICO_PRICE4 = 8800;     // per 1 Ether

    // 308 Million - this includes pre-ICO tokens
    uint public constant TOTAL_SOLD_TOKEN_SUPPLY_LIMIT = 308000000 * (1 ether / 1 wei);

    enum State{
       Init,
       Paused,

       PreICORunning,
       PreICOFinished,

       ICORunning,
       ICOFinished
    }

    State public currentState = State.Init;
    bool public enableTransfers = false;

    address public teamTokenBonus = 0;
    address public activityMiningTokens = 0;
    address public bountyCampaignsTokens = 0;

    // Gathered funds can be withdrawn only to escrow's address.
    address public escrow = 0;

    // Token manager has exclusive priveleges to call administrative
    // functions on this contract.
    address private tokenManager = 0;
    address private ztipsContractAddress = 0;

    uint public preICOSoldTokens = 0;
    uint public icoSoldTokens = 0;
    uint public totalSoldTokens = 0;

    uint public totalMinedTokens = 0;


/// Modifiers:
    modifier onlyTokenManager()
    {
        require(msg.sender==tokenManager); 
        _; 
    }

    modifier onlyInState(State state)
    {
        require(state==currentState); 
        _; 
    }

/// Events:
    event LogBuy(address indexed owner, uint value);

/// Functions:

    /// @dev Constructor
    /// @param _tokenManager Token manager address.
    function ZTipsToken(
        address _tokenManager,
        address _escrow,
        address _teamTokenBonus,
        address _activityMiningTokens,
        address _bountyCampaignsTokens) public
    {
        tokenManager = _tokenManager;
        escrow = _escrow;
        teamTokenBonus = _teamTokenBonus;
        activityMiningTokens = _activityMiningTokens;
        bountyCampaignsTokens = _bountyCampaignsTokens;

        // send team bonus immediately
        uint teamBonus = DEVELOPERS_BONUS;
        uint bountyCampaigns = BOUNTY_CAMPAIGNS_TOKENS;

        balances[_teamTokenBonus] += teamBonus;
        balances[_bountyCampaignsTokens] += bountyCampaigns;

        supply += (teamBonus + bountyCampaigns);

        assert(PREICO_TOKEN_SUPPLY_LIMIT==44000000 * (1 ether / 1 wei));
        assert(TOTAL_SOLD_TOKEN_SUPPLY_LIMIT==308000000 * (1 ether / 1 wei));
    }

    function buyTokens() public payable
    {         
        require(currentState==State.PreICORunning || currentState==State.ICORunning);

        if(currentState==State.PreICORunning){
            return buyTokensPreICO();
        }else{
            return buyTokensICO();
        }
    }

    function buyTokensPreICO() public payable onlyInState(State.PreICORunning)
    {
        uint newTokens = msg.value * PREICO_PRICE;

        require(preICOSoldTokens + newTokens <= PREICO_TOKEN_SUPPLY_LIMIT);

        balances[msg.sender] += newTokens;
        supply+= newTokens;
        preICOSoldTokens+= newTokens;
        totalSoldTokens+= newTokens;

        LogBuy(msg.sender, newTokens);
    }


    function buyTokensICO() public payable onlyInState(State.ICORunning)
    {
        uint newTokens = msg.value * getPrice();

        require(totalSoldTokens + newTokens <= TOTAL_SOLD_TOKEN_SUPPLY_LIMIT);

        balances[msg.sender] += newTokens;
        supply+= newTokens;
        icoSoldTokens+= newTokens;
        totalSoldTokens+= newTokens;

        LogBuy(msg.sender, newTokens);
    }

    function getPrice() public constant returns(uint)
    {
        if(currentState==State.ICORunning){
             if(icoSoldTokens<(66000000 * (1 ether / 1 wei))){
                  return ICO_PRICE1;
             }
             if(icoSoldTokens<(132000000 * (1 ether / 1 wei))){
                  return ICO_PRICE2;
             }
             if(icoSoldTokens<(198000000 * (1 ether / 1 wei))){
                  return ICO_PRICE3;
             }
             return ICO_PRICE4;

        } else {
             return PREICO_PRICE;
        } 

    }

    function setState(State _nextState) public onlyTokenManager
    {
        //setState() method call shouldn't be entertained after ICOFinished
        require(currentState != State.ICOFinished);
        
        currentState = _nextState;
        // enable/disable transfers
        //enable transfers only after ICOFinished, disable otherwise
        enableTransfers = (currentState==State.ICOFinished);
    }

    function withdrawEther() public onlyTokenManager
    {
        if(this.balance > 0) 
        {
            require(escrow.send(this.balance));
        }
    }



    function releaseNewActivityMiningTokens() public
    {
        require(msg.sender == ztipsContractAddress);
        require(totalMinedTokens < ACTIVITY_MINING_TOKEN_SUPPLY_LIMIT);
        
        uint newTokens;

        if (totalMinedTokens < (30800000 * (1 ether / 1 wei))) {
            newTokens = 1000 * (1 ether / 1 wei);
        } else if (totalMinedTokens < (61600000 * (1 ether / 1 wei))) {
            newTokens = 800 * (1 ether / 1 wei);
        } else if (totalMinedTokens < (92400000 * (1 ether / 1 wei))) {
            newTokens = 500 * (1 ether / 1 wei);
        } else if (totalMinedTokens < (123200000 * (1 ether / 1 wei))) {
            newTokens = 400 * (1 ether / 1 wei);
        } else if (totalMinedTokens < (154000000 * (1 ether / 1 wei))) {
            newTokens = 200 * (1 ether / 1 wei);
        } else if (totalMinedTokens < (184800000 * (1 ether / 1 wei))) {
            newTokens = 100 * (1 ether / 1 wei);
        } else if (totalMinedTokens < (215600000 * (1 ether / 1 wei))) {
            newTokens = 80 * (1 ether / 1 wei);
        } else if (totalMinedTokens < (246400000 * (1 ether / 1 wei))) {
            newTokens = 50 * (1 ether / 1 wei);
        } else if (totalMinedTokens < (277200000 * (1 ether / 1 wei))) {
            newTokens = 40 * (1 ether / 1 wei);
        } else if (totalMinedTokens < (308000000 * (1 ether / 1 wei))) {
            newTokens = 20 * (1 ether / 1 wei);
        }

        balances[activityMiningTokens] += newTokens;
        supply += newTokens;
        totalMinedTokens += newTokens;
        
    }

/// Overrides:
    function transfer(address _to, uint256 _value) public returns(bool){
        require(enableTransfers);
        return super.transfer(_to,_value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns(bool){
        require(enableTransfers);
        return super.transferFrom(_from,_to,_value);
    }

    function approve(address _spender, uint256 _value) public returns (bool) {
        require(enableTransfers);
        return super.approve(_spender,_value);
    }

    function approveAndCall(address _spender, uint256 _value, bytes32 _extraData) public returns (bool) {
        require(enableTransfers);
        return super.approveAndCall(_spender, _value, _extraData);
    }

/// Setters/getters
    function setTokenManager(address _mgr) public onlyTokenManager
    {
        tokenManager = _mgr;
    }

    function setZtipsContractAddress(address _ztipsContractAddress) public onlyTokenManager
    {
        ztipsContractAddress = _ztipsContractAddress;
    }

    // Default fallback function
    function() internal payable 
    {
        buyTokens();
    }
}
