pragma solidity >=0.5.3 <0.6.0;

contract RevocationRegistry {
  
  mapping (bytes32 => mapping (address => uint)) public revocations;

  function revoke(bytes32 digest) public returns (bool) {
    revocations[digest][msg.sender] = block.number;
    return true;
  }

  function revoked(address party, bytes32 digest) public view returns (bool) {
    return revocations[digest][party] > 0;
  }
}