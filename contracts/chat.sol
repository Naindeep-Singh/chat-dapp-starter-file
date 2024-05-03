// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract chat{
    
    struct user{
        string name;
        friend[] friendList;
    }

    struct friend{
        address publickey;
        string name;
    }

    struct message{
        address sender;
        uint256 timestamp;
        string msg;
    }

    struct AllUsersStruck{
        string name;
        address accountAddress;
    }

    AllUsersStruck[] getAllUsers;

    mapping (address => user) userList;
    mapping (bytes32 => message[]) allMessages;

    function checkUserExist(address publickey) public view returns (bool){
        return bytes(userList[publickey].name).length > 0;
    }

    function createAccount(string calldata name ) external{
        require(checkUserExist(msg.sender) == false, "user already exists");
        require(bytes(name).length > 0, "username cannot be empty");
        userList[msg.sender].name = name;

        getAllUsers.push(AllUsersStruck(name, msg.sender));
    }

    function getUsername(address publickey) external view returns(string memory){
        require(checkUserExist(publickey), "user is not registered");
        return userList[publickey].name;
    }

    function addfriend(address friend_key, string calldata name) external{
        require(checkUserExist(msg.sender), "create account first");
        require(checkUserExist(friend_key), "user is not registered");
        require(msg.sender != friend_key, "user cannot add themselves as friends");
        require(checkAlreadyFriends(msg.sender, friend_key) == false, "these users are already friends");

        _addFriend(msg.sender, friend_key, name);
        _addFriend(friend_key, msg.sender, userList[msg.sender].name);
    }

    function checkAlreadyFriends(address pubkey1, address pubkey2) internal view returns(bool){

        if (userList[pubkey1].friendList.length > userList[pubkey2].friendList.length){
            address tmp = pubkey1;
            pubkey1 = pubkey2;
            pubkey2 = tmp;
        }

        for(uint256 i = 0; i< userList[pubkey1].friendList.length; i++){
            if(userList[pubkey1].friendList[i].publickey == pubkey2) return true;
        }
        return false;
    }

    function _addFriend(address me, address friend_key, string memory name) internal{
        friend memory newFriend = friend(friend_key, name);
        userList[me].friendList.push(newFriend);
    }

    //find all my friends
    function getmyFriendlist() external view returns(friend[] memory){
        return userList[msg.sender].friendList;
    }

    function _getChatcode(address pubkey1, address pubkey2) internal pure returns(bytes32){
        if(pubkey1 < pubkey2){
            return keccak256(abi.encodePacked(pubkey1, pubkey2));
        } else 
        return keccak256(abi.encodePacked(pubkey2, pubkey1));
    }

    function sendMessage(address friend_key, string calldata _msg) external{
        require(checkUserExist(msg.sender), "create account first");
        require(checkUserExist(friend_key), "user is not registered");
        require(checkAlreadyFriends(msg.sender, friend_key), "you're not friends yet");

        bytes32 chatCode = _getChatcode(msg.sender, friend_key);
        message memory newMsg = message(msg.sender, block.timestamp, _msg);
        allMessages[chatCode].push(newMsg);
    }
    function readMessage(address friend_key) external view returns(message[] memory){
        bytes32 chatCode = _getChatcode(msg.sender, friend_key);
        return allMessages[chatCode];
    }

    function getAllAppuser() public view returns (AllUsersStruck[] memory){
        return getAllUsers;
        
    }


}