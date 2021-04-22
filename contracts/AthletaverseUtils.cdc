// UTILS
//
// Utilities for the Athletaverse smart contracts

pub contract AthletaverseUtils {

    // Requesters can request to add capabilities
    pub resource interface Requester {
        pub fun addCapability(id: UInt64, capability: Capability)
    }

    // Managers can approve and reject requests as well as remove approved
    // capabilities
    pub resource interface Manager {
        pub fun approveRequest(_ id: UInt64)
        pub fun rejectRequest(_ id: UInt64)
        pub fun removeCapability(_ id: UInt64)
    }

    // Allows the manager to handle requests to add Capabilities
    // to a dictionary
    pub resource RegisteredCapabilityManager: Requester, Manager {

        // the queued capabilities
        pub var pending: {UInt64: Capability?}

        // the approved capabilites
        pub var approved: {UInt64: Capability?}
        
        // the maximum amount of approved capabilities
        pub var limit: Int

        init(limit: Int) {
            self.pending = {}
            self.approved = {}
            self.limit = limit
        }

        // adds a capability to the dictionary using the provded ID as the key
        pub fun addCapability(id: UInt64, capability: Capability) {
            pre {
                self.pending[id] == nil: "Pending capability already exists for this ID"
                self.approved[id] == nil: "Approved capability already exists for this ID"
            }

            self.pending[id] = capability
        }

        // moves the capability from the pending to the approved dictionary
        pub fun approveRequest(_ id: UInt64) {
            pre {
                self.pending[id] != nil: "No value at this key"
                self.approved[id] == nil: "A value has already been approved for this key"
                self.approved.length <= self.limit: "No capacity remaining for this approval"
            }

            self.approved[id] = self.pending[id]
            self.pending.remove(key: id)
        }

        // removes the capability from the pending dictionary
        pub fun rejectRequest(_ id: UInt64) {
            pre {
                self.pending[id] != nil: "No value at this key"
            }

            self.pending.remove(key: id)
        }

        // removes the capability from the approved dictionary
        pub fun removeCapability(_ id: UInt64) {
            pre {
                self.approved[id] != nil: "No approved capability with this ID"
            }

            self.approved.remove(key: id)
        }
    }

    access(account) fun newRegisteredCapabilityManager(limit: Int): @RegisteredCapabilityManager {
        return <- create RegisteredCapabilityManager(limit: limit)
    }
}
