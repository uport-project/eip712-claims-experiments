pragma solidity >=0.5.3 <0.6.0;
pragma experimental ABIEncoderV2;
import "./AbstractClaimsVerifier.sol";
import "./claimTypes/IdentityClaimTypes.sol";

contract IdentityClaimsVerifier is AbstractClaimsVerifier, IdentityClaimTypes {

  constructor (address _registryAddress, address _revocations) 
  AbstractClaimsVerifier(
    "EIP712IdentityClaims",
    "1",
    1,
    address(this),
    _registryAddress,
    _revocations
  ) public {}

  function verify(VerifiedIdentity memory claim, uint8 v, bytes32 r, bytes32 s) public view returns (bool) {
    bytes32 digest = keccak256(
      abi.encodePacked(
        "\x19\x01",
        DOMAIN_SEPARATOR,
        hash(claim)
      )
    );
    return verifyIssuer(digest, claim.issuer, claim.subject, v, r, s) && valid(claim.validFrom, claim.validTo);
  }

  function verify(VerifiedResident memory claim, uint8 v, bytes32 r, bytes32 s) public view returns (bool) {
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