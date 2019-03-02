pragma solidity >=0.5.3 <0.6.0;
pragma experimental ABIEncoderV2;
import "./AbstractClaimsVerifier.sol";
import "./claimTypes/OwnershipProofTypes.sol";

contract OwnershipProofVerifier is AbstractClaimsVerifier, OwnershipProofTypes {

  constructor (address _registryAddress) AbstractClaimsVerifier("EIP712IdentityClaims", "1", 1, address(this), _registryAddress) public {}

  function hash(OwnershipProof memory claim) internal pure returns (bytes32) {
    return keccak256(
      abi.encode(
        OWNERSHIP_PROOF_TYPEHASH,
        claim.subject,
        claim.validFrom,
        claim.validTo
      )
    );
  }

  function hash(ContractOwnershipProof memory claim) internal pure returns (bytes32) {
    return keccak256(
      abi.encode(
        CONTRACT_OWNERSHIP_PROOF_TYPEHASH,
        claim.issuer,
        claim.subject,
        claim.validFrom,
        claim.validTo
      )
    );
  }

  function ownedAddress(OwnershipProof memory claim, uint8 v, bytes32 r, bytes32 s) public view returns (address) {
    bytes32 digest = keccak256(
      abi.encodePacked(
        "\x19\x01",
        DOMAIN_SEPARATOR,
        hash(claim)
      )
    );
    require(valid(claim.validFrom, claim.validTo), "invalid issuance timestamps");
    return ecrecover(digest, v, r, s);
  }


  function verify(ContractOwnershipProof memory claim, uint8 v, bytes32 r, bytes32 s) public view returns (bool) {
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