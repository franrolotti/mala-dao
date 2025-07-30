// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "openzeppelin-contracts/contracts/governance/Governor.sol";
import "openzeppelin-contracts/contracts/governance/extensions/GovernorTimelockControl.sol";
import "openzeppelin-contracts/contracts/governance/extensions/GovernorVotesQuorumFraction.sol";

import "./Token.sol";
import "./TimeLock.sol";

/// @title Governor de la Mala DAO (OZ v5)
contract GovernorDAO is
    Governor,
    GovernorVotesQuorumFraction,
    GovernorTimelockControl
{
    constructor(Token _token, TimeLock _timelock)
        Governor("MalaGovernor")
        GovernorVotesQuorumFraction(10)   // 10 % de quórum
        GovernorTimelockControl(_timelock)
    {
        // nada extra
    }

    /* ---------- parámetros de votación ---------- */
    function votingDelay() public pure override returns (uint256) {
        return 1;                 // 1 bloque
    }
    function votingPeriod() public pure override returns (uint256) {
        return 45_818;            // ≈ 1 semana (6,5 s × bloque)
    }
    function proposalThreshold() public pure override returns (uint256) {
        return 0;
    }

    /* ---------- overrides mínimos requeridos ---------- */
    function state(uint256 proposalId)
        public view
        override(Governor, GovernorTimelockControl)
        returns (ProposalState)
    { return super.state(proposalId); }

    function _executor()
        internal view
        override(Governor, GovernorTimelockControl)
        returns (address)
    { return super._executor(); }

    /* clock para ERC-6372 (OZ v5) */
    function clock() public view override returns (uint48) {
        return uint48(block.number);
    }
    function CLOCK_MODE() public pure override returns (string memory) {
        return "mode=blocknumber&from=default";
    }

    /* ¡Importante!: GovernorTimelockControl necesita poder recibir ETH */
    receive() external payable override(GovernorTimelockControl) {}
}
