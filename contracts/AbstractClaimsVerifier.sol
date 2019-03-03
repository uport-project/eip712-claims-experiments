pragma solidity >=0.5.3 <0.6.0;
import "./EthereumDIDRegistry.sol";
import "./RevocationRegistry.sol";

contract AbstractClaimsVerifier {
  
  EthereumDIDRegistry registry;
  RevocationRegistry revocations;

  struct EIP712Domain {
    string  name;
    string  version;
    uint256 chainId;
    address verifyingContract;
  }

  bytes32 constant EIP712DOMAIN_TYPEHASH = keccak256(
    "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
  );

  bytes32 DOMAIN_SEPARATOR;

  constructor (
    string memory name, 
    string memory version, 
    uint256 chainId, 
    address verifyingContract, 
    address _registryAddress, 
    address _revocations) public {
    DOMAIN_SEPARATOR = hash(
      EIP712Domain({
        name: name,
        version: version,
        chainId: chainId,
        verifyingContract: verifyingContract
    }));
    registry = EthereumDIDRegistry(_registryAddress);
    revocations = RevocationRegistry(_revocations);
  }

  function hash(EIP712Domain memory eip712Domain) internal pure returns (bytes32) {
    return keccak256(
      abi.encode(
        EIP712DOMAIN_TYPEHASH,
        keccak256(bytes(eip712Domain.name)),
        keccak256(bytes(eip712Domain.version)),
        eip712Domain.chainId,
        eip712Domain.verifyingContract
    ));
  }

  function valid(uint256 validFrom, uint256 validTo) internal view returns (bool) {
    return (validFrom >= block.timestamp) && (block.timestamp < validTo);
  }

  function verifyIssuer(bytes32 digest, address issuer, address subject, uint8 v, bytes32 r, bytes32 s) internal view returns (bool) {
    return !revocations.revoked(issuer, digest) && !revocations.revoked(issuer, subject) &&registry.validDelegate(issuer, "veriKey", ecrecover(digest, v, r, s));
  }  
}