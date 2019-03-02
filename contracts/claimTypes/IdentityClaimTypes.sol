pragma solidity >=0.5.3 <0.6.0;

contract IdentityClaimTypes {
  struct VerifiedIdentity {
    address issuer;
    address subject;
    uint8 loa;
    uint256 validFrom;
    uint256 validTo;
  }

  struct VerifiedResident {
    address issuer;
    address subject;
    bytes2 country;
    uint8 loa;
    uint256 validFrom;
    uint256 validTo;
  }

  bytes32 constant VERIFIED_IDENTITY_TYPEHASH = keccak256(
    "VerifiedIdentity(address issuer, address subject, uint8 loa, uint256 validFrom, uint256 validTo)"
  );

  bytes32 constant VERIFIED_RESIDENT_TYPEHASH = keccak256(
    "VerifiedResident(address issuer, address subject, bytes2 country, uint8 loa, uint256 validFrom, uint256 validTo)"
  );
}