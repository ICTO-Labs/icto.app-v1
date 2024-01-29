export const formatPoolMeta = (meta) => {
    let res = {};
    const formatToken = (token) => {
        let result = {};
        token.forEach((item) => {
            if (Array.isArray(item) && item.length === 2 && typeof item[1] === "object") {
                for (let valueType in item[1]) {
                    result[item[0]] = `${item[1][valueType]}`;
                }
            }
        });
        return result;
    };
    res.token0 = formatToken(meta.token0);
    res.token1 = formatToken(meta.token1);
    return res;
}
