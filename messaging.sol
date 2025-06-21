// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract MessageStorage {
    struct Message {
        address sender;
        address receiver;
        string cid;        
        uint256 timestamp;
        bool deleted; 
    }

    // Mapping from chat ID (hashed pair of addresses) to array of messages
    mapping(bytes32 => Message[]) private conversations;

    event MessageSent(
        address indexed sender,
        address indexed receiver,
        string cid,
        uint256 timestamp
    );

    event MessageDeleted(
        address indexed sender,
        address indexed receiver,
        uint256 index
    );

    // Helper to get chat ID from two addresses (order independent)
    function _getChatId(address a, address b) internal pure returns (bytes32) {
        return a < b
            ? keccak256(abi.encodePacked(a, b))
            : keccak256(abi.encodePacked(b, a));
    }

    // Send message by providing receiver and cid
    function sendMessage(address _receiver, string calldata _cid) external {
        require(_receiver != address(0), "Invalid receiver");
        require(bytes(_cid).length > 0, "CID required");

        bytes32 chatId = _getChatId(msg.sender, _receiver);

        conversations[chatId].push(
            Message({
                sender: msg.sender,
                receiver: _receiver,
                cid: _cid,
                timestamp: block.timestamp,
                deleted: false
            })
        );

        emit MessageSent(msg.sender, _receiver, _cid, block.timestamp);
    }

    // Get all messages between msg.sender and another user
    function getMessages(address _otherUser) external view returns (Message[] memory) {
        bytes32 chatId = _getChatId(msg.sender, _otherUser);
        return conversations[chatId];
    }

    function deleteMessage(address _receiver, uint256 index) external {
        bytes32 chatId = _getChatId(msg.sender, _receiver);
        require(index < conversations[chatId].length, "Invalid index");
        Message storage msgToDelete = conversations[chatId][index];
        require(msgToDelete.sender == msg.sender, "Not your message");

        msgToDelete.deleted = true;

        emit MessageDeleted(msg.sender, _receiver, index);
    }
}

