//SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title HSpace ERC20 Token
 *
 * @dev Implementation of the Space  token for the non-zone project.
 * @author non-zone
 */
contract HSpaceToken is ERC20 {

    constructor() ERC20("H-Space", "HSPACE") {
        _mint(msg.sender, 500 * 1e18);
    }
}
