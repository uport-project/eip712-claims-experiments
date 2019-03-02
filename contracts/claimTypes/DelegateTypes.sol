pragma solidity >=0.5.3 <0.6.0;
pragma experimental ABIEncoderV2;

contract DelegateTypes {

  struct Delegate {
    address issuer;
    address subject;
    bytes32 type_hash;
    uint256 validFrom;
    uint256 validTo;
  }

  struct VerifiedDelegate {
    Delegate delegate;
    uint8 v;
    bytes32 r;
    bytes32 s;
  }

  bytes32 constant DELEGATE_TYPEHASH = keccak256(
    "Delegate(address issuer, address subject, bytes32 type_hash, uint256 validFrom, uint256 validTo)"
  );

  bytes32 constant VERIFIED_DELEGATE_TYPEHASH = keccak256(
    abi.encodePacked("VerifiedDelegate(Delegate delegate, uint8 v, bytes32 r, bytes32 s)", DELEGATE_TYPEHASH)
  );

  function hash(Delegate memory delegate) public pure returns (bytes32) {
    return keccak256(
      abi.encode(
        DELEGATE_TYPEHASH,
        delegate.issuer,
        delegate.subject,
        delegate.type_hash,
        delegate.validFrom,
        delegate.validTo
      )
    );
  }

  function hash(VerifiedDelegate memory verified) public pure returns (bytes32) {
    return keccak256(
      abi.encode(
        VERIFIED_DELEGATE_TYPEHASH,
        hash(verified.delegate),
        verified.v,
        verified.r,
        verified.s
      )
    );
  }
}
