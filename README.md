# Titan Forge - On-Chain Options Protocol

[![Stacks](https://img.shields.io/badge/Stacks-3.0-orange)](https://stacks.org)
[![Clarity](https://img.shields.io/badge/Clarity-3.0-blue)](https://clarity-lang.org)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

Titan Forge is a composable, decentralized options trading engine built for programmable financial derivatives on the Stacks blockchain. It enables users to write, buy, and exercise CALL and PUT options using any SIP-010 compliant token with robust risk management and governance features.

## 🚀 Features

### Core Options Trading

- **CALL & PUT Options**: Full support for both option types with proper collateralization
- **Dynamic Pricing**: Integrated price oracle system for real-time asset pricing
- **Flexible Expiry**: Time-based expiration using Stacks block height
- **Automatic Settlement**: Seamless option exercise with profit calculation

### Security & Risk Management

- **Collateral Requirements**: Dynamic collateral calculation based on option type and strike price
- **Token Whitelisting**: Only approved SIP-010 tokens can be used as collateral
- **Position Tracking**: Comprehensive user position management
- **Validation Layer**: Extensive input validation and error handling

### Governance & Administration

- **Protocol Fees**: Configurable fee structure (max 10%)
- **Oracle Management**: Permissioned price feed updates
- **Asset Approval**: Administrative control over supported tokens
- **Critical Asset Protection**: Safeguards against removing essential tokens

## 📋 Table of Contents

- [Installation](#installation)
- [Quick Start](#quick-start)
- [Contract Architecture](#contract-architecture)
- [API Reference](#api-reference)
- [Testing](#testing)
- [Security Considerations](#security-considerations)
- [Deployment](#deployment)
- [Contributing](#contributing)

## 🛠️ Installation

### Prerequisites

- [Node.js](https://nodejs.org/) (v18+)
- [Clarinet](https://github.com/hirosystems/clarinet) (v2.0+)
- [Stacks CLI](https://docs.stacks.co/stacks-cli)

### Setup

```bash
# Clone the repository
git clone https://github.com/veronica-andiee/titan-forge.git
cd titan-forge

# Install dependencies
npm install

# Check contract syntax
clarinet check

# Run tests
npm test
```

## 🚀 Quick Start

### 1. Writing an Option

```clarity
;; Write a CALL option for 1000 STX at strike price 2.5 STX, expiring in 1000 blocks
(contract-call? .titan-forge write-option
  .wrapped-stx       ;; SIP-010 token contract
  u1000000000        ;; Collateral amount (1000 STX in microSTX)
  u2500000           ;; Strike price (2.5 STX in microSTX)
  u50000000          ;; Premium (50 STX in microSTX)
  (+ stacks-block-height u1000)  ;; Expiry (1000 blocks from now)
  "CALL"             ;; Option type
)
```

### 2. Buying an Option

```clarity
;; Buy an existing option by ID
(contract-call? .titan-forge buy-option
  .wrapped-stx       ;; Payment token
  u1                 ;; Option ID
)
```

### 3. Exercising an Option

```clarity
;; Exercise an option you hold
(contract-call? .titan-forge exercise-option
  .wrapped-stx       ;; Settlement token
  u1                 ;; Option ID
)
```

## 🏗️ Contract Architecture

### Data Structures

#### Options Map

```clarity
(define-map options uint {
  writer: principal,
  holder: (optional principal),
  collateral-amount: uint,
  strike-price: uint,
  premium: uint,
  expiry: uint,
  is-exercised: bool,
  option-type: (string-ascii 4),   ;; "CALL" or "PUT"
  state: (string-ascii 9),         ;; "ACTIVE" or "EXERCISED"
})
```

#### User Positions

```clarity
(define-map user-positions principal {
  written-options: (list 10 uint),
  held-options: (list 10 uint),
  total-collateral-locked: uint,
})
```

#### Price Feeds

```clarity
(define-map price-feeds (string-ascii 10) {
  price: uint,
  timestamp: uint,
  source: principal,
})
```

### Key Functions

| Function | Type | Description |
|----------|------|-------------|
| `write-option` | Public | Create a new option contract |
| `buy-option` | Public | Purchase an existing option |
| `exercise-option` | Public | Exercise a held option |
| `set-approved-token` | Admin | Manage token whitelist |
| `update-price-feed` | Admin | Update asset prices |
| `set-protocol-fee-rate` | Admin | Adjust protocol fees |

## 📚 API Reference

### Public Functions

#### `write-option`

Creates a new option contract with specified parameters.

**Parameters:**

- `token` (SIP-010 trait): Token contract for collateral
- `collateral-amount` (uint): Amount of collateral to lock
- `strike-price` (uint): Option strike price
- `premium` (uint): Option premium
- `expiry` (uint): Block height when option expires
- `option-type` (string-ascii 4): "CALL" or "PUT"

**Returns:** `(response uint uint)` - Option ID on success

#### `buy-option`

Purchases an existing option by paying the premium.

**Parameters:**

- `token` (SIP-010 trait): Token contract for payment
- `option-id` (uint): ID of option to purchase

**Returns:** `(response bool uint)` - Success boolean

#### `exercise-option`

Exercises a held option if profitable and not expired.

**Parameters:**

- `token` (SIP-010 trait): Token contract for settlement
- `option-id` (uint): ID of option to exercise

**Returns:** `(response bool uint)` - Success boolean

### Read-Only Functions

#### `get-option`

Retrieves option details by ID.

```clarity
(define-read-only (get-option (option-id uint))
  (map-get? options option-id)
)
```

#### `get-user-position`

Gets user's position summary.

```clarity
(define-read-only (get-user-position (user principal))
  (map-get? user-positions user)
)
```

### Administrative Functions

#### `set-approved-token`

Manages the token whitelist (owner only).

```clarity
(define-public (set-approved-token (token principal) (approved bool))
```

#### `update-price-feed`

Updates asset price data (owner only).

```clarity
(define-public (update-price-feed 
  (symbol (string-ascii 10)) 
  (price uint) 
  (timestamp uint)
)
```

## 🧪 Testing

The project uses Vitest with Clarinet SDK for comprehensive testing.

```bash
# Run all tests
npm test

# Run tests with coverage
npm run test:report

# Watch mode for development
npm run test:watch

# Check contract syntax
clarinet check
```

### Test Categories

- **Unit Tests**: Core function testing
- **Integration Tests**: Multi-contract interactions
- **Edge Cases**: Boundary condition testing
- **Security Tests**: Attack vector validation

## 🔒 Security Considerations

### Collateral Management

- **Dynamic Requirements**: Collateral calculated based on option type and market conditions
- **Locked Funds**: Collateral remains locked until option expiry or exercise
- **Slippage Protection**: Minimum collateral requirements prevent undercollateralization

### Access Controls

- **Owner Privileges**: Limited to fee adjustment and asset management
- **Token Validation**: Only whitelisted SIP-010 tokens accepted
- **Critical Asset Protection**: Prevents removal of essential tokens

### Oracle Security

- **Permissioned Updates**: Only authorized sources can update prices
- **Timestamp Validation**: Prevents stale price data
- **Symbol Validation**: Restricted to approved trading pairs

### Error Handling

```clarity
;; Comprehensive error constants
(define-constant ERR-NOT-AUTHORIZED (err u1000))
(define-constant ERR-INSUFFICIENT-BALANCE (err u1001))
(define-constant ERR-INVALID-EXPIRY (err u1002))
(define-constant ERR-OPTION-EXPIRED (err u1005))
;; ... additional error codes
```

## 🚀 Deployment

### Testnet Deployment

```bash
# Deploy to testnet
clarinet deploy --testnet

# Verify deployment
clarinet console --testnet
```

### Mainnet Deployment

```bash
# Deploy to mainnet (ensure thorough testing first)
clarinet deploy --mainnet
```

### Post-Deployment Setup

1. **Initialize Price Feeds**

   ```clarity
   (contract-call? .titan-forge set-allowed-symbol "BTC-USD" true)
   (contract-call? .titan-forge update-price-feed "BTC-USD" u4500000000000 stacks-block-height)
   ```

2. **Approve Initial Tokens**

   ```clarity
   (contract-call? .titan-forge set-approved-token .wrapped-btc true)
   (contract-call? .titan-forge set-approved-token .wrapped-stx true)
   ```

3. **Set Protocol Fee**

   ```clarity
   (contract-call? .titan-forge set-protocol-fee-rate u100)  ;; 1%
   ```

## 📊 Gas Optimization

The contract is optimized for minimal transaction costs:

- **Efficient Data Structures**: Minimal storage overhead
- **Batch Operations**: Reduced function call complexity
- **Lazy Evaluation**: Conditional execution paths
- **Memory Management**: Optimized list operations

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md).

### Development Workflow

1. Fork the repository
2. Create a feature branch
3. Make changes with tests
4. Run the test suite
5. Submit a pull request

### Code Style

- Follow Clarity best practices
- Use descriptive variable names
- Include comprehensive comments
- Maintain test coverage above 90%

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
