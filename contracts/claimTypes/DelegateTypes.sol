pragma solidity >=0.5.3 <0.6.0;
pragma experimental ABIEncoderV2;

contract DelegateTypes {

  struct Delegate {
    address issuer;
    address subject;
    bytes32 allowed_type_hash;
    uint256 validFrom;
    uint256 validTo;
  }

  struct VerifiableDelegate {
    Delegate delegate;
    uint8 v;
    bytes32 r;
    bytes32 s;
  }

  bytes32 constant DELEGATE_TYPEHASH = keccak256(
    "Delegate(address issuer, address subject, bytes32 allowed_type_hash, uint256 validFrom, uint256 validTo)"
  );

  bytes32 constant VERIFIABLE_DELEGATE_TYPEHASH = keccak256(
    abi.encodePacked("VerifiableDelegate(Delegate delegate, uint8 v, bytes32 r, bytes32 s)", DELEGATE_TYPEHASH)
  );

  function hash(Delegate memory delegate) public pure returns (bytes32) {
    return keccak256(
      abi.encode(
        DELEGATE_TYPEHASH,
        delegate.issuer,
        delegate.subject,
        delegate.allowed_type_hash,
        delegate.validFrom,
        delegate.validTo
      )
    );
  }

  function hash(VerifiableDelegate memory verified) public pure returns (bytes32) {
    return keccak256(
      abi.encode(
        VERIFIABLE_DELEGATE_TYPEHASH,
        hash(verified.delegate),
        verified.v,
        verified.r,
        verified.s
      )
    );
  }
}
