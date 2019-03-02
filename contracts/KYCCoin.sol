pragma solidity >=0.5.3 <0.6.0;
pragma experimental ABIEncoderV2;
import "./claimTypes/IdentityClaimTypes.sol";
import "./claimTypes/OwnershipProofTypes.sol";
import "./IdentityClaimsVerifier.sol";
import "./OwnershipProofVerifier.sol";

contract KYCCoin is IdentityClaimTypes, OwnershipProofTypes {
  address owner;
  IdentityClaimsVerifier idVerifier;
  OwnershipProofVerifier ownershipVerifier;

  mapping (address => uint) balances;
  mapping (address => uint) verifiers;
  mapping (address => uint) whitelist;

  event Transfer(address indexed _from, address indexed _to, uint256 _value);

  modifier onlyOwner {
    require(
      msg.sender == owner, "Only owner can call this function."
    );
    _;
  }

  modifier onlyWhitelisted {
    require(
      whitelist[msg.sender] > 0, "Only whitelisted users can call this function."
    );
    _;
  }

  constructor(address _idVerifier, address _ownershipVerifier) public {
    owner = msg.sender;
    idVerifier = IdentityClaimsVerifier(_idVerifier);
    ownershipVerifier = OwnershipProofVerifier(_ownershipVerifier);
    balances[msg.sender] = 10000;
    whitelist[msg.sender] = block.number;
  }

  function authorizeVerifier(address verifier) external onlyOwner {
    verifiers[verifier] = block.number;
  }

  function deauthorizeVerifier(address verifier) external onlyOwner {
    verifiers[verifier] = 0;
  }

  function authorize(VerifiedIdentity memory claim, uint8 v, bytes32 r, bytes32 s) public returns (bool) {
    require(idVerifier.verify(claim, v, r, s), "Could not Verify Identity Claim");
    require(verifiers[claim.issuer] > 0, "Issuer of claim is not Trusted");
    require(claim.loa >= 2, "Level of Assurance is required to be 2 or above");
    whitelist[claim.subject] = block.number;
    return true;
  }

  function authorize(OwnershipProof memory claim, uint8 v, bytes32 r, bytes32 s) public onlyWhitelisted returns (bool) {
    require(claim.subject == msg.sender, "Level of Assurance is required to be 2 or above");
    whitelist[ownershipVerifier.ownedAddress(claim, v, r, s)] = block.number;
    return true;
  }

  function sendCoin(address receiver, uint amount) public onlyWhitelisted returns(bool sufficient) {
    require(
      whitelist[receiver] > 0, "Only whitelisted users can receive tokens"
    );
    if (balances[msg.sender] < amount) return false;
    balances[msg.sender] -= amount;
    balances[receiver] += amount;
    emit Transfer(msg.sender, receiver, amount);
    return true;
  }

  function getBalance(address addr) public view returns(uint) {
    return balances[addr];
  }
}
