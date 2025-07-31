# Mala DAO – Solidity v0.8 / Foundry

A minimal, **production-ready skeleton** for an on-chain DAO built on OpenZeppelin v5:

| Contract                | Purpose                                                  |
|-------------------------|----------------------------------------------------------|
| `Token.sol`             | ERC-20 governance token (`MGT`) with **ERC20Permit** + **ERC20Votes** (on-chain snapshots). |
| `TimeLock.sol`          | Thin wrapper over `TimelockController`, deploys with empty proposer / executor arrays and a configurable `minDelay`. |
| `Governor.sol`          | `Governor` + `CountingSimple` + `VotesQuorumFraction` + `TimelockControl`.<br>Parameters: 1-block delay, ~1-week period, 10 % quorum, 0 threshold. |
| `DeployDAO.s.sol`       | Script that deploys Token → Timelock → Governor, wires the roles and revokes the deployer’s admin role. |
| `GovernorFlow.t.sol`    | End-to-end test: create proposal → vote → queue → execute. |

---

## Quick start

```bash
# Clone & install deps
git clone https://github.com/<you>/mala-dao.git
cd mala-dao
forge install         # installs OpenZeppelin v5

# Run tests
forge test -vv

# Deploy (set PRIVATE_KEY & RPC_URL in .env)
forge script script/DeployDAO.s.sol \
  --rpc-url $RPC_URL \
  --broadcast \
  --verify

```

### Repo layout

```bash
src/
  Token.sol
  TimeLock.sol
  Governor.sol
script/
  DeployDAO.s.sol
test/
  GovernorFlow.t.sol
lib/
  openzeppelin-contracts/   # via forge install
foundry.toml
remappings.txt
```
