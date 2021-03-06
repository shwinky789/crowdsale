pragma solidity ^0.4.15;

import './zeppelin/SafeMath.sol';

/**
 * @title EtherDivvy
 * @dev Contract to divvy up the ether raised in the crowdsale evenly between
 *      the three founders and the organization wallet.
 */
contract EtherDivvy {
    address public founderOne;      // Shayne 
    address public founderTwo;      // Logan
    address public founderThree;    // Jack
    address public organization;    // TokenBnk organization

    address multisig;               // Multisig wallet where the founders hold the key. Faciliates the setting of wallet addresses.

    modifier onlyMultisig {
        require(msg.sender == multisig);
        _;
    }

    modifier onlyIfAddressesSet(bool yes) {
        require(yes == (founderOne != 0x0 &&
                        founderTwo != 0x0 &&
                        founderThree != 0x0 &&
                        organization != 0x0));
        _;
    }

    function EtherDivvy(address _multisig) {
        multisig = _multisig;
    }

    function divvy()
        onlyMultisig
        onlyIfAddressesSet(true)
    {
        /// Use SafeMath.***() here to mitigate compiler error.
        uint oneHundredth = SafeMath.div(this.balance, 100);
        uint fivePercent = SafeMath.mul(oneHundredth, 5);
        uint threePercent = SafeMath.mul(oneHundredth, 3);
        uint twoPercent = SafeMath.mul(oneHundredth, 2);
        uint organizationShare = SafeMath.sub(
                                    SafeMath.sub(
                                        SafeMath.sub(this.balance, fivePercent),
                                    threePercent),
                                 twoPercent);

        founderThree.transfer(twoPercent);          // Sends funds from least significant portion to most.
        founderTwo.transfer(threePercent);
        founderOne.transfer(fivePercent);
        organization.transfer(organizationShare);
    }

    function setAddresses(address _one,
                          address _two,
                          address _three,
                          address _organization)
        onlyMultisig
        onlyIfAddressesSet(false)
    {
        founderOne = _one;
        founderTwo = _two;
        founderThree = _three;
        organization = _organization;
    }

    /// @dev Fallback function so that this contract can accept ether.
    function () payable {
    }
}