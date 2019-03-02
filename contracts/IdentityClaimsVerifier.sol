pragma solidity >=0.5.3 <0.6.0;
pragma experimental ABIEncoderV2;
import "./AbstractClaimsVerifier.sol";
import "./claimTypes/IdentityClaimTypes.sol";

contract IdentityClaimsVerifier is AbstractClaimsVerifier, IdentityClaimTypes {

  constructor (address _registryAddress) AbstractClaimsVerifier("EIP712IdentityClaims", "1", 1, address(this), _registryAddress) public {}

  function hash(VerifiedIdentity memory claim) internal pure returns (bytes32) {
    return keccak256(
      abi.encode(
        VERIFIED_IDENTITY_TYPEHASH,
        claim.issuer,
        claim.subject,
        claim.loa,
        claim.validFrom,
        claim.validTo
      )
    );
  }

  function hash(VerifiedResident memory claim) internal pure returns (bytes32) {
    return keccak256(
      abi.encode(
        VERIFIED_RESIDENT_TYPEHASH,
        claim.issuer,
        claim.subject,
        claim.country,
        claim.loa,
        claim.validFrom,
        claim.validTo
      )
    );
  }

  function verify(VerifiedIdentity memory claim, uint8 v, bytes32 r, bytes32 s) public view returns (bool) {
    bytes32 digest = keccak256(
      abi.encodePacked(
        "\x19\x01",
        DOMAIN_SEPARATOR,
        hash(claim)
      )
    );
    return verifyIssuer(digest, claim.issuer, v, r, s) && valid(claim.validFrom, claim.validTo);
  }


  function verify(VerifiedResident memory claim, uint8 v, bytes32 r, bytes32 s) public view returns (bool) {
    bytes32 digest = keccak256(
      abi.encodePacked(
        "\x19\x01",
        DOMAIN_SEPARATOR,
        hash(claim)
      )
    );
    return verifyIssuer(digest, claim.issuer, v, r, s) && valid(claim.validFrom, claim.validTo);
  }

}