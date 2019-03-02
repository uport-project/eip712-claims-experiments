pragma solidity >=0.5.3 <0.6.0;
pragma experimental ABIEncoderV2;
import "./AbstractClaimsVerifier.sol";
import "./claimTypes/DomainDelegateTypes.sol";

contract DomainDelegateVerifier is AbstractClaimsVerifier, DomainDelegateTypes {

  constructor (address _registryAddress, address _revocations) 
  AbstractClaimsVerifier(
    "EIP712DomainDelegate",
    "1",
    1,
    address(this),
    _registryAddress,
    _revocations
  ) public {}

  function hash(DomainDelegate memory delegate) public pure returns (bytes32) {
    return keccak256(
      abi.encode(
        DOMAIN_DELEGATE_TYPEHASH,
        delegate.issuer,
        delegate.subject,
        delegate.domain,
        delegate.type_hash,
        delegate.validFrom,
        delegate.validTo
      )
    );
  }

  function verify(DomainDelegate memory _delegate, uint8 v, bytes32 r, bytes32 s) public view returns (bool) {
    DomainDelegate memory delegate = _delegate;
    bytes32 digest = keccak256(
      abi.encodePacked(
        "\x19\x01",
        DOMAIN_SEPARATOR,
        hash(delegate)
      )
    );
    return verifyIssuer(digest, delegate.issuer, v, r, s);
  }

}