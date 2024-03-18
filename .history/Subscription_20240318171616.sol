// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.20;

import "./MerkleTreeWithHistory.sol";

interface IVerifier {

    function verifyProof(
        uint[2] memory a,
        uint[2][2] memory b,
        uint[2] memory c,
        uint[2] memory input
    ) external pure returns (bool r);

}

interface ISubToken {
    function directTransfer(address recipient, uint256 amount) external;
}

contract SubContractHandler is MerkleTreeWithHistory{

    mapping(bytes32 => bool) public commitments;
    mapping(bytes32 => bool) public isValid; 
    mapping(bytes32 => uint8) public subStart;
    mapping(bytes32 => uint256) public TTL; // amount money deposited


    ISubToken public subContract;
    IVerifier public immutable verifier;

    event Commit(
        bytes32 indexed commitment,
        uint32 leafIndex,
        uint256 timestamp
    );

    constructor(
        uint32 _levels,
        IHasher _hasher,
        IVerifier _verifier,
        ISubToken _subContract

    ) MerkleTreeWithHistory(_levels, _hasher) {
        verifier = _verifier;
        subContract = _subContract;

    }

    function _createSubscription(bytes32 _commitment) internal {
        require(!commitments[_commitment], "The commitment has been submitted");

        commitments[_commitment] = true;

        uint32 insertedIndex = _insert(_commitment);

        emit Commit(_commitment, insertedIndex, block.number);
    }

    function _renewelSubscription(
        uint[2] memory _proof_a,
        uint[2][2] memory _proof_b,
        uint[2] memory _proof_c,
        bytes32 _nullifierHash,
        bytes32 _root
    ) internal {
        require(isKnownRoot(_root), "Cannot find your merkle root");
        require(
            verifier.verifyProof(
                _proof_a,
                _proof_b,
                _proof_c,
                [uint256(_nullifierHash), uint256(_root)]
            ),
            "Invalid proof"
        );


        if(subStart[_nullifierHash]!= 0){ // Not the first time
            subContract.directTransfer(msg.sender, 1 * 10**18);

            // require(tokenContract.transfer(msg.sender, 1 * 10**18), "Token transfer failed");
            subStart[_nullifierHash] -= 1;
            TTL[_nullifierHash] += 30 * 3600 * 24;
        }
        else{
            require(!isValid[_nullifierHash],"Subscription is over" );
            // require(tokenContract.transferFrom(address(tokenContract), msg.sender, 1 * 10**18), "Token transfer failed");
            subContract.directTransfer(msg.sender, 1 * 10**18);
            isValid[_nullifierHash] = true;
            subStart[_nullifierHash] = 11;
            TTL[_nullifierHash] = block.timestamp + 30 * 3600 * 24 * 12;
        }

        // payable(recipient).transfer(boxAmount[_nullifierHash]);
        
    }
    

    function uintToString(uint v) internal pure returns (string memory) {
        uint maxlength = 100;
        bytes memory reversed = new bytes(maxlength);
        uint i = 0;
        while (v != 0) {
            uint remainder = v % 10;
            v = v / 10;
            reversed[i++] = bytes1(uint8(48 + remainder));
        }
        bytes memory s = new bytes(i);
        for (uint j = 0; j < i; j++) {
            s[j] = reversed[i - 1 - j];
        }

        return string(s);
    }

}