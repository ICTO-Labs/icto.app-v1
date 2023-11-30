import { toast } from 'vue3-toastify';
import crc32 from 'crc-32'
import { sha224 } from 'js-sha256'

const isHex = (h) => {
    var regexp = /^[0-9a-fA-F]+$/;
    return regexp.test(h);
};
export const validateAddress = (a) => {
    return (isHex(a) && a.length === 64)
}
export const showError = (message)=>{
    toast.error(message, {
        position: toast.POSITION.BOTTOM_CENTER,
    });
}
export const showSuccess = (message)=>{
    toast.success(message, {
        position: toast.POSITION.BOTTOM_CENTER,
    });
}
const deepCopy = (obj) => {
    var copy = Object.create(Object.getPrototypeOf(obj))
    var propNames = Object.getOwnPropertyNames(obj)

    propNames.forEach(function (name) {
        var desc = Object.getOwnPropertyDescriptor(obj, name)
        Object.defineProperty(copy, name, desc)
    })

    return copy
}
const to32bits = (num) => {
    let b = new ArrayBuffer(4)
    new DataView(b).setUint32(0, num)
    return Array.from(new Uint8Array(b))
  }
export const principalToAccountId = (p, s) => {
    const padding = Buffer("\x0Aaccount-id");
    const array = new Uint8Array([
        ...padding,
        ...Principal.fromText(p).toUint8Array(),
        ...getSubAccountArray(s)
    ]);
    const hash = sha224(array);
    const checksum = to32bits(getCrc32(hash));
    const array2 = new Uint8Array([
        ...checksum,
        ...hash
    ]);
    return toHexString(array2);
};
export const getSubAccountArray = (s) => {
    if (Array.isArray(s)){
        return s.concat(Array(32-s.length).fill(0));
    } else {
        //32 bit number only
        return Array(28).fill(0).concat(to32bits(s ? s : 0))
    }
};
const from32bits = ba => {
    var value;
    for (var i = 0; i < 4; i++) {
        value = (value << 8) | ba[i];
    }
    return value;
}

export const Storage = {
    set(key, value) {
        if (window.localStorage) {
            window.localStorage.setItem(key, JSON.stringify(value))
        }
    },
    get(key) {
        if (window.localStorage) {
            return JSON.parse(window.localStorage.getItem(key))
        }
    },
    remove(key) {
        if (window.localStorage) {
            window.localStorage.removeItem(key)
        }
    }
}

export default {
    validateAddress,
    showError
}