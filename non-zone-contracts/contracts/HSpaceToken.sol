// SPDX-License-Identifier: AGPLv3
pragma solidity ^0.7.6;


import {
    ISuperToken
} from "@superfluid-finance/ethereum-contracts/contracts/interfaces/superfluid/ISuperfluid.sol"; 
import {
    CustomSuperTokenProxyBase
}
from "@superfluid-finance/ethereum-contracts/contracts/interfaces/superfluid/CustomSuperTokenProxyBase.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @dev Native SuperToken custom token functions
 *
 * @author Superfluid
 */
interface INativeSuperTokenCustom {
    function initialize(string calldata name, string calldata symbol, uint256 initialSupply) external;
}

/**
 * @dev Native SuperToken full interface
 *
 * @author Superfluid
 */
interface INativeSuperToken is INativeSuperTokenCustom, ISuperToken {
    function initialize(string calldata name, string calldata symbol, uint256 initialSupply) external override;
}

/**
 * @dev Native SuperToken custom super token implementation
 *
 * NOTE:
 * - This is a simple implementation where the supply is pre-minted.
 *
 * @author Superfluid
 */
contract HSpaceToken is INativeSuperTokenCustom, CustomSuperTokenProxyBase {
    function initialize(string calldata name, string calldata symbol, uint256 initialSupply)
        external override
    {
        ISuperToken(address(this)).initialize(
            IERC20(0x0), // no underlying/wrapped token
            18,
            name,
            symbol
        );
        ISuperToken(address(this)).selfMint(msg.sender, 500 * 1e18, new bytes(0));
    }
}