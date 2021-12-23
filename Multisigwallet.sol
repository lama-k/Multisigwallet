pragma solidity ^0.8.7;
pragma abicoder v2;
import "./Ownable.sol";
import "./Destroyable.sol";

contract MultisigWallet is Ownable,Destroyable{
    uint requiredApprovals;
    uint requestNumber;
    mapping(address => mapping(uint => bool)) approvals;
    mapping(address => uint) balance;
    mapping(uint => Transfer) transferRequests;
    address[] owners;
     //emit an event on transfer creation
    event TransferRequest(uint _id,address recipient,uint _amount);
    event TransferApproved(uint _tranferId);
    struct Transfer{
        uint id;
        uint amount;
        uint approvalCount;
        address recipient;
        address requestCreator;
    }

    modifier  ownlyOwners{
        bool isowner = false;
        for(uint i = 0;i < owners.length; i++){
            if(owners[i] == msg.sender){
                isowner = true;
            }
        }    
        require(isowner == true,"must be a owner");
        _;
    }
    constructor(uint _requiredApprovals, address[] memory _owners){
        requiredApprovals = _requiredApprovals;
        requestNumber = 0;
        for(uint i = 0;i < _owners.length; i++){
            owners.push(_owners[i]);
        }
    }

    function deposit() public payable ownlyOwners{
         balance[msg.sender] += msg.value;
    }

    function createTransfer(uint _amount,address _recipient) public  ownlyOwners{
        // check for the owners amount
            require(balance[msg.sender] >= _amount,"No enough funds");
            // increment the request number and use it as request id and key in the mapping
            requestNumber++;
            Transfer storage newtransfer = transferRequests[requestNumber];
            // set the transfer request parameters
            newtransfer.id = requestNumber;
            newtransfer.amount = _amount;
            newtransfer.recipient = _recipient;
            newtransfer.approvalCount = 0;
            newtransfer.requestCreator = msg.sender;
            emit TransferRequest(requestNumber,_recipient,_amount);
    }

     function approveTransfer(uint _transferID) public ownlyOwners{
        Transfer storage transferToApprove = transferRequests[_transferID];
        require(msg.sender != transferToApprove.requestCreator,"you cannot approve your transfer that you created");
        require(transferToApprove.approvalCount < requiredApprovals,"Transfer already approved");
        require(approvals[msg.sender][transferToApprove.id] != true,"you have already approve transfer");
        approvals[msg.sender][transferToApprove.id] = true;
        transferToApprove.approvalCount++;
        emit TransferApproved(transferToApprove.id);
     }

     function sendTransfer(uint _transferID)public ownlyOwners{
        Transfer storage transferToSend = transferRequests[_transferID];
        require(msg.sender == transferToSend.requestCreator,"you can only send your own created transfers");
        require(transferToSend.approvalCount == requiredApprovals,"Transfer must be approved by all approvals");
        require(balance[transferToSend.requestCreator] >= transferToSend.amount,"No enough funds");
        balance[transferToSend.requestCreator] -= transferToSend.amount;
        payable(transferToSend.recipient).transfer(transferToSend.amount);
     }

    function getApproval(uint _index) public view returns(bool){
        return approvals[msg.sender][_index];
    }

    function getWalletBalance() public view returns(uint){
        return address(this).balance;
    }

    function getBalance() public view returns(uint){
        return balance[msg.sender];
    }

    function getowners() public view returns(address ){
        return owners[0];
    }
}
