// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/Token.sol";
import "../src/TimeLock.sol";
import "../src/Governor.sol";

contract DeployDAO is Script {
    function run() external {
        uint256 pk = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(pk);

        uint256 SUPPLY    = 1_000_000 * 1e18;
        uint256 MIN_DELAY = 1 days;

        /* 1. Token */
        Token token = new Token(msg.sender, SUPPLY);

        /* 2. Timelock (only delay needed) */
        TimeLock timelock = new TimeLock(MIN_DELAY);

        /* 3. Governor */
        GovernorDAO gov = new GovernorDAO(token, timelock);

        /* 4. Wire timelock roles */
        timelock.grantRole(timelock.PROPOSER_ROLE(), address(gov));
        timelock.grantRole(timelock.EXECUTOR_ROLE(), address(0)); // anyone
        timelock.revokeRole(timelock.DEFAULT_ADMIN_ROLE(), msg.sender);

        vm.stopBroadcast();

        console2.log("Token     :", address(token));
        console2.log("Timelock  :", address(timelock));
        console2.log("Governor  :", address(gov));
    }
}
