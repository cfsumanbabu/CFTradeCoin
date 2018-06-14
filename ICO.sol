pragma solidity ^0.4.16;


library SafeMath3 {

  function mul(uint a, uint b) internal  returns (uint c) {
    c = a * b;
    assert( a == 0 || c / a == b );
  }

  function sub(uint a, uint b) internal  returns (uint) {
    assert( b <= a );
    return a - b;
  }

  function add(uint a, uint b) internal  returns (uint c) {
    c = a + b;
    assert( c >= a );
  }

}


// ----------------------------------------------------------------------------
//
// Owned contract
//
// ----------------------------------------------------------------------------

contract Owned {

  address public owner;
  address public newOwner;

  // Events ---------------------------

  event OwnershipTransferProposed(address indexed _from, address indexed _to);
  event OwnershipTransferred(address indexed _from, address indexed _to);

  // Modifier -------------------------

  modifier onlyOwner {
    require( msg.sender == owner );
    _;
  }

  // Functions ------------------------

  function Owned() {
    owner = msg.sender;
  }

  function transferOwnership(address _newOwner) onlyOwner {
    require( _newOwner != owner );
    require( _newOwner != address(0x0) );
    OwnershipTransferProposed(owner, _newOwner);
    newOwner = _newOwner;
  }

  function acceptOwnership() {
    require(msg.sender == newOwner);
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}


// ----------------------------------------------------------------------------
//
// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
//
// ----------------------------------------------------------------------------

contract ERC20Interface {

  // Events ---------------------------

  event Transfer(address indexed _from, address indexed _to, uint _value);
  event Approval(address indexed _owner, address indexed _spender, uint _value);

  // Functions ------------------------

  function totalSupply()  returns (uint);
  function balanceOf(address _owner)  returns (uint balance);
  function transfer(address _to, uint _value) returns (bool success);
  function transferFrom(address _from, address _to, uint _value) returns (bool success);
  function approve(address _spender, uint _value) returns (bool success);
  function allowance(address _owner, address _spender)  returns (uint remaining);

}


// ----------------------------------------------------------------------------
//
// ERC Token Standard #20
//
// ----------------------------------------------------------------------------

contract ERC20Token is ERC20Interface, Owned {
  
  using SafeMath3 for uint;

  uint public tokensIssuedTotal = 0;
  mapping(address => uint) balances;
  mapping(address => mapping (address => uint)) allowed;

  // Functions ------------------------

  /* Total token supply */

  function totalSupply()  returns (uint) {
    return tokensIssuedTotal;
  }

  /* Get the account balance for an address */

  function balanceOf(address _owner)  returns (uint balance) {
    return balances[_owner];
  }

  /* Transfer the balance from owner's account to another account */

  function transfer(address _to, uint _amount) returns (bool success) {
    // amount sent cannot exceed balance
    require( balances[msg.sender] >= _amount );

    // update balances
    balances[msg.sender] = balances[msg.sender].sub(_amount);
    balances[_to]        = balances[_to].add(_amount);

    // log event
    Transfer(msg.sender, _to, _amount);
    return true;
  }

  /* Allow _spender to withdraw from your account up to _amount */

  function approve(address _spender, uint _amount) returns (bool success) {
    // approval amount cannot exceed the balance
    require ( balances[msg.sender] >= _amount );
      
    // update allowed amount
    allowed[msg.sender][_spender] = _amount;
    
    // log event
    Approval(msg.sender, _spender, _amount);
    return true;
  }

  /* Spender of tokens transfers tokens from the owner's balance */
  /* Must be pre-approved by owner */

  function transferFrom(address _from, address _to, uint _amount) returns (bool success) {
    // balance checks
    require( balances[_from] >= _amount );
    require( allowed[_from][msg.sender] >= _amount );

    // update balances and allowed amount
    balances[_from]            = balances[_from].sub(_amount);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_amount);
    balances[_to]              = balances[_to].add(_amount);

    // log event
    Transfer(_from, _to, _amount);
    return true;
  }

  /* Returns the amount of tokens approved by the owner */
  /* that can be transferred by spender */

  function allowance(address _owner, address _spender)  returns (uint remaining) {
    return allowed[_owner][_spender];
  }

}



