export const setWalletToken = (assets)=>{
    localStorage.setItem("WALLET_TOKEN", JSON.stringify(assets))
}
export const getWalletToken = ()=>{
    return JSON.parse(localStorage.getItem('WALLET_TOKEN'));
}

export const setLocaleStorage = (locale) => {
    localStorage.setItem('LANGUAGE_LOCALE', locale);
};

export const getLocaleStorage = () => {
    const locale = localStorage.getItem('LANGUAGE_LOCALE');
    return locale ? locale : 'en';
};

export const setUserInfoStorage = (user) => {
    if(user.owner!==""){
        localStorage.setItem(`USER_${user.owner.toUpperCase()}`, JSON.stringify(user));
    }
};
export const getUserInfoStorage = (principal) => {
    const info = localStorage.getItem(`USER_${principal.toUpperCase()}`);
    if (null == info) return null;
    try {
        const read = JSON.parse(info);
        return read;
    } catch (e) {
        console.error(`read user ${principal} info failed:`, e);
    }
    return null;
};

export const deleteUserInfoStorage = (principal)=> {
    console.log("deleteUser",principal)
    localStorage.removeItem(`USER_${principal.toUpperCase()}`);
};

export const setWalletInfoStorage = (walletInfo) => {
    sessionStorage.setItem('WALLET_INFO', JSON.stringify(walletInfo));
};
export const getWalletInfoStorage = () => {
    const result = sessionStorage.getItem('WALLET_INFO');
    if (result) {
        return JSON.parse(result);
    }
    return null;
};
export const deleteWalletInfoStorage = () => {
    sessionStorage.removeItem('WALLET_INFO');
};