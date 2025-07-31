// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "openzeppelin-contracts/contracts/governance/TimelockController.sol";

/// @dev Simple wrapper: only `minDelay` is supplied at deploy.
///      Proposers / executors start empty and are granted later.
contract TimeLock is TimelockController {
    constructor(uint256 minDelay, address initialAdmin)
        TimelockController(
            minDelay,
            new address[](0),   // proposers
            new address[](0),   // executors (anyone)
            initialAdmin                 // admin = deployer (msg.sender)
        )
    {}
}
