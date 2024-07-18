// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

struct Ad {
    uint256 duration;
    string message;
    uint256 start;
}

contract AdCoin is ERC20 {

    mapping (uint256 => Ad) private adSpace;
    uint256 public fee = 100 gwei;

    function name() public view override returns (string memory) {
        string memory _name = adSpace[block.timestamp].message;

        return _name;
    }

    constructor() ERC20("AdCoin", "ADC") {
        _mint(msg.sender, 1000000 * 10 ** decimals());
    }

    function getFee(uint256 duration) public view returns (uint256) {
        return duration * fee;
    }

    function isRented(uint256 time) public view returns (bool) {
        return _isRented(time);
    }

    function _isRented(uint256 time) private view returns (bool) {
        // Check if the ad space is occupied at this time
        uint256 _now = block.timestamp;
        return adSpace[time].start > _now && adSpace[time].start + adSpace[time].duration > _now;
    }

    function rentAdSpace(uint256 start, uint256 duration, string calldata message) external payable {
        require(duration > 0, "AdCoin: duration must be greater than 0");
        require(!_isRented(start), "AdCoin: ad space is already rented");
        require(msg.value >= getFee(duration), "AdCoin: insufficient funds");
        
        Ad memory ad = Ad({
            duration: duration,
            message: message,
            start: start
        });

        adSpace[start] = ad;

        emit AdSpacePurchased(msg.sender, duration, message);
    }

    event AdSpacePurchased(address indexed buyer, uint256 duration, string message);
}
