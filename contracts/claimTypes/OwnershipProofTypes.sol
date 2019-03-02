pragma solidity >=0.5.3 <0.6.0;

contract OwnershipProofTypes {
  struct OwnershipProof {
    address subject;
    uint256 validFrom;
    uint256 validTo;
  }

  struct ContractOwnershipProof {
    address issuer;
    address subject;
    uint256 validFrom;
    uint256 validTo;
  }

  bytes32 constant OWNERSHIP_PROOF_TYPEHASH = keccak256(
    "OwnershipProof(address subject, uint256 validFrom, uint256 validTo)"
  );

  bytes32 constant CONTRACT_OWNERSHIP_PROOF_TYPEHASH = keccak256(
    "ContractOwnershipProof(address issuer, address subject, uint256 validFrom, uint256 validTo)"
  );

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
}