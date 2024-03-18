// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.20;

import "./ZOKSHandler.sol";

contract SubContract is SubContractHandler {

    constructor(
        uint32 _levels,
        IHasher _hasher,
        IVerifier _verifier,
        ISubToken _subContract

    ) SubContractHandler(_levels, _hasher, _verifier, _subContract) {}

    function createSubscription(uint256 _commitment) external {
        _createSubscription(bytes32(_commitment));
    }

    function withdrawMoney(
        uint[2] memory _proof_a,
        uint[2][2] memory _proof_b,
        uint[2] memory _proof_c,
        uint256 _nullifierHash,
        uint256 _root
    ) external{
         return _renewelSubscription(
            _proof_a,
            _proof_b,
            _proof_c,
            bytes32(_nullifierHash),
            bytes32(_root)
        );
    }
}
