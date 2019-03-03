pragma solidity >=0.5.3 <0.6.0;
pragma experimental ABIEncoderV2;
import "./claimTypes/DelegateTypes.sol";
import "./AbstractClaimsVerifier.sol";

contract ConsortiumAgreements is AbstractClaimsVerifier, DelegateTypes {

  struct Offer {
    VerifiableDelegate issuer;
    bytes32 terms;
    uint256 amount;
    uint256 price;
    uint256 validFrom;
    uint256 validTo;
  }

  struct Acceptance {
    VerifiableDelegate issuer;
    bytes32 offer;
    uint256 validFrom;
    uint256 validTo;
  }

  bytes32 constant OFFER_TYPEHASH = keccak256(
    abi.encodePacked(
      "Offer(VerifiableDelegate issuer, bytes32 terms, uint256 amount, uint256 price, uint256 validFrom, uint256 validTo)",
      VERIFIABLE_DELEGATE_TYPEHASH)
  );

  bytes32 constant ACCEPTANCE_TYPEHASH = keccak256(
    abi.encodePacked(
      "Acceptance(VerifiableDelegate issuer, bytes32 offer, uint256 validFrom, uint256 validTo)",
      VERIFIABLE_DELEGATE_TYPEHASH)
  );

  mapping (address => uint) members;
  mapping (bytes32 => Offer) offers;
  mapping (bytes32 => uint) agreements;

  event Offered(bytes32 indexed agreement, address indexed offerer);
  event Accepted(bytes32 indexed agreement, address indexed offerer, address indexed acceptor);

  modifier onlyMembers {
    require(
      members[msg.sender] > 0, "Only members can call this function."
    );
    _;
  }

  constructor(address _registryAddress, address _revocations)
  AbstractClaimsVerifier(
    "EIP712ConsortiumAgreementDemo",
    "1",
    1,
    address(this),
    _registryAddress,
    _revocations
  ) public {
    members[msg.sender] = block.number;
  }

  function addMember(address member) public onlyMembers {
    require(members[member] == 0, "Address is already a Consortium Member");
    members[member] = block.number;
  }

  function makeOffer(Offer memory offer, uint8 v, bytes32 r, bytes32 s) public returns(bool) {
    require(offer.validTo > block.timestamp, "offer should have validity in the future");
    require(offer.issuer.delegate.allowed_type_hash == OFFER_TYPEHASH, "delegate is not allowed to sign Offers");
    bytes32 digest = verifyAndReturnDigest(offer, v, r, s);
    require(digest != 0x0, "Could not Verify signature of Issuer");
    offers[digest] = offer;
    emit Offered(digest, offer.issuer.delegate.issuer);
  }

  function acceptOffer(Acceptance memory acceptance, uint8 v, bytes32 r, bytes32 s) public returns(bool) {
    require(verify(acceptance, v, r, s), "Could not Verify signature of Issuer");
    require(acceptance.issuer.delegate.allowed_type_hash == ACCEPTANCE_TYPEHASH, "delegate is not allowed to sign Acceptances");
    Offer memory offer = offers[acceptance.offer];
    require(offer.validTo > 0, "Offer has not been registered");
    require(agreements[acceptance.offer] > 0, "Offer has already been accepted");
    emit Accepted(acceptance.offer, offer.issuer.delegate.issuer, acceptance.issuer.delegate.issuer);
  }

  function hash(Offer memory offer) public pure returns (bytes32) {
    return keccak256(
      abi.encode(
        OFFER_TYPEHASH,
        hash(offer.issuer),
        offer.terms,
        offer.amount,
        offer.price,
        offer.validFrom,
        offer.validTo
      )
    );
  }

  function hash(Acceptance memory acceptance) public pure returns (bytes32) {
    return keccak256(
      abi.encode(
        ACCEPTANCE_TYPEHASH,
        hash(acceptance.issuer),
        acceptance.offer,
        acceptance.validFrom,
        acceptance.validTo
      )
    );
  }

  function verifyAndReturnDigest(Offer memory offer, uint8 v, bytes32 r, bytes32 s) internal view returns (bytes32) {
    if (verify(offer.issuer)) {
      bytes32 digest = keccak256(
        abi.encodePacked(
          "\x19\x01",
          DOMAIN_SEPARATOR,
          hash(offer)
        )
      );
      if (ecrecover(digest, v, r, s) == offer.issuer.delegate.subject && valid(offer.validFrom, offer.validTo)) {
        return digest;
      } else {
        return 0x0;
      }
    } else {
      return 0x0;
    }
  }

  function verify(Offer memory offer, uint8 v, bytes32 r, bytes32 s) public view returns (bool) {
    return (verifyAndReturnDigest(offer, v, r, s) != 0x0);
  }


  function verify(Acceptance memory acceptance, uint8 v, bytes32 r, bytes32 s) public view returns (bool) {
    if (verify(acceptance.issuer)) {
      bytes32 digest = keccak256(
        abi.encodePacked(
          "\x19\x01",
          DOMAIN_SEPARATOR,
          hash(acceptance)
        )
      );
      return ecrecover(digest, v, r, s) == acceptance.issuer.delegate.subject && valid(acceptance.validFrom, acceptance.validTo);
    } else {
      return false;
    }
  }

  function verify(VerifiableDelegate memory verified) public view returns (bool) {
    Delegate memory claim = verified.delegate;
    bytes32 digest = keccak256(
      abi.encodePacked(
        "\x19\x01",
        DOMAIN_SEPARATOR,
        hash(claim)
      )
    );
    return verifyIssuer(digest, claim.issuer, claim.subject, verified.v, verified.r, verified.s)
      && members[claim.issuer] > 0
      && valid(claim.validFrom, claim.validTo);
  }

}
