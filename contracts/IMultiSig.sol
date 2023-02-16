// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface IMultiSig {

    struct TxData {
        address to;
        bytes data;
        uint256 value;
        uint8 noOfConfirmations;
        bool isSent;
    }

    function  createTransaction(address _to, uint256 _value,  bytes calldata _data) external;


    function signTransaction(uint256 _TxID) external;


    function getAdmins() external view returns (address[] memory);

    event Log(bool _success, bytes _data, string _message);
}