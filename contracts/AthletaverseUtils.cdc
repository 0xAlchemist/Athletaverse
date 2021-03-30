// UTILS
//
// Utilities for the Athletaverse smart contracts

pub contract AthletaverseUtils {

    // Requesters can request to add capabilities
    pub struct interface Requester {
        pub fun addCapability(id: UInt64, capability: Capability)
    }

    // Managers can approve and reject requests as well as remove approved
    // capabilities
    pub struct interface Manager {
        pub fun approveRequest(_ id: UInt64)
        pub fun rejectRequest(_ id: UInt64)
        pub fun removeCapability(_ id: UInt64)
    }

    // Allows the manager to handle queued requests to add Capabilities
    // to a dictionary
    pub struct QueuedCapabilityManager: Requester, Manager {

        // the queued capabilities
        pub var queue: {UInt64: Capability?}

        // the approved capabilites
        pub var approved: {UInt64: Capability?}
        
        // the maximum amount of approved capabilities
        pub var limit: Int

        init(limit: Int) {
            self.queue = {}
            self.approved = {}
            self.limit = limit
        }

        // adds a capability to the queue using the provded ID as the key
        pub fun addCapability(id: UInt64, capability: Capability) {
            pre {
                self.queue[id] == nil: "Queued capability already exists with this ID"
                self.approved[id] == nil: "Approved capability already exists with this ID"
            }

            self.queue[id] = capability
        }

        // moves the capability from the queue to the approved dictionary
        pub fun approveRequest(_ id: UInt64) {
            pre {
                self.queue[id] != nil: "No value at this key"
                self.approved[id] == nil: "A value has already been approved for this key"
                self.approved.length <= self.limit: "No capacity remaining for this approval"
            }

            self.approved[id] = self.queue[id]
            self.queue.remove(key: id)
        }

        // removes the capability from the queue
        pub fun rejectRequest(_ id: UInt64) {
            pre {
                self.queue[id] != nil: "No value at this key"
            }

            self.queue.remove(key: id)
        }

        // removes the capability from the approved dictionary
        pub fun removeCapability(_ id: UInt64) {
            pre {
                self.approved[id] != nil: "No approved capability with this ID"
            }

            self.approved.remove(key: id)
        }
    }

    pub fun newQueuedCapabilityManager(limit: Int): QueuedCapabilityManager {
        return QueuedCapabilityManager(limit: limit)
    }
}
