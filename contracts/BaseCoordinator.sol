pragma solidity 0.5.16;
pragma experimental ABIEncoderV2;

import "./Owned.sol";
import "./MixinResolver.sol";
import "./interfaces/IERC20.sol";
import "./interfaces/ILock.sol";
import "./Lock.sol";

contract BaseCoordinator is Lock, Owned, MixinResolver {

    bytes32 public constant CONTRACT_MAI_PROXY = "MAI_PROXY";
    bytes32 public constant CONTRACT_LOCK = "LockCoordinatorsV1";
    bool public  staking_initialized;

    struct CoordinatorInfo {
        string name; // Change to string
        address ownerAddress;
        address[] functionAddresses;
    }

    struct Nominee {
        CoordinatorInfo info;
        uint256 voteCount;
        uint256 nominationTime;
    }

    CoordinatorInfo[] public coordinators;
    Nominee[] public nominees;
    uint256 public timeVotingNewCoordinator;
    uint256 public percentageGettingElected;

    constructor(
        address _lockOwner,
        uint _unlockTime,
        address _owner,
        address _resolver
    )
    Lock( _lockOwner, _unlockTime) // Initialize Lock
    Owned(_owner) // Initialize Owned
    MixinResolver(_resolver) // Initialize MixinResolver
    public
    {
        staking_initialized = false;
    }

    function _initialize() public onlyOwner {
        require(!staking_initialized, "Already initialized");
        token = maiTokenContract();
        staking_initialized = true;
    }

    function resolverAddressesRequired() public view returns (bytes32[] memory addresses) {
        addresses = new bytes32[](1);
        addresses[0] = CONTRACT_MAI_PROXY;
        addresses[1] = CONTRACT_LOCK;
    }

    function maiTokenContract() internal view returns (IERC20) {
        return IERC20(requireAndGetAddress(CONTRACT_MAI_PROXY));
    }

    function coordinatorLockContract() internal view returns (ILock) {
        return ILock(requireAndGetAddress(CONTRACT_LOCK));
    }

    function addCoordinator(string memory _name, address _ownerAddress, address[] memory _functionAddresses) public onlyOwner {
        require(_ownerAddress != address(0), "Owner address cannot be zero");
        require(bytes(_name).length > 0, "Name cannot be empty");

        CoordinatorInfo memory newCoordinator = CoordinatorInfo({
            name: _name,
            ownerAddress: _ownerAddress,
            functionAddresses: _functionAddresses
        });
        coordinators.push(newCoordinator);
    }

    function getCoordinatorByAddress(address _ownerAddress) public view returns (string memory, address, address[] memory) {
        for (uint i = 0; i < coordinators.length; i++) {
            if (coordinators[i].ownerAddress == _ownerAddress) {
                return (coordinators[i].name, coordinators[i].ownerAddress, coordinators[i].functionAddresses);
            }
        }
        revert("Coordinator not found");
    }

    function getCoordinatorByName(string memory _name) public view returns (string memory, address, address[] memory) {
        for (uint i = 0; i < coordinators.length; i++) {
            if (keccak256(abi.encodePacked(coordinators[i].name)) == keccak256(abi.encodePacked(_name))) {
                return (coordinators[i].name, coordinators[i].ownerAddress, coordinators[i].functionAddresses);
            }
        }
        revert("Coordinator not found");
    }

    // ... rest of the contract ...
}