// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "openzeppelin-contracts/contracts/governance/Governor.sol";
import "openzeppelin-contracts/contracts/governance/extensions/GovernorCountingSimple.sol";
import "openzeppelin-contracts/contracts/governance/extensions/GovernorVotes.sol";
import "openzeppelin-contracts/contracts/governance/extensions/GovernorVotesQuorumFraction.sol";
import "openzeppelin-contracts/contracts/governance/extensions/GovernorTimelockControl.sol";

import "./Token.sol";
import "./TimeLock.sol";

contract GovernorDAO is
    Governor,
    GovernorCountingSimple,
    GovernorVotes,
    GovernorVotesQuorumFraction,
    GovernorTimelockControl
{
    constructor(IVotes _token, TimelockController _timelock)
        Governor("MalaGovernor")
        GovernorVotes(_token)
        GovernorVotesQuorumFraction(10)           // 10 % quorum
        GovernorTimelockControl(_timelock)
    {}

    /* --- parameters --- */
    function votingDelay()  public pure override returns (uint256) { return 1; }
    function votingPeriod() public pure override returns (uint256) { return 45_818; }
    function proposalThreshold() public pure override returns (uint256) { return 0; }

    /* --- quorum passthrough --- */
    function quorum(uint256 blockNumber)
        public view
        override(Governor, GovernorVotesQuorumFraction)
        returns (uint256)
    { return super.quorum(blockNumber); }

    /* --- state merge (Governor + Timelock) --- */
    function state(uint256 id)
        public view
        override(Governor, GovernorTimelockControl)
        returns (ProposalState)
    { return super.state(id); }

    function proposalNeedsQueuing(uint256 id)
        public view
        override(Governor, GovernorTimelockControl)
        returns (bool)
    { return super.proposalNeedsQueuing(id); }

    function _executor()
        internal view
        override(Governor, GovernorTimelockControl)
        returns (address)
    { return super._executor(); }

    function _queueOperations(
        uint256 id,
        address[] memory t,
        uint256[] memory v,
        bytes[]  memory d,
        bytes32  h
    )
        internal
        override(Governor, GovernorTimelockControl)
        returns (uint48) 
    {                        
        return super._queueOperations(id, t, v, d, h);
    }

    function _executeOperations(
        uint256 id,
        address[] memory t,
        uint256[] memory v,
        bytes[]  memory d,
        bytes32  h
    )
        internal
        override(Governor, GovernorTimelockControl)
    {
        super._executeOperations(id, t, v, d, h);
    }

    function _cancel(
        address[] memory t,
        uint256[] memory v,
        bytes[]  memory d,
        bytes32  h
    )
        internal
        override(Governor, GovernorTimelockControl)
        returns (uint256)
    {
        return super._cancel(t, v, d, h);
    }

    /* --- ERC-6372 clock --- */
    function clock()
        public view
        override(Governor, GovernorVotes)
        returns (uint48)
    { return uint48(block.number); }

    function CLOCK_MODE()
        public pure
        override(Governor, GovernorVotes)
        returns (string memory)
    { return "mode=blocknumber&from=default"; }

    /* receive ETH from Timelock */
    receive() external payable override(Governor) {}
}
