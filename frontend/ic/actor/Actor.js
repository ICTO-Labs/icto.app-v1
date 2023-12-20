import { createBaseActor } from "./BaseActor"
import { HttpAgent } from "@dfinity/agent"
import { IDL } from "@dfinity/candid"
import config from "@/config";

export let Connector;
(function(Connector) {
  Connector["ICPSwap"] = "ICPSwap"
  Connector["PLUG"] = "PLUG"
  Connector["STOIC"] = "STOIC"
  Connector["IC"] = "IC"
  Connector["NFID"] = "NFID"
  Connector["INFINITY"] = "INFINITY"
})(Connector || (Connector = {}))

export function isICConnector(connector) {
  return (
    connector === Connector.IC ||
    connector === Connector.STOIC ||
    connector === Connector.NFID
  )
}

export function isPlugConnector(connector) {
  return connector === Connector.PLUG || connector === Connector.INFINITY
}

async function createInfinityActor(canisterId, interfaceFactory) {
  return await window.ic.infinityWallet.createActor({
    canisterId,
    interfaceFactory
  })
}

async function createPlugActor(canisterId, interfaceFactory) {
  return await window.ic.plug.createActor({ canisterId, interfaceFactory })
}

export class Actor {
  connector = Connector.IC
  agent = null
  host = config.HOST
  errorCallbacks = []

  setConnector(connector) {
    this.connector = connector
  }

  async create({ canisterId, host, idlFactory, identity, agent }) {
    if (!canisterId) throw Error(`No canister id`)

    const _host = host ?? this.host

    if (!idlFactory) throw Error(`No idlFactory for ${canisterId}`)

    let _agent = this.AnonymousAgent(host)
    let isRejected = false

    // catch plug type wallet reject error
    try {
      _agent = agent
        ? agent
        : !identity
        ? this.AnonymousAgent(host)
        : this.agent
        ? this.agent
        : await this.createAgent(canisterId, _host, identity)
    } catch (err) {
      isRejected = true
      console.error(err)
    }

    const serviceClass = idlFactory({ IDL: IDL })

    let actor = null

    // catch create infinity actor rejected
    let createActorError = null

    if (this.connector === Connector.INFINITY && !!identity) {
      try {
        actor = await createInfinityActor(canisterId, idlFactory)
      } catch (error) {
        createActorError = String(error)
      }
    } else if (this.connector === Connector.PLUG && !!identity) {
      try {
        actor = await createPlugActor(canisterId, idlFactory)
      } catch (error) {
        createActorError = String(error)
      }
    } else {
      actor = await createBaseActor({
        canisterId: canisterId,
        idlFactory: idlFactory,
        agent: _agent,
        fetchRootKey: true
      })
    }

    const _actor = {}

    serviceClass._fields.forEach(ele => {
      const key = ele[0]

      _actor[key] = async (...args) => {
        if (createActorError) return { err: createActorError }
        if (isRejected) return { err: "The agent creation was rejected" }

        try {
          if (!actor) return { err: "no actor" }
          // @ts-ignore
          const result = actor[key](...args)
          return await result
        } catch (error) {
          const _error = String(error)

          let message = ""
          if (_error.includes("Reject text:")) {
            const _message =
              _error.split(`Reject text: `)[1]?.split(" at") ?? ""
            message = !!_message ? _message[0]?.trim() : _error
          } else {
            const _message = _error.includes(`"Message"`)
              ? _error.split(`"Message": `)[1]?.split('"')
              : ""
            message =
              _error.includes(`"Message"`) && !!_message ? _message[1] : _error
          }

          console.log("Error =====================>")
          console.log("canister: ", canisterId)
          console.log("method: ", key)
          console.log("rejected: ", message)
          console.log("Error =====================>")

          this.errorCallbacks.forEach(call => {
            call({ canisterId: canisterId ?? "", method: key, message })
          })

          return { err: message }
        }
      }
    })

    return _actor
  }

  AnonymousAgent(host) {
    return new HttpAgent({
      host: host ?? this.host
    })
  }

  async createAgent(canisterId, host, identity) {
    if (identity === true) {
      if (this.connector === Connector.PLUG) {
        await window.ic.plug.createAgent({ whitelist: [canisterId], host })
        return window.ic.plug.agent
      } else if (this.connector === Connector.INFINITY) {
        return new HttpAgent({
          host: host ?? this.host
        })
      } else if (isICConnector(this.connector)) {
        return window.icConnector.httpAgent
      }
    } else if (!!identity) {
      return new HttpAgent({
        host: host ?? this.host,
        identity
      })
    }

    return new HttpAgent({
      host: host ?? this.host
    })
  }

  setAgent(agent) {
    this.agent = agent
  }

  setHost(host) {
    this.host = host
  }

  onError(callback) {
    this.errorCallbacks.push(callback)
  }
}

export const actor = new Actor()