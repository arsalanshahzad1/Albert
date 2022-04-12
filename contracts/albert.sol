// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";
import "./Paymentsplitter.sol";

contract NFT is ReentrancyGuard, Ownable{
    
     
    uint256 public current_supply;
    uint256 public maxSupply ;
    uint256 public SalePrice  ;
    address payable receiver ;

    mapping(address => uint256) public addressMintedBalance;

     constructor(address payable pay_)  {
       receiver = pay_;
    }

    function getAmount(uint256 amount) public view 
        returns ( uint256 )
    {
        return (amount * SalePrice ) ;
    }
    
    function buyToken(uint256 amount) public nonReentrant payable {
        
        uint256 weiAmount = getAmount(amount);
        require (weiAmount ==  msg.value,"please provide exact amount for one Token");
        // require (current_supply+amount <=  maxSupply,"entered ammount exceed max supply");
        current_supply+=amount;
        (receiver).transfer(msg.value);
        addressMintedBalance[msg.sender] += amount;
    }

    

    function setcurrent_supply(uint256 _current_supply) public onlyOwner {
        current_supply =_current_supply;
    }

    function setmaxSupply(uint256 _maxSupply) public onlyOwner {
       maxSupply =_maxSupply;
    }

    function setSalePrice(uint256 _SalePrice) public onlyOwner {
       SalePrice =_SalePrice;
    }
    function getaddressMintedBalance (address _addressMintedBalance) public view returns (uint256){
        return addressMintedBalance[_addressMintedBalance] ;
    }



}

    