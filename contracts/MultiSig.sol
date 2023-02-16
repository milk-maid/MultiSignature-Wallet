// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import {IMultiSig} from "./IMultiSig.sol";

contract MultiSig is IMultiSig {
    constructor(address[] memory _admins, uint8 _noOfConfirmation) {
        uint256 adminSize = _admins.length;
        require(adminSize >= 3, "A minimum of 3 Admins is required");
        require(_noOfConfirmation >= 2 && _noOfConfirmation < adminSize);
        admins_ = _admins;
        for(uint8 i; i < adminSize; i++){
            isAdmin[_admins[i]] = true;
        }
        noOfConfirmation = _noOfConfirmation;
    }

    /// @dev This is the list of admins
    address[] internal admins_;
    uint8 private noOfConfirmation;

    /// @dev This is the number of transactions created in the smart contract
    uint256 private TxNonce;
    
    /// @dev This maps a Tx ID to the Tx Data stored in the Tx Mempool
    mapping (uint256 => TxData) private _TxMempool;

    /// @dev It checks if an address is an Admin
    mapping (address => bool) internal isAdmin;

    /// @dev TxId => Owner Address => hasSigned
    mapping(uint256 => mapping(address => bool)) internal hasSigned;

    function  createTransaction(address _to, uint256 _value,  bytes calldata _data) external onlyAdmins {
        TxData storage txData = _TxMempool[TxNonce];

        txData.to = _to;
        txData.value = _value;
        txData.data = _data;
        txData.noOfConfirmations = 1;

        hasSigned[TxNonce][msg.sender] = true;

        TxNonce += 1;
    }

    function signTransaction(uint256 _TxID) external onlyAdmins {
        require(!hasSigned[_TxID][msg.sender], "You have already signed this transaction");
        TxData storage signTx = _TxMempool[_TxID];
        signTx.noOfConfirmations += 1;
        if(signTx.noOfConfirmations >= noOfConfirmation){
            sendTransaction_(_TxID);
        }
    }

    function sendTransaction_(uint256 _TxID) private returns (bool success,bytes memory data){
        TxData storage sentTx = _TxMempool[_TxID];
        (success,data) = sentTx.to.call{value: sentTx.value}(sentTx.data);
        sentTx.isSent = success;
        if (success) { 
            emit Log(success, data, "Transaction has been sent"); 
        }
    }





    function getAdmins() public view returns (address[] memory admins) {
        admins = admins_;
    }

    modifier onlyAdmins {
        require(isAdmin[msg.sender], "Only an Admin can create a Transaction");
        _;        
    }

}