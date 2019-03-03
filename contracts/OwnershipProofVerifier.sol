pragma solidity >=0.5.3 <0.6.0;
pragma experimental ABIEncoderV2;
import "./AbstractClaimsVerifier.sol";
import "./claimTypes/OwnershipProofTypes.sol";

contract OwnershipProofVerifier is AbstractClaimsVerifier, OwnershipProofTypes {

  constructor (address _registryAddress, address _revocations) 
  AbstractClaimsVerifier(
    "EIP712IdentityClaims",
    "1",
    1,
    address(this),
    _registryAddress,
    _revocations
  ) public {}

  function ownedAddress(OwnershipProof memory claim, uint8 v, bytes32 r, bytes32 s) public view returns (address) {
    bytes32 digest = keccak256(
      abi.encodePacked(
        "\x19\x01",
        DOMAIN_SEPARATOR,
        hash(claim)
      )
    );
    require(valid(claim.validFrom, claim.validTo), "invalid issuance timestamps");
    address issuer = ecrecover(digest, v, r, s);
    require(!revocations.revoked(issuer, digest), "claim was revoked by issuer");
    require(!revocations.revoked(claim.subject, digest), "claim was revoked subject");
    return issuer;
  }

  function verify(ContractOwnershipProof memory claim, uint8 v, bytes32 r, bytes32 s) public view returns (bool) {
    bytes32 digest = keccak256(
      abi.encodePacked(
        "\x19\x01",
        DOMAIN_SEPARATOR,
        hash(claim)
      )
    );
    return verifyIssuer(digest, claim.issuer, claim.subject, v, r, s) && valid(claim.validFrom, claim.validTo);
  }

}