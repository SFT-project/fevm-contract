// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockToken is ERC20 {

    constructor() ERC20("MOCK FIL", "MF") {}

     function mint (address to_, uint amount_) external {
        _mint(to_, amount_);
    }
}