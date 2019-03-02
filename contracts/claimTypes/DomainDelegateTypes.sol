pragma solidity >=0.5.3 <0.6.0;

contract DomainDelegateTypes {

  struct DomainDelegate {
    address issuer;
    address subject;
    bytes32 domain;
    bytes32 type_hash;
    uint256 validFrom;
    uint256 validTo;
  }

  bytes32 constant DOMAIN_DELEGATE_TYPEHASH = keccak256(
    "DomainDelegate(address issuer, address subject, bytes32 domain, bytes32 type_hash, uint256 validFrom, uint256 validTo)"
  );
  
}
