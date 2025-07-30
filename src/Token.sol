// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Votes.sol";

contract Token is ERC20, ERC20Votes {
    constructor(address initialHolder, uint256 initialSupply)
        ERC20("Mala Gov Token", "MGT")
        ERC20Votes("Mala Gov Token")     // <- pasa name (y versión default "1")
    {
        _mint(initialHolder, initialSupply);
    }

    /* overrides obligatorios v5 */
    function _update(address from, address to, uint256 value)
        internal
        override(ERC20, ERC20Votes)
    { super._update(from, to, value); }
}
