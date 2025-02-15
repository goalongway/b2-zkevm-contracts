// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

interface ISimpleBridge{
    function deposit(address to_address, uint256 amount) external;

    function withdraw(string calldata btc_address) external payable;

    event DepositEvent(address indexed caller, address indexed to_address, uint256 amount);

    event WithdrawEvent(address indexed from_address, string btc_address, uint256 amount);
}

contract SimpleBridge is ISimpleBridge, Initializable, AccessControlUpgradeable  {

    receive() external payable {}

    bytes32 public constant ADMIN_ROLE = keccak256("admin_role");

    function initialize() public initializer {
        __AccessControl_init();
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(ADMIN_ROLE, msg.sender);
    }

    function deposit(address b2_to_address, uint256 btc_amount) external onlyRole(ADMIN_ROLE) {
        uint256 b2_amount = btc_amount * 10000000000;
        payable(b2_to_address).transfer(b2_amount);
        emit DepositEvent(msg.sender, b2_to_address, b2_amount);
    }

    function withdraw(string calldata btc_address) external payable {
        uint256 b2_amount = msg.value;
        uint256 btc_amount = b2_amount/ 10000000000;
        emit WithdrawEvent(msg.sender, btc_address, btc_amount);
    }

}

contract SimpleBridgeV2 is SimpleBridge  {

   mapping (bytes32 => bool) deposit_uuids;
   mapping (bytes32 => bool) withdraw_uuids;

   function version() external pure returns (uint256) {
      return 2;
   }

    function depositV2(bytes32 deposit_uuid, address b2_to_address, uint256 btc_amount) external onlyRole(ADMIN_ROLE) {
        require(!deposit_uuids[deposit_uuid], "non-repeatable processing");
        deposit_uuids[deposit_uuid] = true;
        uint256 b2_amount = btc_amount * 10000000000;
        payable(b2_to_address).transfer(b2_amount);
        emit DepositEvent(msg.sender, b2_to_address, b2_amount);
    }

    function withdrawV2(bytes32 withdraw_uuid, string calldata btc_address) external payable {
        require(!withdraw_uuids[withdraw_uuid], "non-repeatable processing");
        withdraw_uuids[withdraw_uuid] = true;
        uint256 b2_amount = msg.value;
        uint256 btc_amount = b2_amount/ 10000000000;
        emit WithdrawEvent(msg.sender, btc_address, btc_amount);
    }

}