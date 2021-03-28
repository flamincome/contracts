pragma solidity ^0.6.2;

interface MetaCurvePools {
    function add_liquidity(address _pool, uint256[4] calldata _deposit_amounts, uint256 _min_mint_amount) external;
    function calc_withdraw_one_coin(address _pool, uint256 _token_amount, int128 i) external view returns (uint256);
    function remove_liquidity_one_coin(address _pool, uint256 _token_amount, int128 i, uint256 min_amount) external;
}