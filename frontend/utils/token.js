export const decodeICRC1Metadata = (metadata)=>{
    return metadata.reduce((acc, next) => {
        switch (next[0]) {
          case 'icrc1:name':
            return Object.assign(acc, { name: next[1].Text })
          case 'icrc1:symbol':
            return Object.assign(acc, { symbol: next[1].Text })
          case 'icrc1:decimals':
            return Object.assign(acc, { decimals: Number(next[1].Nat) })
          case 'icrc1:fee':
            return Object.assign(acc, { fee: (next[1].Nat).toString() })
          default:
            return Object.assign(acc, { [next[0]]: next[1] })
        }
      }, {})
}