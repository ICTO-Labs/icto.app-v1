import Connect from "@/ic/actor/Connect";
import { txtToPrincipal } from "@/utils/common";
import { walletStore } from "@/store/";
import univ3prices from "@thanpolas/univ3prices";

export const useGetPoolValue = (sqrtPriceX96, tickLower, tickUpper, liquidity, tick) => {
    console.log(sqrtPriceX96, tickLower, tickUpper, liquidity, tick);
    const [amount0Raw, amount1Raw] = univ3prices.getAmountsForLiquidityRange(
        sqrtPriceX96, // generate sqrt price for range
        univ3prices.tickMath.getSqrtRatioAtTick(tickLower), // lower tick
        univ3prices.tickMath.getSqrtRatioAtTick(tickUpper), // upper tick
        liquidity // liquidity
    );
    
    const price = univ3prices.tickPrice([8, 8], tick).toAuto({reverse: true});
    const amount0 = Number(amount0Raw) / 100_000_000;
    const amount1 = Number(amount1Raw) / 100_000_000;//ICP
    const totalValueInICP = amount0 * price + amount1;
    
    const totalValueInUSD = totalValueInICP*13.01;//x ICP Price
    return {amount0, amount1, totalValueInICP, totalValueInUSD};
}

/**
 * Retrieves the user's positions in a swap pool by principal.
 * @param {string} canisterId - The ID of the swap pool canister.
 * @returns {Promise<Array>} - A promise that resolves to an array of user positions.
 */
export const useGetPoolLP = async (canisterId) => {
    const _rs = await Connect.canister(canisterId, 'swapPool').getUserPositionsByPrincipal(txtToPrincipal(walletStore.principal));
    if(_rs && "ok" in _rs){
        return _rs.ok;
    }else{
        return [];
    }
}

/**
 * Retrieves the metadata of a swap pool canister.
 * @param {string} canisterId - The ID of the swap pool canister.
 * @returns {Promise<Object|null>} - A promise that resolves to the metadata object of the swap pool canister, or null if an error occurs.
 */
export const useGetPoolMeta = async (canisterId) => {
    try{
        const _rs = await Connect.canister(canisterId, 'swapPool').metadata();
        if(_rs && "ok" in _rs){
            console.log('_rs', _rs);
            return _rs.ok;
        }else{
            return null;
        }
    }catch(e){
        return null;
    }
}
export const useGetTokenMeta = async (canisterId) => {
    try{
        const _rs = await Connect.canister(canisterId, 'swapPool').getTokenMeta();
        console.log('_rs', _rs);
        return _rs;
    }catch(e){
        return null;
    }
}

/**
 * Approves a user's position in a swap pool.
 * @param {string} canisterId - The ID of the swap pool canister.
 * @param {number} positionId - The ID of the user's position.
 * @returns {Promise<Object|null>} - A promise that resolves to the result of the approval, or null if an error occurs.
 * @note This function requires the user to have the necessary permissions to approve the position.
 */
export const useApprovePosition = async (canisterId, positionId) => {
    try{
        const _rs = await Connect.canister(canisterId, 'swapPool').approvePosition(txtToPrincipal(walletStore.principal), Number(positionId));
        console.log('_rs', _rs); 
        return _rs;
    }catch(e){
        return null;
    }
}