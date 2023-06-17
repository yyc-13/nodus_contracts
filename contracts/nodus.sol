// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract NodusVault is Ownable {
    IERC20 public usdc;

    constructor(address _usdcAddress) {
        usdc = IERC20(_usdcAddress);
    }

    function withdraw(uint _amount) external onlyOwner {
        require(usdc.transfer(owner(), _amount), "Withdrawal failed");
    }
}

contract Nodus is Ownable {
    IERC20 public usdc;
    NodusVault public vault;

    struct Content {
        string id;
        uint price;
        address payable creator;
    }

    struct Membership {
        string id;
        uint price;
        address payable creator;
    }

    mapping(string => Content) public contents;
    mapping(string => Membership) public memberships;

    uint constant PROCESSING_FEE_PERCENT = 250;

    event PurchaseContent(string contentId, address buyer);
    event PurchaseMembership(string membershipId, address buyer);
    event Donation(string contentId, address donor, uint amount);

    constructor(address _usdcAddress, address _vaultAddress) {
        usdc = IERC20(_usdcAddress);
        vault = NodusVault(_vaultAddress);
    }

    function createContent(string memory _id, uint _price) public {
        contents[_id] = Content(_id, _price, payable(msg.sender));
    }

    function createMembership(string memory _id, uint _price) public {
        memberships[_id] = Membership(_id, _price, payable(msg.sender));
    }

    function purchaseContent(string memory _id) public {
        Content memory content = contents[_id];
        uint price = content.price;
        require(
            usdc.transferFrom(msg.sender, address(this), price),
            "Not enough USDC provided."
        );

        uint fee = (price * PROCESSING_FEE_PERCENT) / 10000;
        uint amountToCreator = price - fee;

        require(
            usdc.transfer(content.creator, amountToCreator),
            "Transfer to creator failed."
        );
        require(
            usdc.transfer(address(vault), fee),
            "Transfer to vault failed."
        );

        emit PurchaseContent(_id, msg.sender);
    }

    function purchaseMembership(string memory _id) public {
        Membership memory membership = memberships[_id];
        uint price = membership.price;
        require(
            usdc.transferFrom(msg.sender, address(this), price),
            "Not enough USDC provided."
        );

        uint fee = (price * PROCESSING_FEE_PERCENT) / 10000;
        uint amountToCreator = price - fee;

        require(
            usdc.transfer(membership.creator, amountToCreator),
            "Transfer to creator failed."
        );
        require(
            usdc.transfer(address(vault), fee),
            "Transfer to vault failed."
        );

        emit PurchaseMembership(_id, msg.sender);
    }

    function donateContent(string memory _id, uint _amount) public {
        Content memory content = contents[_id];

        // transfer the donation from the donor to the contract
        require(
            usdc.transferFrom(msg.sender, address(this), _amount),
            "Transfer failed"
        );

        // calculate the processing fee and the amount that goes to the creator
        uint fee = (_amount * PROCESSING_FEE_PERCENT) / 10000;
        uint amountToCreator = _amount - fee;

        // transfer the amount to the creator and the fee to the vault
        require(
            usdc.transfer(content.creator, amountToCreator),
            "Transfer to creator failed"
        );
        require(usdc.transfer(address(vault), fee), "Transfer to vault failed");

        // emit the Donation event
        emit Donation(_id, msg.sender, _amount);
    }
}
