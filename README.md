# Intellectual Property Protection Smart Contract

This project implements a smart contract for intellectual property (IP) protection using Clarity, the smart contract language for the Stacks blockchain. The contract allows users to register, verify, transfer ownership, and set expirations for intellectual property.

## Features

* Register new intellectual property by providing a hash of the work and an optional expiration date
* Check ownership of registered intellectual property
* Verify the hash of registered intellectual property
* Transfer ownership of registered intellectual property
* Extend the registration period of intellectual property
* Automatic expiration of IP registrations

## Smart Contract Overview

The main components of the smart contract are:

1. **Data Storage**
   * `owner`: Stores the contract owner's principal (address)
   * `ip-registrations`: A map that stores IP registrations, indexed by an IP ID
   * `registered-hashes`: A map that tracks registered hashes to prevent duplicates
   * `ip-counter`: A counter to generate unique IP IDs

2. **Main Functions**
   * `register-ip`: Register new IP by providing a hash of the work and an optional expiration date
   * `check-ip-ownership`: Check the ownership of a registered IP
   * `verify-ip-hash`: Verify an IP hash against the registered hash
   * `transfer-ip`: Transfer ownership of an IP to another address
   * `extend-ip-registration`: Extend the registration period of an IP
   * `is-hash-registered`: Check if a hash is already registered

## Usage

To use this smart contract, you need to:

1. Deploy the contract on the Stacks blockchain
2. Interact with the contract using its public functions

### Registering IP

To register new intellectual property:

```lisp
(contract-call? .ip-protection-contract register-ip 
    0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef 
    (some u144000))
```

This will register the IP with the given hash and set an expiration 144000 blocks in the future. Omit the second argument or use `none` to register without an expiration date.

### Checking IP Ownership

To check the ownership of a registered IP:

```lisp
(contract-call? .ip-protection-contract check-ip-ownership u1)
```

Replace `u1` with the IP ID you want to check.

### Verifying IP Hash

To verify the hash of a registered IP:

```lisp
(contract-call? .ip-protection-contract verify-ip-hash u1 
    0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef)
```

Replace `u1` with the IP ID and provide the hash you want to verify.

### Transferring IP Ownership

To transfer ownership of an IP:

```lisp
(contract-call? .ip-protection-contract transfer-ip u1 
    'SP2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKNRV9EJ7)
```

Replace `u1` with the IP ID and provide the principal of the new owner.

### Extending IP Registration

To extend the registration period of an IP:

```lisp
(contract-call? .ip-protection-contract extend-ip-registration u1 u288000)
```

Replace `u1` with the IP ID and provide the new expiration block height.

## Development

To further develop or modify this smart contract:

1. Set up a Clarity development environment
2. Make changes to the contract code
3. Test thoroughly using Clarity testing frameworks
4. Deploy the updated contract to the Stacks blockchain

## Safety Features

The contract includes several safety checks:

* Validation of IP hash length and content
* Prevention of duplicate hash registrations
* Expiration date checks to ensure they are set in the future
* Ownership checks for transfers and registration extensions
* Input validation for IP IDs to ensure they are within valid range

## Author

Blessing Eze