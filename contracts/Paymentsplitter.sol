// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/finance/PaymentSplitter.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "hardhat/console.sol";

contract NFTpaymentSplitter is Context {
      using SafeERC20 for IERC20;

       event PayeeAdded(address account, uint256 shares);
        event PaymentReleased(address to, uint256 amount);
        event ERC20PaymentReleased(IERC20 indexed token, address to, uint256 amount);
       event PaymentReceived(address from, uint256 amount);

       uint256 private _totalShares;
         uint256 private _totalReleased;

       mapping(address => uint256) private _shares;
       mapping(address => uint256) private _released;
    address[] private _payees;

     mapping(IERC20 => uint256) private _erc20TotalReleased;
    mapping(IERC20 => mapping(address => uint256)) private _erc20Released;

    uint256[] shares_ = [50,50];
    address[] payees = [address(0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2),address(0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB)];

    constructor() payable {
    require(payees.length == shares_.length, "PaymentSplitter: payees and shares length mismatch");
        require(payees.length > 0, "PaymentSplitter: no payees");

        for (uint256 i = 0; i < payees.length; i++) {
            _addPayee(payees[i], shares_[i]);
        }
    }

    receive() external payable virtual {
        emit PaymentReceived(_msgSender(), msg.value);
    }

     function totalShares() public view returns (uint256) {
        return _totalShares;
    }

   
    function totalReleased() public view returns (uint256) {
        return _totalReleased;
    }

   

    
    function shares(address account) public view returns (uint256) {
        return _shares[account];
    }

    function released(address account) public view returns (uint256) {
        return _released[account];
    }

    
 

    function release(address payable account) payable public virtual {
        require(_shares[account] > 0, "PaymentSplitter: account has no shares");

        uint256 totalReceived = address(this).balance + totalReleased();
        uint256 payment = _pendingPayment(account, totalReceived, released(account));

        require(payment != 0, "PaymentSplitter: account is not due payment");

        _released[account] += payment;
        _totalReleased += payment;

        Address.sendValue(account, payment);
        emit PaymentReleased(account, payment);
    }

    function _pendingPayment(
        address account,
        uint256 totalReceived,
        uint256 alreadyReleased
    ) public view returns (uint256) {
        return (totalReceived * _shares[account]) / _totalShares - alreadyReleased;
    }

    function _addPayee(address account, uint256 shares) private {
        require(account != address(0), "PaymentSplitter: account is the zero address");
        require(shares > 0, "PaymentSplitter: shares are 0");
        require(_shares[account] == 0, "PaymentSplitter: account already has shares");

        _payees.push(account);
        _shares[account] = shares;
        _totalShares = _totalShares + shares;
        emit PayeeAdded(account, shares);
    }

      

   
}