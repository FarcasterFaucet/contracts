// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract Faucet is Ownable {
    uint256 public constant ONE_HUNDRED_PERCENT = 1e18;
    uint256 public constant VERIFICATION_TIMESTAMP_VARIANCE = 1 days;

    struct Claimer {
        uint256 registeredForPeriod;
        uint256 latestClaimPeriod;
    }

    struct Period {
        uint256 totalRegisteredUsers;
        uint256 maxPayout;
    }

    ERC20 public token;
    uint256 public periodLength;
    uint256 public percentPerPeriod;
    uint256 public firstPeriodStart;
    mapping(address => Claimer) public claimers;
    mapping(uint256 => Period) public periods;

    event Initialize(address token, uint256 periodLength, uint256 percentPerPeriod);
    event SetPercentPerPeriod(uint256 percentPerPeriod);
    event Claim(address claimer, uint256 periodNumber, uint256 claimerPayout);
    event Register(address sender, uint256 periodNumber);

    /**
     * @param _token Token distributed by the faucet
     * @param _periodLength Length of each distribution period
     * @param _percentPerPeriod Percent of total balance distributed each period
     */
    constructor(ERC20 _token, uint256 _periodLength, uint256 _percentPerPeriod) public {
        require(_periodLength > 0, "Invalid period lenght");
        require(_percentPerPeriod <= ONE_HUNDRED_PERCENT, "Invalid period percentage");

        token = _token;
        periodLength = _periodLength;
        percentPerPeriod = _percentPerPeriod;
        firstPeriodStart = block.timestamp;

        emit Initialize(address(_token), _periodLength, _percentPerPeriod);
    }

    /**
     * @notice Set percent per period
     * @param _percentPerPeriod Percent of total balance distributed each period
     */
    function setPercentPerPeriod(uint256 _percentPerPeriod) public onlyOwner {
        require(_percentPerPeriod <= ONE_HUNDRED_PERCENT, "Invalid period percentage");

        percentPerPeriod = _percentPerPeriod;
        emit SetPercentPerPeriod(_percentPerPeriod);
    }

    /**
     * @notice Register for the next period and claim if registered for the current period.
     */
    function claimAndOrRegister() public {
        Claimer storage claimer = claimers[msg.sender];
        require(claimer.registeredForPeriod <= getCurrentPeriod(), "Already registered");

        uint256 currentPeriod = getCurrentPeriod();
        if (_canClaim(claimer, currentPeriod)) {
            _claim(claimer, currentPeriod);
        }

        uint256 nextPeriod = getCurrentPeriod() + 1;
        claimer.registeredForPeriod = nextPeriod;
        periods[nextPeriod].totalRegisteredUsers++;

        emit Register(msg.sender, nextPeriod);
    }

    /**
     * @notice Claim from the faucet without registering for the next period.
     */
    function claim() public {
        Claimer storage claimer = claimers[msg.sender];
        uint256 currentPeriod = getCurrentPeriod();
        require(_canClaim(claimer, currentPeriod), "Cannot calim");

        _claim(claimer, currentPeriod);
    }

    /**
     * @notice Withdraw the faucets entire balance of the faucet distributed token
     * @param _to Address to withdraw to
     */
    function withdrawDeposit(address _to) public onlyOwner {
        token.transfer(_to, token.balanceOf(address(this)));
    }

    /**
     * @notice Get the current period number
     */
    function getCurrentPeriod() public view returns (uint256) {
        return (block.timestamp - firstPeriodStart) / periodLength;
    }

    /**
     * @notice Get a specific periods individual payouts. For future and uninitialised periods with 0 registered
     *         users it will return 0
     * @param _periodNumber Period number
     */
    function getPeriodIndividualPayout(uint256 _periodNumber) public view returns (uint256) {
        Period storage period = periods[_periodNumber];
        return _getPeriodIndividualPayout(period);
    }

    function _canClaim(Claimer storage claimer, uint256 currentPeriod) internal view returns (bool) {
        bool userRegisteredCurrentPeriod = claimer.registeredForPeriod == currentPeriod;
        bool userYetToClaimCurrentPeriod = claimer.latestClaimPeriod < currentPeriod;

        return userRegisteredCurrentPeriod && userYetToClaimCurrentPeriod;
    }

    function _claim(Claimer storage _claimer, uint256 _currentPeriod) internal {
        Period storage period = periods[_currentPeriod];
        uint256 faucetBalance = token.balanceOf(address(this));
        require(faucetBalance > 0, "Faucet balance is zero");

        // Save maxPayout so every claimer gets the same payout amount.
        if (period.maxPayout == 0) {
            period.maxPayout = _getPeriodMaxPayout(faucetBalance);
        }

        uint256 claimerPayout = _getPeriodIndividualPayout(period);

        token.transfer(msg.sender, claimerPayout);

        _claimer.latestClaimPeriod = _currentPeriod;

        emit Claim(msg.sender, _currentPeriod, claimerPayout);
    }

    function _getPeriodMaxPayout(uint256 _faucetBalance) internal view returns (uint256) {
        return _faucetBalance.mul(percentPerPeriod).div(ONE_HUNDRED_PERCENT);
    }

    function _getPeriodIndividualPayout(Period storage period) internal view returns (uint256) {
        if (period.totalRegisteredUsers == 0) {
            return 0;
        }

        uint256 periodMaxPayout =
            period.maxPayout == 0 ? _getPeriodMaxPayout(token.balanceOf(address(this))) : period.maxPayout;

        return periodMaxPayout.div(period.totalRegisteredUsers);
    }
}
