pragma solidity 0.5.16;
pragma experimental ABIEncoderV2;

import "./BaseCoordinator.sol";

contract Coordinator is BaseCoordinator {

    // Constructor for the Coordinator contract
    constructor(
        address _lockOwner,
        uint _unlockTime,
        address _owner,
        address _resolver
    )
    BaseCoordinator(_lockOwner, _unlockTime, _owner, _resolver) // Initialize BaseCoordinator
    public
    {
        // Additional initialization specific to Coordinator contract (if any)
    }

    function initialize() public {
        _initialize();
    }

    function nominateSelfAsCoordinator(
        string memory _name,
        address[] memory _functionAddresses,
        uint _amount) public {
        uint256 totalSupply = token.totalSupply();
        uint256 requiredTokenAmount = totalSupply.mul(nominationPercentage).div(100);

        require(token.balanceOf(msg.sender) >= requiredTokenAmount, "Insufficient token balance to nominate");
        require(_amount >= requiredTokenAmount, "Staked amount does not meet the required threshold");

        // Directly call the deposit function
        deposit(_amount);

        // Create new coordinator information with the staked amount
        CoordinatorInfo memory newCoordinator = CoordinatorInfo({
            name: _name,
            ownerAddress: msg.sender,
            functionAddresses: _functionAddresses,
            stakedAmount: _amount  // Storing the staked amount
        });

        coordinators.push(newCoordinator);

        // Emit an event or other logic as necessary
    }

    function addCoordinator(
        string memory _name,
        address _ownerAddress,
        address[] memory _functionAddresses,
        uint _stakedAmount) public onlyOwner {
        // existing checks and logic...

        CoordinatorInfo memory newCoordinator = CoordinatorInfo({
            name: _name,
            ownerAddress: _ownerAddress,
            functionAddresses: _functionAddresses,
            stakedAmount: _stakedAmount // Optional: Include this if staking is required
        });

        coordinators.push(newCoordinator);
    }

    modifier onlyCoordinator() {
        require(isCoordinatorAddress(msg.sender), "Caller is not a coordinator");
        _;
    }




}
