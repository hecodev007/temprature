//SPDX-License-Identifier: Unlicense
pragma solidity 0.6.12;

import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
// "^3.4.2",
contract Temperature is Ownable {
    using SafeMath for uint256;
    uint256 private temperature;
    uint private decimals;
    uint256 private blockTimestampLast;
    uint256 private blockTimestampInitial;
    uint256 public temperatureCumulativeLast;
    uint256 private limit;//average +- limit
    mapping(address => bool) public  whitelist;
    modifier onlyCaller() {
        require(whitelist[msg.sender] == true, "not the whitelist caller");
        _;
    }

    constructor (uint _decimal, uint256 _limit) public {
        decimals = _decimal;
        limit = _limit;
    }

    function getTemperature() public view returns (uint256) {
        return temperature_internal();
    }

    function temperature_internal() internal view returns (uint256) {
        if (blockTimestampLast == 0) {
            return temperature;
        } else {
            uint256 blockTimestamp = block.timestamp % 2 ** 32;
            uint256 timeElapsed = blockTimestamp - blockTimestampInitial;
            return temperatureCumulativeLast / timeElapsed;
        }
    }

    function setWhiteList(address _call) public onlyOwner {
        whitelist[_call] = true;
    }

    function setTemperature(uint256 _temprature) public onlyCaller {
        require(_temprature <= temperature_internal().add(limit) && _temprature >= temperature_internal().sub(limit), "wrong value");
        uint256 blockTimestamp = block.timestamp % 2 ** 32;
        uint256 timeElapsed = blockTimestamp - blockTimestampLast;
        if (blockTimestampLast == 0) {
            blockTimestampInitial = blockTimestamp;
        }
        temperatureCumulativeLast += _temprature.mul(timeElapsed);
    }
}
