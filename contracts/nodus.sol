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
    mapping(address => bool) public registeredUsers;

    uint constant PROCESSING_FEE_PERCENT = 250;

    event PurchaseContent(string contentId, address buyer);
    event PurchaseMembership(string membershipId, address buyer);
    event Donation(string contentId, address donor, uint amount);

    modifier onlyRegisteredUser() {
        require(registeredUsers[msg.sender] == true, "Not a registered user");
        _;
    }

    constructor(address _usdcAddress, address _vaultAddress) {
        usdc = IERC20(_usdcAddress);
        vault = NodusVault(_vaultAddress);
    }

    function registerUser(address _user) external onlyOwner {
        registeredUsers[_user] = true;
    }

    function createContent(
        string memory _id,
        uint _price
    ) public onlyRegisteredUser {
        require(
            contents[_id].creator == address(0),
            "Content ID already exists"
        );
        contents[_id] = Content(_id, _price, payable(msg.sender));
    }

    function createMembership(
        string memory _id,
        uint _price
    ) public onlyRegisteredUser {
        require(
            memberships[_id].creator == address(0),
            "Membership ID already exists"
        );
        memberships[_id] = Membership(_id, _price, payable(msg.sender));
    }

    function updateContentPrice(
        string memory _id,
        uint _newPrice
    ) public onlyRegisteredUser {
        require(
            contents[_id].creator == msg.sender,
            "Only the content creator can update the price"
        );
        contents[_id].price = _newPrice;
    }

    function updateMembershipPrice(
        string memory _id,
        uint _newPrice
    ) public onlyRegisteredUser {
        require(
            memberships[_id].creator == msg.sender,
            "Only the membership creator can update the price"
        );
        memberships[_id].price = _newPrice;
    }

    function deleteContent(string memory _id) public onlyRegisteredUser {
        require(
            contents[_id].creator == msg.sender,
            "Only the content creator can delete this content"
        );
        delete contents[_id];
    }

    function deleteMembership(string memory _id) public onlyRegisteredUser {
        require(
            memberships[_id].creator == msg.sender,
            "Only the membership creator can delete this membership"
        );
        delete memberships[_id];
    }

    function purchaseContent(string memory _id) public onlyRegisteredUser {
        require(
            usdc.allowance(msg.sender, address(this)) >= contents[_id].price,
            "Not enough USDC allowance"
        );
        _purchaseContent(_id);
    }

    function purchaseMembership(string memory _id) public onlyRegisteredUser {
        require(
            usdc.allowance(msg.sender, address(this)) >= memberships[_id].price,
            "Not enough USDC allowance"
        );
        _purchaseMembership(_id);
    }

    function donateContent(
        string memory _id,
        uint _amount
    ) public onlyRegisteredUser {
        require(
            usdc.allowance(msg.sender, address(this)) >= _amount,
            "Not enough USDC allowance"
        );
        require(contents[_id].creator != address(0), "Content does not exist");
        _donateContent(_id, _amount);
    }

    function _purchaseContent(string memory _id) private {
        _purchase(_id, contents[_id].creator, contents[_id].price);
        emit PurchaseContent(_id, msg.sender);
    }

    function _purchaseMembership(string memory _id) private {
        _purchase(_id, memberships[_id].creator, memberships[_id].price);
        emit PurchaseMembership(_id, msg.sender);
    }

    function _purchase(
        string memory _id,
        address payable _recipient,
        uint _price
    ) private {
        require(
            usdc.transferFrom(msg.sender, address(this), _price),
            "Not enough USDC provided"
        );

        uint fee = (_price * PROCESSING_FEE_PERCENT) / 10000;
        uint amountToRecipient = _price - fee;

        require(
            usdc.transfer(_recipient, amountToRecipient),
            "Transfer to recipient failed"
        );
        require(usdc.transfer(address(vault), fee), "Transfer to vault failed");
    }

    function _donateContent(string memory _id, uint _amount) private {
        _donate(_id, contents[_id].creator, _amount);
        emit Donation(_id, msg.sender, _amount);
    }

    function _donate(
        string memory _id,
        address payable _recipient,
        uint _amount
    ) private {
        require(
            usdc.transferFrom(msg.sender, address(this), _amount),
            "Transfer failed"
        );

        uint fee = (_amount * PROCESSING_FEE_PERCENT) / 10000;
        uint amountToRecipient = _amount - fee;

        require(
            usdc.transfer(_recipient, amountToRecipient),
            "Transfer to recipient failed"
        );
        require(usdc.transfer(address(vault), fee), "Transfer to vault failed");
    }
}
