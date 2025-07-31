// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/Token.sol";
import "../src/TimeLock.sol";
import "../src/Governor.sol";

contract GovernorFlow is Test {
    Token       token;
    TimeLock    timelock;
    GovernorDAO gov;
    address voter = address(0xBEEF);

    function setUp() public {
        token    = new Token(address(this), 1_000_000 * 1e18);
        timelock = new TimeLock(1 days);                      // ← fixed
        gov      = new GovernorDAO(token, timelock);

        timelock.grantRole(timelock.PROPOSER_ROLE(), address(gov));
        timelock.grantRole(timelock.EXECUTOR_ROLE(), address(0));
        timelock.revokeRole(timelock.DEFAULT_ADMIN_ROLE(), address(this));

        token.transfer(voter, 100_000 * 1e18);
        vm.prank(voter);
        token.delegate(voter);
    }

    function testFullProposalFlow() public {
        address [] memory targets = new address[](1);
        uint256 [] memory values   = new uint256[](1);
        bytes [] memory calldatas = new bytes[](1);
        string memory description  = "Mint 10 tokens to voter";

        targets[0]   = address(token);
        values[0]    = 0;
        calldatas[0] = abi.encodeWithSignature(
            "mint(address,uint256)", voter, 10 * 1e18
        );

        uint256 id = gov.propose(targets, values, calldatas, description);

        vm.roll(block.number + gov.votingDelay() + 1);
        vm.prank(voter);
        gov.castVote(id, 1);

        vm.roll(block.number + gov.votingPeriod() + 1);

        gov.queue(targets, values, calldatas, keccak256(bytes(description)));
        vm.warp(block.timestamp + timelock.getMinDelay() + 1);

        gov.execute(targets, values, calldatas, keccak256(bytes(description)));

        assertEq(token.balanceOf(voter), 100_010 * 1e18);
    }
}
