// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Votes.sol";

contract Token is ERC20, ERC20Permit, ERC20Votes {
    constructor(address initialHolder, uint256 initialSupply)
        ERC20("Mala Gov Token", "MGT")
        ERC20Permit("Mala Gov Token")
    {
        _mint(initialHolder, initialSupply);
    }

    /* Single hook required in OZ v5 */
    function _update(address from, address to, uint256 amount)
        internal
        override(ERC20, ERC20Votes)
    { super._update(from, to, amount); }

    /* ---- Resolve duplicate Nonces ---- */
    function nonces(address owner)
        public view
        override(ERC20Permit, Nonces)
        returns (uint256)
    { return super.nonces(owner); }


}
