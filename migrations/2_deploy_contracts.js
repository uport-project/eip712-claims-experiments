const DomainDelegateVerifier = artifacts.require('DomainDelegateVerifier')
const IdentityClaimsVerifier = artifacts.require('IdentityClaimsVerifier')
const OwnershipProofVerifier = artifacts.require('OwnershipProofVerifier')
const KYCCoin = artifacts.require('KYCCoin')

module.exports = function (deployer) {
  deployer.deploy(DomainDelegateVerifier)
  deployer.deploy(IdentityClaimsVerifier)
  deployer.deploy(OwnershipProofVerifier)
  deployer.deploy(KYCCoin, IdentityClaimsVerifier.address, OwnershipProofVerifier.address)
};
