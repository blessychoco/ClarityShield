# Intellectual Property Protection Smart Contract

This project implements a smart contract for intellectual property (IP) protection using Clarity, the smart contract language for the Stacks blockchain. The contract allows users to register, verify, and transfer ownership of intellectual property.

## Features

- Register new intellectual property by providing a hash of the work
- Check ownership of registered intellectual property
- Verify the hash of registered intellectual property
- Transfer ownership of registered intellectual property

## Smart Contract Overview

The main components of the smart contract are:

1. **Data Storage**
   - `owner`: Stores the contract owner's principal (address)
   - `ip-registrations`: A map that stores IP registrations, indexed by an IP ID
   - `ip-counter`: A counter to generate unique IP IDs

2. **Main Functions**
   - `register-ip`: Register new IP by providing a hash of the work
   - `check-ip-ownership`: Check the ownership of a registered IP
   - `verify-ip-hash`: Verify an IP hash against the registered hash
   - `transfer-ip`: Transfer ownership of an IP to another address

## Usage

To use this smart contract, you need to:

1. Deploy the contract on the Stacks blockchain
2. Interact with the contract using its public functions

### Registering IP

To register new intellectual property:

```clarity
(contract-call? .ip-protection-contract register-ip 0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef)
```

This will return the new IP ID.

### Checking IP Ownership

To check the ownership of a registered IP:

```clarity
(contract-call? .ip-protection-contract check-ip-ownership u1)
```

Replace `u1` with the IP ID you want to check.

### Verifying IP Hash

To verify the hash of a registered IP:

```clarity
(contract-call? .ip-protection-contract verify-ip-hash u1 0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef)
```

Replace `u1` with the IP ID and provide the hash you want to verify.

### Transferring IP Ownership

To transfer ownership of an IP:

```clarity
(contract-call? .ip-protection-contract transfer-ip u1 'SP2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKNRV9EJ7)
```

Replace `u1` with the IP ID and provide the principal of the new owner.

## Development

To further develop or modify this smart contract:

1. Set up a Clarity development environment
2. Make changes to the contract code
3. Test thoroughly using Clarity testing frameworks
4. Deploy the updated contract to the Stacks blockchain

## Author

Blessing Eze