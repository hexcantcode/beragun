# Beragun

A gas-optimized Solidity contract for batch-sending Ether and ERC20 tokens to multiple recipients in a single transaction. This contract is designed to minimize gas costs while maintaining security and reliability.

## Features

- Batch send native ETH to multiple recipients
- Batch send ERC20 tokens to multiple recipients
- Gas-optimized implementation using:
  - Unchecked arithmetic for loop counters
  - Calldata arrays for gas efficiency
  - Single transferFrom for token batches
  - Automatic dust refund for ETH transfers
- Reentrancy protection using OpenZeppelin's ReentrancyGuard
- Event emission for tracking transfers

## Contract Details

### Functions

#### disperseEther
```solidity
function disperseEther(
    address payable[] calldata recipients,
    uint256[] calldata amounts
) external payable nonReentrant
```
Allows sending different amounts of ETH to multiple recipients in a single transaction. Any excess ETH is automatically refunded to the sender.

**Parameters:**
- `recipients`: Array of recipient addresses
- `amounts`: Array of ETH amounts in wei (must match recipients length)

#### disperseToken
```solidity
function disperseToken(
    IERC20 token,
    address[] calldata recipients,
    uint256[] calldata amounts
) external nonReentrant
```
Allows sending different amounts of an ERC20 token to multiple recipients in a single transaction.

**Parameters:**
- `token`: Address of the ERC20 token contract
- `recipients`: Array of recipient addresses
- `amounts`: Array of token amounts (must match recipients length)

### Events

- `DispersedEther(uint256 totalAmount, uint256 recipientsCount)`
- `DispersedToken(address indexed token, uint256 totalAmount, uint256 recipientsCount)`

## Installation

```bash
npm install @openzeppelin/contracts
```

## Security Features

- Uses OpenZeppelin's ReentrancyGuard to prevent reentrancy attacks
- Implements checks for array length matching
- Verifies all transfer success
- Safely handles ETH refunds
- Uses `.call{value}("")` for ETH transfers instead of `transfer()` or `send()`

## Gas Optimization Details

1. Uses `unchecked` blocks for loop counters where overflow is impossible
2. Employs `calldata` instead of `memory` for read-only arrays
3. Performs a single `transferFrom` for token batches
4. Minimizes storage reads/writes
5. Optimizes error messages for gas efficiency

## License

MIT 