// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract SubToken is ERC20 {
    address trustedContract;

    constructor(uint256 initialSupply) ERC20("SubToken", "STK") {
        _mint(msg.sender, initialSupply);
    }

    function approveSpender(address _trustedContract) external {
        trustedContract = _trustedContract;
    }

    function directTransfer(address recipient, uint256 amount) external {
        require(msg.sender == trustedContract, "Unauthorized");
        _transfer(address(this), recipient, amount);
    }
}
