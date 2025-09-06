# BitVault - Bitcoin-Native Asset Tokenization Protocol

[![Clarity](https://img.shields.io/badge/Clarity-3.0-blue.svg)](https://clarity-lang.org/)
[![Stacks](https://img.shields.io/badge/Stacks-Layer%202-orange.svg)](https://stacks.co/)
[![Bitcoin](https://img.shields.io/badge/Bitcoin-Native-f7931e.svg)](https://bitcoin.org/)
[![License](https://img.shields.io/badge/License-ISC-green.svg)](LICENSE)

> Transform real-world assets into fractional Bitcoin-secured tokens with institutional-grade compliance and transparency built for Stacks Layer 2.

## 🌟 Overview

BitVault revolutionizes asset ownership by bridging traditional finance with Bitcoin's security model, enabling fractional ownership of premium assets while maintaining regulatory compliance and transparent governance. Built on Stacks, BitVault leverages Bitcoin's unmatched security for enterprise-grade asset tokenization.

### Core Value Propositions

- **Bitcoin-Secured Ownership**: Fractional asset ownership backed by Bitcoin's security model
- **Institutional Compliance**: Built-in regulatory safeguards and automated compliance verification  
- **Transparent Governance**: On-chain governance with comprehensive audit trails
- **Enterprise-Grade**: Professional audit logging and event tracking for regulatory reporting
- **Native Integration**: Seamless Stacks integration leveraging Bitcoin's finality

### Perfect Use Cases

- 🏢 **Real Estate Tokenization**: Fractional property ownership with compliance
- 🎨 **Art Collections**: Democratized access to premium art investments  
- 🥇 **Precious Metals**: Tokenized gold, silver, and commodity ownership
- 💎 **Intellectual Property**: Patent and IP rights tokenization
- 📈 **High-Value Assets**: Any premium asset requiring compliant fractional ownership

## 🏗️ Architecture

### Smart Contract Structure

```text
contracts/
└── bitvault-asset.clar          # Main protocol contract

tests/
└── bitvault-asset.test.ts       # Comprehensive test suite

settings/
├── Devnet.toml                  # Development configuration
├── Testnet.toml                 # Testnet configuration
└── Mainnet.toml                 # Production configuration
```

### Core Components

1. **Asset Registry**: Comprehensive metadata and ownership tracking
2. **Compliance System**: Regulatory approval and verification management
3. **Fractional Ownership**: Share-based ownership distribution system
4. **NFT Integration**: Primary ownership tokens for asset control rights
5. **Audit Trail**: Immutable event logging for regulatory compliance
6. **Validation Layer**: Multi-tier input validation and security checks

## 🔧 Installation & Setup

### Prerequisites

- **Node.js**: Version 18.0.0 or higher
- **Clarinet CLI**: Latest version
- **Git**: For version control

### Quick Start

1. **Clone the Repository**

```bash
git clone https://github.com/gid-ctl/bitvault-asset.git
cd bitvault-asset
```

2. **Install Dependencies**

```bash
npm install
```

3. **Run Contract Validation**

```bash
clarinet check
```

4. **Execute Test Suite**

```bash
npm test
```

5. **Development Mode with Watch**

```bash
npm run test:watch
```

## 📋 API Reference

### Core Functions

#### Asset Creation

```clarity
(define-public (create-asset
    (total-supply uint)
    (fractional-shares uint) 
    (metadata-uri (string-utf8 256))
  )
)
```

Creates a new tokenized asset with fractional ownership capabilities.

**Parameters:**

- `total-supply`: Total number of asset units
- `fractional-shares`: Number of fractional shares available
- `metadata-uri`: IPFS or HTTP URI containing asset metadata

**Returns:** `(response uint uint)` - Asset ID on success

#### Fractional Ownership Transfer

```clarity
(define-public (transfer-fractional-ownership
    (asset-id uint)
    (to-principal principal)
    (amount uint)
  )
)
```

Transfers fractional ownership shares with full compliance verification.

**Parameters:**

- `asset-id`: Unique asset identifier
- `to-principal`: Recipient's principal address
- `amount`: Number of shares to transfer

**Returns:** `(response bool uint)` - Success status

#### Compliance Management

```clarity
(define-public (set-compliance-status
    (asset-id uint)
    (user principal)
    (is-approved bool)
  )
)
```

Updates regulatory compliance status for asset participants.

**Parameters:**

- `asset-id`: Target asset identifier
- `user`: User's principal address
- `is-approved`: Compliance approval status

**Returns:** `(response bool uint)` - Updated compliance status

### Read-Only Functions

#### Asset Details

```clarity
(define-read-only (get-asset-details (asset-id uint)))
```

Retrieves comprehensive asset information including owner, supply, metadata, and transferability status.

#### Ownership Query

```clarity
(define-read-only (get-owner-shares
    (asset-id uint)
    (owner principal)
  )
)
```

Returns the fractional share balance for a specific asset-owner pair.

#### Compliance Status

```clarity
(define-read-only (get-compliance-details
    (asset-id uint)
    (user principal)
  )
)
```

Retrieves compliance status and approval history for regulatory auditing.

#### Event Audit

```clarity
(define-read-only (get-event (event-id uint)))
```

Accesses immutable event logs for comprehensive audit trails.

## 🔒 Security Model

### Multi-Layer Validation

1. **Input Validation**: Comprehensive parameter checking
2. **Business Logic**: Asset existence and ownership verification  
3. **Compliance Checks**: Regulatory approval validation
4. **Access Control**: Administrative function restrictions
5. **State Integrity**: Atomic operations with rollback capability

### Error Handling

```clarity
ERR-UNAUTHORIZED (u1)              # Access control violation
ERR-INSUFFICIENT-FUNDS (u2)        # Inadequate balance  
ERR-INVALID-ASSET (u3)             # Asset doesn't exist
ERR-TRANSFER-FAILED (u4)           # NFT transfer failure
ERR-COMPLIANCE-CHECK-FAILED (u5)   # Regulatory violation
ERR-INVALID-INPUT (u6)             # Parameter validation failure
ERR-INSUFFICIENT-SHARES (u7)       # Inadequate share balance
ERR-EVENT-LOGGING (u8)             # Audit trail failure
```

## 🧪 Testing Framework

### Test Configuration

The project uses **Vitest** with **Clarinet SDK** for comprehensive smart contract testing:

```bash
# Run all tests
npm test

# Generate coverage report  
npm run test:report

# Watch mode for development
npm run test:watch
```

### Test Structure

```typescript
import { describe, expect, it } from "vitest";

describe("BitVault Asset Tests", () => {
  it("should create asset with proper validation", () => {
    // Test implementation
  });
  
  it("should handle fractional transfers correctly", () => {
    // Test implementation  
  });
});
```

## 📊 Gas Optimization

BitVault implements several gas optimization strategies:

- **Efficient Data Structures**: Optimized map designs for minimal storage
- **Batch Operations**: Combined operations to reduce transaction costs
- **Lazy Evaluation**: On-demand computation for expensive operations
- **Storage Patterns**: Strategic use of maps vs. data variables

## 🚀 Deployment Guide

### Development Deployment

```bash
# Deploy to local devnet
clarinet integrate

# Deploy to public testnet  
clarinet deploy --testnet

# Deploy to mainnet (production)
clarinet deploy --mainnet
```

### Configuration Files

- **Devnet.toml**: Local development settings
- **Testnet.toml**: Public testnet configuration  
- **Mainnet.toml**: Production deployment settings

## 🤝 Contributing

We welcome contributions from the developer community!

### Development Process

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Commit** your changes (`git commit -m 'Add amazing feature'`)
4. **Push** to the branch (`git push origin feature/amazing-feature`)
5. **Open** a Pull Request

### Code Standards

- Follow Clarity best practices and naming conventions
- Include comprehensive tests for new functionality
- Document all public functions with clear descriptions
- Maintain consistent error handling patterns

## 📄 License

This project is licensed under the **ISC License** - see the [LICENSE](LICENSE) file for details.

## 🔗 Resources & Links

- **Stacks Documentation**: [docs.stacks.co](https://docs.stacks.co/)
- **Clarity Language**: [clarity-lang.org](https://clarity-lang.org/)
- **Clarinet CLI**: [github.com/hirosystems/clarinet](https://github.com/hirosystems/clarinet)
- **Bitcoin Whitepaper**: [bitcoin.org/bitcoin.pdf](https://bitcoin.org/bitcoin.pdf)
