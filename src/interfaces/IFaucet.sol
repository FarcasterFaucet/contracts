// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

interface IFaucet {
    /*//////////////////////////////////////////////////////////////
                                 STRUCTS
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev Claimer struct to keep track of the last period a user claimed.
     *
     * @param registeredForPeriod The period the user registered for.
     * @param latestClaimPeriod   The last period the user claimed.
     */
    struct Claimer {
        uint256 registeredForPeriod;
        uint256 latestClaimPeriod;
    }

    /**
     * @dev Period struct to keep track of the total registered users and max payout.
     *
     * @param totalRegisteredUsers The total number of users registered for the period.
     * @param maxPayout            The maximum payout for the period.
     */
    struct Period {
        uint256 totalRegisteredUsers;
        uint256 maxPayout;
    }

    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/

    /// @dev Revert when the caller does not have the authority to perform the action.
    error Unauthorized();

    /// @dev Revert when the caller must have an fid but does not have one.
    error HasNoId();

    /// @dev Revert when the caller is already registered.
    error AlreadyRegisterd();

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev Emitted when the percent per period is set.
     *
     * @param percentPerPeriod The new percent per period.
     */
    event SetPercentPerPeriod(uint256 percentPerPeriod);

    /**
     * @dev Emitted when the a claim is made for the period.
     *
     * @param claimer The address of the claimer.
     * @param periodNumber The period number.
     * @param claimerPayout The claimer's payout.
     */
    event Claim(address claimer, uint256 periodNumber, uint256 claimerPayout);

    /**
     * @dev Emitted when the a user registers for the period.
     *
     * @param sender The address of the sender.
     * @param periodNumber The period number.
     */
    event Register(address sender, uint256 periodNumber);
}
