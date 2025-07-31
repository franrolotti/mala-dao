// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/Token.sol";
import "../src/TimeLock.sol";
import "../src/Governor.sol";

contract DeployDAO is Script {
    function run() external {
        address deployer = vm.envAddress("DEPLOYER_ADDR"); // <- NEW
        uint256 pk       = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(pk);

        uint256 SUPPLY    = 1_000_000e18;
        uint256 MIN_DELAY = 1 days;

        Token token = new Token(deployer, SUPPLY);
        TimeLock timelock = new TimeLock(MIN_DELAY, deployer);   // pass admin
        GovernorDAO gov = new GovernorDAO(token, timelock);

        // while deployer is still admin, grant roles
        timelock.grantRole(timelock.PROPOSER_ROLE(), address(gov));
        timelock.grantRole(timelock.EXECUTOR_ROLE(), address(0));   // anyone

        // now drop admin so DAO is trust-less
        timelock.revokeRole(timelock.DEFAULT_ADMIN_ROLE(), deployer);

        vm.stopBroadcast();

        console2.log("Token     :", address(token));
        console2.log("Timelock  :", address(timelock));
        console2.log("Governor  :", address(gov));
    }
}
