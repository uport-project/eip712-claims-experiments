pragma solidity >=0.5.3 <0.6.0;

contract EthereumDIDRegistry {
  function validDelegate(address identity, bytes32 delegateType, address delegate) public view returns(bool);
}