contract UserTokensControl is ERC20Token {
    address companyReserve;
    address founderReserve;
}

// ----------------------------------------------------------------------------
//
// CrowdForceTradeCoin public token sale
//
// ----------------------------------------------------------------------------

contract CrowdForceTradeCoin is ERC20Token {

  /* Utility variable */
  
  uint  E6 = 10**6;
  
  /* Basic token data */

  string public  name     = "CrowdForce Trade Coin";
  string public  symbol   = "CFTD";
  uint8  public  decimals = 6;

  /* Wallet addresses - initially set to owner at deployment */
  
  address public wallet;
  address public adminWallet;

  /* ICO dates */

  uint public  DATE_PRESALE_START = 1528740000; // 06/11/2018 @ 6:00pm (UTC)
  uint public  DATE_PRESALE_END   = 1528758000; // 06/11/2018 @ 11:00pm (UTC)

  uint public  DATE_ICO_START =1528761600 ; // 06/12/2018 @ 12:00am (UTC)
  uint public  DATE_ICO_END   = 1528920000; // 06/13/2018 @ 8:00pm (UTC)

  /* ICO tokens per ETH */
  
  uint public tokensPerEth = 500 * E6; // rate during last ICO week

  uint public  BONUS_PRESALE      = 40;
  uint public  BONUS_ICO_WEEK_ONE = 20;
  uint public  BONUS_ICO_WEEK_TWO = 10;

  /* Other ICO parameters */  
  
  uint public  TOKEN_SUPPLY_TOTAL = 300 * E6 * E6;                                       // 300 mm tokens
  uint public  TOKEN_SUPPLY_ICO   = 40 * E6 * E6;                                       // 40 mm tokens
  uint public  TOKEN_SUPPLY_Bonuses_Program   = 18 * E6  * E6;                          // 8 million tokens
  uint public  TOKEN_SUPPLY_Referrals_Program   = 7500000  * E6;                       // 7 million, 5 hundred thousand tokens
  uint public  TOKEN_SUPPLY_Funders_TechnicalTeam_Projects   = 45 * E6  * E6;           // 45 million tokens
  uint public  TOKEN_SUPPLY_RE_Projects   = 60 * E6  * E6;                             // 60 million tokens
  uint public  TOKEN_SUPPLY_Technology_Projects   = 13500000  * E6;                    // 13 million, 5 hundred thousand tokens
  uint public  TOKEN_SUPPLY_Commerce_Projects   = 13500000  * E6;                       // 13 million, 5 hundred thousand tokens
  uint public  TOKEN_SUPPLY_Art_Projects   = 13500000  * E6;                            // 13 million, 5 hundred thousand tokens
  uint public  TOKEN_SUPPLY_Turism_Projects   = 13500000  * E6;                         // 13 million, 5 hundred thousand tokens
  uint public  TOKEN_SUPPLY_Startupfinancing_Projects   = 13500000  * E6;               // 13 million, 5 hundred thousand tokens
  uint public  TOKEN_SUPPLY_Health_Projects   = 13500000  * E6;                                // 13 million, 5 hundred thousand tokens
  uint public  TOKEN_SUPPLY_Operation_Costs   =  13500000  * E6;                        // 13 million, 5 hundred thousand tokens
    uint public  TOKEN_SUPPLY_Greg_Access   =  35000000  * E6 * E6;                  // 35 million,  tokens             
    
  uint public  PRESALE_ETH_CAP =  15000 ether;

  uint public  MIN_FUNDING_GOAL =  40 * E6 * E6; // 40 mm tokens
  
  uint public  MIN_CONTRIBUTION = 1 ether / 2; // 0.5 Ether
  uint public  MAX_CONTRIBUTION = 300 ether;

  uint public  COOLDOWN_PERIOD =  2 days;
  uint public  CLAWBACK_PERIOD = 90 days;

  /* Crowdsale variables */

  uint public icoEtherReceived = 0; // Ether actually received by the contract

  uint public tokensIssuedIco   = 0;
  uint public tokensIssuedBusPrg   = 0;
  uint public tokensIssuedBounse   = 0;
  uint public tokensIssuedRerrPrg   = 0;
  uint public tokensIssuedFunderTechTeam   = 0;
  uint public tokensIssuedREProj   = 0;
  uint public tokensIssuedTechTeam   = 0;
  uint public tokensIssuedComProj   = 0;
  uint public tokensIssuedArtProj   = 0;
  uint public tokensIssuedTurismProj   = 0;
  uint public tokensIssuedOperationcost   = 0;
  uint public tokensIssuedHealthProj   = 0;
  uint public tokensIssuedStartupfinancingProj   = 0;
  uint public tokensIssuedGregAccess   = 0;
        
  uint public tokensClaimedAirdrop = 0;
    uint public tokensIssuedAsBouns = 0;
      uint public tokensIssuedAsReferal = 0;
  
  /* Keep track of Ether contributed and tokens received during Crowdsale */
  
  mapping(address => uint) public icoEtherContributed;
  mapping(address => uint) public icoTokensReceived;

  /* Keep track of participants who 
  /* - have received their airdropped tokens after a successful ICO */
  /* - or have reclaimed their contributions in case of failed Crowdsale */
  /* - are locked */
  
  mapping(address => bool) public airdropClaimed;
  mapping(address => bool) public refundClaimed;
  mapping(address => bool) public locked;

  // Events ---------------------------
  
  event WalletUpdated(address _newWallet);
  event AdminWalletUpdated(address _newAdminWallet);
  event TokensPerEthUpdated(uint _tokensPerEth);
  event TokensMinted(address indexed _owner, uint _tokens, uint _balance);
  event TokensIssued(address indexed _owner, uint _tokens, uint _balance, uint _etherContributed);
  event Refund(address indexed _owner, uint _amount, uint _tokens);
  event Airdrop(address indexed _owner, uint _amount, uint _balance);
  event LockRemoved(address indexed _participant);

  // Basic Functions ------------------

  /* Initialize (owner is set to msg.sender by Owned.Owned() */

  function CrowdForceTradeCoin() {
    require( 
 TOKEN_SUPPLY_ICO 
+TOKEN_SUPPLY_Bonuses_Program 
+TOKEN_SUPPLY_Referrals_Program  
+TOKEN_SUPPLY_Funders_TechnicalTeam_Projects   
+TOKEN_SUPPLY_RE_Projects  
+TOKEN_SUPPLY_Technology_Projects  
+TOKEN_SUPPLY_Commerce_Projects  
+TOKEN_SUPPLY_Art_Projects
+TOKEN_SUPPLY_Turism_Projects
+TOKEN_SUPPLY_Startupfinancing_Projects
+TOKEN_SUPPLY_Health_Projects  
+TOKEN_SUPPLY_Operation_Costs  
== TOKEN_SUPPLY_TOTAL 
);
    wallet = owner;
    adminWallet = owner;
  }

  /* Fallback */
  
  function () payable {
    buyTokens();
  }
  
  // Information functions ------------
  
  /* What time is it? */
  
  function atNow()  returns (uint) {
    return now;
  }
  
  /* Has the minimum threshold been reached? */
  
  function icoThresholdReached()  returns (bool thresholdReached) {
     if (tokensIssuedIco < MIN_FUNDING_GOAL) return false;
     return true;
  }  
  
  /* Are tokens transferable? */

  function isTransferable()  returns (bool transferable) {
     if ( !icoThresholdReached() ) return false;
     if ( atNow() < DATE_ICO_END + COOLDOWN_PERIOD ) return false;
     return true;
  }
  
  // Lock functions -------------------

  /* Manage locked */

  function removeLock(address _participant) {
    require( msg.sender == adminWallet || msg.sender == owner );
    locked[_participant] = false;
    LockRemoved(_participant);
  }

  function removeLockMultiple(address[] _participants) {
    require( msg.sender == adminWallet || msg.sender == owner );
    for (uint i = 0; i < _participants.length; i++) {
      locked[_participants[i]] = false;
      LockRemoved(_participants[i]);
    }
  }

  // Owner Functions ------------------
  
  /* Change the crowdsale wallet address */

  function setWallet(address _wallet) onlyOwner {
    require( _wallet != address(0x0) );
    wallet = _wallet;
    WalletUpdated(wallet);
  }

  /* Change the admin wallet address */

  function setAdminWallet(address _wallet) onlyOwner {
    require( _wallet != address(0x0) );
    adminWallet = _wallet;
    AdminWalletUpdated(adminWallet);
  }

  /* Change tokensPerEth before ICO start */
  
  function updateTokensPerEth(uint _tokensPerEth) onlyOwner {
    require( atNow() < DATE_PRESALE_START );
    tokensPerEth = _tokensPerEth;
    TokensPerEthUpdated(_tokensPerEth);
  }

  /* Minting of Funders_TechnicalTeam tokens by owner */

  function mintFunders_TechnicalTeam(address _participant, uint _tokens) onlyOwner {
    // check amount
    require( _tokens <= TOKEN_SUPPLY_Funders_TechnicalTeam_Projects.sub(tokensIssuedFunderTechTeam) );
    
    // update balances
    balances[_participant] = balances[_participant].add(_tokens);
    tokensIssuedFunderTechTeam = tokensIssuedFunderTechTeam.add(_tokens);
    tokensIssuedTotal      = tokensIssuedTotal.add(_tokens);
    
    // locked
    locked[_participant] = true;
    
    // log the miniting
    Transfer(0x0, _participant, _tokens);
    TokensMinted(_participant, _tokens, balances[_participant]);
  }
  
  
    /* Minting of RE_Projects tokens by owner */

  function mintRE_Projectsg(address _participant, uint _tokens) onlyOwner {
    // check amount
    require( _tokens <= TOKEN_SUPPLY_RE_Projects.sub(tokensIssuedREProj) );
    
    // update balances
    balances[_participant] = balances[_participant].add(_tokens);
    tokensIssuedREProj        = tokensIssuedREProj.add(_tokens);
    tokensIssuedTotal      = tokensIssuedTotal.add(_tokens);
    
    // locked
    locked[_participant] = true;
    
    // log the miniting
    Transfer(0x0, _participant, _tokens);
    TokensMinted(_participant, _tokens, balances[_participant]);
  }
  
  
    /* Minting of Technology_Projects tokens by owner */

  function mintTechnology_Projects(address _participant, uint _tokens) onlyOwner {
    // check amount
    require( _tokens <= TOKEN_SUPPLY_Technology_Projects.sub(tokensIssuedTechTeam) );
    
    // update balances
    balances[_participant] = balances[_participant].add(_tokens);
    tokensIssuedTechTeam        = tokensIssuedTechTeam.add(_tokens);
    tokensIssuedTotal      = tokensIssuedTotal.add(_tokens);
    
    // locked
    locked[_participant] = true;
    
    // log the miniting
    Transfer(0x0, _participant, _tokens);
    TokensMinted(_participant, _tokens, balances[_participant]);
  }
  
  
  
    /* Minting of Commerce_Projects tokens by owner */

  function mintCommerce_Projects(address _participant, uint _tokens) onlyOwner {
    // check amount
    require( _tokens <= TOKEN_SUPPLY_Commerce_Projects.sub(tokensIssuedComProj) );
    
    // update balances
    balances[_participant] = balances[_participant].add(_tokens);
    tokensIssuedComProj        = tokensIssuedComProj.add(_tokens);
    tokensIssuedTotal      = tokensIssuedTotal.add(_tokens);
    
    // locked
    locked[_participant] = true;
    
    // log the miniting
    Transfer(0x0, _participant, _tokens);
    TokensMinted(_participant, _tokens, balances[_participant]);
  }
  
  
    /* Minting of Art_Projects tokens by owner */

  function mintArt_Projects(address _participant, uint _tokens) onlyOwner {
    // check amount
    require( _tokens <= TOKEN_SUPPLY_Art_Projects.sub(tokensIssuedArtProj) );
    
    // update balances
    balances[_participant] = balances[_participant].add(_tokens);
    tokensIssuedArtProj        = tokensIssuedArtProj.add(_tokens);
    tokensIssuedTotal      = tokensIssuedTotal.add(_tokens);
    
    // locked
    locked[_participant] = true;
    
    // log the miniting
    Transfer(0x0, _participant, _tokens);
    TokensMinted(_participant, _tokens, balances[_participant]);
  }
  
  
    /* Minting of Turism_Projects tokens by owner */

  function mintTurism_Projects(address _participant, uint _tokens) onlyOwner {
    // check amount
    require( _tokens <= TOKEN_SUPPLY_Turism_Projects.sub(tokensIssuedTurismProj) );
    
    // update balances
    balances[_participant] = balances[_participant].add(_tokens);
    tokensIssuedTurismProj        = tokensIssuedTurismProj.add(_tokens);
    tokensIssuedTotal      = tokensIssuedTotal.add(_tokens);
    
    // locked
    locked[_participant] = true;
    
    // log the miniting
    Transfer(0x0, _participant, _tokens);
    TokensMinted(_participant, _tokens, balances[_participant]);
  }
  
  
    /* Minting of Startupfinancing_Projects tokens by owner */

  function mintStartupfinancing_Projects (address _participant, uint _tokens) onlyOwner {
    // check amount
    require( _tokens <= TOKEN_SUPPLY_Startupfinancing_Projects.sub(tokensIssuedStartupfinancingProj) );
    
    // update balances
    balances[_participant] = balances[_participant].add(_tokens);
    tokensIssuedStartupfinancingProj        = tokensIssuedStartupfinancingProj.add(_tokens);
    tokensIssuedTotal      = tokensIssuedTotal.add(_tokens);
    
    // locked
    locked[_participant] = true;
    
    // log the miniting
    Transfer(0x0, _participant, _tokens);
    TokensMinted(_participant, _tokens, balances[_participant]);
  }
  
  
    /* Minting of Health_Projects  tokens by owner */

  function mintHealth_Projects(address _participant, uint _tokens) onlyOwner {
    // check amount
    require( _tokens <= TOKEN_SUPPLY_Health_Projects.sub(tokensIssuedHealthProj) );
    
    // update balances
    balances[_participant] = balances[_participant].add(_tokens);
    tokensIssuedHealthProj        = tokensIssuedHealthProj.add(_tokens);
    tokensIssuedTotal      = tokensIssuedTotal.add(_tokens);
    
    // locked
    locked[_participant] = true;
    
    // log the miniting
    Transfer(0x0, _participant, _tokens);
    TokensMinted(_participant, _tokens, balances[_participant]);
  }
  
  
    /* Minting of Operation_Costs  tokens by owner */

  function mintOperation_Costs(address _participant, uint _tokens) onlyOwner {
    // check amount
    require( _tokens <= TOKEN_SUPPLY_Operation_Costs.sub(tokensIssuedOperationcost) );
    
    // update balances
    balances[_participant] = balances[_participant].add(_tokens);
    tokensIssuedOperationcost        = tokensIssuedOperationcost.add(_tokens);
    tokensIssuedTotal      = tokensIssuedTotal.add(_tokens);
    
    // locked
    locked[_participant] = true;
    
    // log the miniting
    Transfer(0x0, _participant, _tokens);
    TokensMinted(_participant, _tokens, balances[_participant]);
  }
  
  
  
  

  /* Owner clawback of remaining funds after clawback period */
  /* (for use in case of a failed Crwodsale) */
  
  function ownerClawback() external onlyOwner {
    require( atNow() > DATE_ICO_END + CLAWBACK_PERIOD );
    wallet.transfer(this.balance);
  }

  /* Transfer out any accidentally sent ERC20 tokens */

  function transferAnyERC20Token(address tokenAddress, uint amount) onlyOwner returns (bool success) {
      return ERC20Interface(tokenAddress).transfer(owner, amount);
  }

  // Private functions ----------------

  /* Accept ETH during crowdsale (called by default function) */

  function buyTokens() private {
    uint ts = atNow();
    bool isPresale = false;
    bool isIco = false;
    uint tokens = 0;
    
    // minimum contribution
    require( msg.value >= MIN_CONTRIBUTION );
    
    // one address transfer hard cap
    require( icoEtherContributed[msg.sender].add(msg.value) <= MAX_CONTRIBUTION );

    // check dates for presale or ICO
    if (ts > DATE_PRESALE_START && ts < DATE_PRESALE_END) isPresale = true;  
    if (ts > DATE_ICO_START && ts < DATE_ICO_END) isIco = true;  
    require( isPresale || isIco );
    
    
    uint diffInSeconds = ts - DATE_ICO_START;
        uint diffInHours = (diffInSeconds/60)/60;
        
        if(diffInHours < 1 weeks){
            //return 25;
        }

        if(diffInHours > 1 weeks && diffInHours < 1 weeks){
           // return 15;
        }

    // presale cap in Ether
    if (isPresale) require( icoEtherReceived.add(msg.value) <= PRESALE_ETH_CAP );
    
    // get baseline number of tokens
    tokens = tokensPerEth.mul(msg.value) / 1 ether;
    
    // apply bonuses (none for last week)
    if (isPresale) {
      tokens = tokens.mul(100 + BONUS_PRESALE) / 100;
      
    } else if (ts == DATE_ICO_START)
    {
      // first week ico bonus 
      
      //BONUS_PRESALE should be 5000
      //if(diffInHours < 15  days){
            //return 25;
    //    }
       

      tokens = tokens.mul(100 + BONUS_ICO_WEEK_ONE) / 100;
    } else if (ts < DATE_ICO_START + 1 days) {
      // second week ico bonus
      tokens = tokens.mul(100 + BONUS_ICO_WEEK_TWO) / 100;
    }
    
    // ICO token volume cap
    require( tokensIssuedIco.add(tokens) <= TOKEN_SUPPLY_ICO );
    
       // Bounse token volume cap
    require( tokensIssuedAsBouns.add(tokens) <= TOKEN_SUPPLY_Bonuses_Program );
    
       // ICO token volume cap
 //   require( tokensIssuedIco.add(tokens) <= TOKEN_SUPPLY_ICO );

    // register tokens
    balances[msg.sender]          = balances[msg.sender].add(tokens);
    icoTokensReceived[msg.sender] = icoTokensReceived[msg.sender].add(tokens);
    tokensIssuedIco               = tokensIssuedIco.add(tokens);
    tokensIssuedTotal             = tokensIssuedTotal.add(tokens);
    
    //Add Bounse Tokens 
      tokensIssuedAsBouns              = tokensIssuedAsBouns.add(tokens);
      
         
    //Add Refferal Tokens 
      tokensIssuedAsReferal              = tokensIssuedAsReferal.add(tokens);
      
    // register Ether
    icoEtherReceived                = icoEtherReceived.add(msg.value);
    icoEtherContributed[msg.sender] = icoEtherContributed[msg.sender].add(msg.value);
    
    // locked
    locked[msg.sender] = true;
    
    // log token issuance
    Transfer(0x0, msg.sender, tokens);
    TokensIssued(msg.sender, tokens, balances[msg.sender], msg.value);

    // transfer Ether if we're over the threshold
    if ( icoThresholdReached() ) wallet.transfer(this.balance);
  }
  
  // ERC20 functions ------------------

  /* Override "transfer" (ERC20) */

  function transfer(address _to, uint _amount) returns (bool success) {
    require( isTransferable() );
    require( locked[msg.sender] == false );
    require( locked[_to] == false );
    return super.transfer(_to, _amount);
  }
  
  /* Override "transferFrom" (ERC20) */

  function transferFrom(address _from, address _to, uint _amount) returns (bool success) {
    require( isTransferable() );
    require( locked[_from] == false );
    require( locked[_to] == false );
    return super.transferFrom(_from, _to, _amount);
  }

  // External functions ---------------

  /* Reclaiming of funds by contributors in case of a failed crowdsale */
  /* (it will fail if account is empty after ownerClawback) */

  /* While there could not have been any token transfers yet, a contributor */
  /* may have received minted tokens, so the token balance after a refund */ 
  /* may still be positive */
  
  function reclaimFunds() external {
    uint tokens; // tokens to destroy
    uint amount; // refund amount
    
    // ico is finished and was not successful
    require( atNow() > DATE_ICO_END && !icoThresholdReached() );
    
    // check if refund has already been claimed
    require( !refundClaimed[msg.sender] );
    
    // check if there is anything to refund
    require( icoEtherContributed[msg.sender] > 0 );
    
    // update variables affected by refund
    tokens = icoTokensReceived[msg.sender];
    amount = icoEtherContributed[msg.sender];

    balances[msg.sender] = balances[msg.sender].sub(tokens);
    tokensIssuedTotal    = tokensIssuedTotal.sub(tokens);
    
    refundClaimed[msg.sender] = true;
    
    // transfer out refund
    msg.sender.transfer(amount);
    
    // log
    Transfer(msg.sender, 0x0, tokens);
    Refund(msg.sender, amount, tokens);
  }

  /* Claiming of "airdropped" tokens in case of successful crowdsale */
  /* Can be done by token holder, or by adminWallet */ 

  function claimAirdrop() external {
    doAirdrop(msg.sender);
  }

  function adminClaimAirdrop(address _participant) external {
    require( msg.sender == adminWallet );
    doAirdrop(_participant);
  }

  function adminClaimAirdropMultiple(address[] _addresses) external {
    require( msg.sender == adminWallet );
    for (uint i = 0; i < _addresses.length; i++) doAirdrop(_addresses[i]);
  }  
  
  function doAirdrop(address _participant) internal {
    uint airdrop = computeAirdrop(_participant);

    require( airdrop > 0 );

    // update balances and token issue volume
    airdropClaimed[_participant] = true;
    balances[_participant] = balances[_participant].add(airdrop);
    tokensIssuedTotal      = tokensIssuedTotal.add(airdrop);
    tokensClaimedAirdrop   = tokensClaimedAirdrop.add(airdrop);
    
    // log
    Airdrop(_participant, airdrop, balances[_participant]);
    Transfer(0x0, _participant, airdrop);
  }

  /* Function to estimate airdrop amount. For some accounts, the value of */
  /* tokens received by calling claimAirdrop() may be less than gas costs */
  
  /* If an account has tokens from the ico, the amount after the airdrop */
  /* will be newBalance = tokens * TOKEN_SUPPLY_ICO / tokensIssuedIco */
      
  function computeAirdrop(address _participant)  returns (uint airdrop) {
    // return 0 if it's too early or ico was not successful
    if ( atNow() < DATE_ICO_END || !icoThresholdReached() ) return 0;
    
    // return  0 is the airdrop was already claimed
    if( airdropClaimed[_participant] ) return 0;

    // return 0 if the account does not hold any crowdsale tokens
    if( icoTokensReceived[_participant] == 0 ) return 0;
    
    // airdrop amount
    uint tokens = icoTokensReceived[_participant];
    uint newBalance = tokens.mul(TOKEN_SUPPLY_ICO) / tokensIssuedIco;
    airdrop = newBalance - tokens;
  }  

  /* Multiple token transfers from one address to save gas */
  /* (longer _amounts array not accepted = sanity check) */

  function transferMultiple(address[] _addresses, uint[] _amounts) external {
    require( isTransferable() );
    require( locked[msg.sender] == false );
    require( _addresses.length == _amounts.length );
    for (uint i = 0; i < _addresses.length; i++) {
      if (locked[_addresses[i]] == false) super.transfer(_addresses[i], _amounts[i]);
    }
  }  

}
