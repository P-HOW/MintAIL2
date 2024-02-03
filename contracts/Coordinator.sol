pragma solidity 0.5.16;
pragma experimental ABIEncoderV2;

import "./Owned.sol";
import "./MixinResolver.sol";

contract Coordinator is Owned, MixinResolver {

    bytes32 private constant CONTRACT_MAI = "MAI";

    struct CoordinatorInfo {
        bytes name;
        address ownerAddress;
        address[] functionAddresses;
    }

    CoordinatorInfo[] public coordinators;

    constructor(address _owner, address _resolver) public Owned(_owner) MixinResolver(_resolver) {}

    function resolverAddressesRequired() public view returns (bytes32[] memory addresses) {
        addresses = new bytes32[](1);
        addresses[0] = CONTRACT_MAI;
    }

    function addCoordinator(bytes memory _name, address _ownerAddress, address[] memory _functionAddresses) public onlyOwner {
        require(_ownerAddress != address(0), "Owner address cannot be zero");
        require(_name.length > 0, "Name cannot be empty");

        CoordinatorInfo memory newCoordinator = CoordinatorInfo({
            name: _name,
            ownerAddress: _ownerAddress,
            functionAddresses: _functionAddresses
        });
        coordinators.push(newCoordinator);
    }

    function getCoordinatorByAddress(address _ownerAddress) public view returns (bytes memory, address, address[] memory) {
        for (uint i = 0; i < coordinators.length; i++) {
            if (coordinators[i].ownerAddress == _ownerAddress) {
                return (coordinators[i].name, coordinators[i].ownerAddress, coordinators[i].functionAddresses);
            }
        }
        revert("Coordinator not found");
    }

    function getCoordinatorByName(bytes memory _name) public view returns (bytes memory, address, address[] memory) {
        for (uint i = 0; i < coordinators.length; i++) {
            if (keccak256(coordinators[i].name) == keccak256(_name)) {
                return (coordinators[i].name, coordinators[i].ownerAddress, coordinators[i].functionAddresses);
            }
        }
        revert("Coordinator not found");
    }

    function isCoordinatorAddress(address _address) public view returns (bool) {
        for (uint i = 0; i < coordinators.length; i++) {
            // Check if the address is the owner address of a coordinator
            if (coordinators[i].ownerAddress == _address) {
                return true;
            }

            // Check if the address is one of the function addresses of a coordinator
            for (uint j = 0; j < coordinators[i].functionAddresses.length; j++) {
                if (coordinators[i].functionAddresses[j] == _address) {
                    return true;
                }
            }
        }
        return false; // Address not found in any coordinators
    }

    function getCoordinatorsCount() public view returns (uint) {
        return coordinators.length;
    }





    // Additional functions...
}
