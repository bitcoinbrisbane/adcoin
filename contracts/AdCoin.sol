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
    uint256 public fee = 100000000000 wei; // per day
    uint256 public nextAvailableDay;
    uint256 private constant START_HOUR = 12; // 12:00 PM

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
        _mint(msg.sender, 1000000 * 10 ** decimals());
    }

    function quote(uint256 duration) public view returns (uint256) {
        return duration * fee;
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
        require(msg.value >= quote(duration), "AdCoin: insufficient funds");

        Ad memory ad = Ad({start: day, duration: duration * 1 days, symbol: _symbol, message: message});

        adSpace[day] = ad;

        emit AdSpacePurchased(msg.sender, duration, message);
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
