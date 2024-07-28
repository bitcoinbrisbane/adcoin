// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

struct Ad {
    uint256 start;
    uint256 duration;
    string symbol;
    string message;
}

contract AdCoin is ERC20 {
    mapping(uint256 => Ad) private adSpace;
    uint256 public fee = 10000000000 wei; // per day
    uint256 private constant START_HOUR = 12; // 12:00 PM
    uint256 private holdersCount;
    address private owner;

    function holders () public view returns (uint256) {
        return holdersCount;
    }

    function decimals() public pure override returns (uint8) {
        return 0;
    }

    function name() public view override returns (string memory) {
        uint256 day = getDayFromTimestamp(block.timestamp);
        string memory _name = adSpace[day].message;

        return _name;
    }

    function symbol() public view override returns (string memory) {
        uint256 day = getDayFromTimestamp(block.timestamp);
        string memory _symbol = adSpace[day].symbol;

        return _symbol;
    }

    constructor() ERC20("AdCoin", "ADC") {
        _mint(msg.sender, 10000000);
        owner = msg.sender;
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        // Cannot transfer all of the tokens
        require(balanceOf(msg.sender) >= amount + 1, "AdCoin: insufficient balance");

        if (balanceOf(recipient) == 0) {
            holdersCount++;
        }

        return super.transfer(recipient, amount);
    }

    function nextAvailableDay() public view returns (uint256) {
        uint256 day = getDayFromTimestamp(block.timestamp);
        uint256 nextDay = day + 1;

        while (_isRented(nextDay)) {
            nextDay++;
        }

        return nextDay;
    }

    function quote(uint256 duration) public view returns (uint256) {
        return _quote(duration);
    }

    function _quote(uint256 duration) private view returns (uint256) {
        uint256 _holders = holdersCount / 1000 + 1;
        return duration * fee * _holders;
    }

    function isRentedNow() public view returns (bool) {
        uint256 day = getDayFromTimestamp(block.timestamp);
        return _isRented(day);
    }

    function isRented(uint256 day) public view returns (bool) {
        return _isRented(day);
    }

    function _isRented(uint256 time) private view returns (bool) {
        // Check if the ad space is occupied at this time
        uint256 _now = getDayFromTimestamp(block.timestamp);
        return adSpace[_now].start <= time && time < adSpace[_now].start + adSpace[_now].duration;
    }

    function rentAdSpaceNow(
        uint256 duration,
        string calldata _symbol,
        string calldata message
    ) external payable {
        uint256 day = getDayFromTimestamp(block.timestamp);
        _rentAdSpace(day, duration, _symbol, message);
    }

    function rentAdSpace(
        uint256 start,
        uint256 duration,
        string calldata _symbol,
        string calldata message
    ) external payable {
        _rentAdSpace(start, duration, _symbol, message);
    }

    function _rentAdSpace(
        uint256 day,
        uint256 duration,
        string calldata _symbol,
        string calldata message
    ) private {
        require(!_isRented(day), "AdCoin: ad space is already rented");
        require(msg.value >= _quote(duration), "AdCoin: insufficient funds");

        Ad memory ad = Ad({start: day, duration: duration * 1 days, symbol: _symbol, message: message});

        adSpace[day] = ad;

        emit AdSpacePurchased(msg.sender, duration, message);
    }

    function shill(address to) public {
        _mint(to, 1);
    }

    function withdraw() public {
        require(msg.sender == owner, "AdCoin: only owner can withdraw");
        payable(owner).transfer(address(this).balance);
    }

    // Helper function to get the current day number
    function getCurrentDay() public view returns (uint256) {
        return getDayFromTimestamp(block.timestamp);
    }

    // Helper function to get the day number from a timestamp
    function getDayFromTimestamp(
        uint256 _timestamp
    ) public pure returns (uint256) {
        return _timestamp / 1 days;
    }

    // Helper function to get the start timestamp for a given day
    function getStartTimestampForDay(
        uint256 _day
    ) public pure returns (uint256) {
        return _day * 1 days + START_HOUR * 1 hours;
    }

    event AdSpacePurchased(
        address indexed buyer,
        uint256 duration,
        string message
    );
}
