// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "openzeppelin-contracts/contracts/governance/TimelockController.sol";

contract TimeLock is TimelockController {
    constructor(uint256 minDelay)
        TimelockController(
            minDelay,
            new address,    // proposers
            new address,    // executors (cualquiera)
            address(0)           // admin = cero
        )
    {}
}
