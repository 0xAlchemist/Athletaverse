// Utilities for the Athletaverse contracts

pub contract AthletaverseUtils {

    pub resource interface Requester {
        pub fun addCapability(id: UInt64, capability: Capability)
    }

    pub resource interface Manager {
        pub fun approveRequest(_ id: UInt64)
        pub fun rejectRequest(_ id: UInt64)
        pub fun removeCapability(_ id: UInt64)
    }

    pub struct QueuedCapabilityManager: Requester, Manager {

        // the queued capabilities
        pub var queue: {UInt64: Capability?}

        // the approved capabilites
        pub var approved: {UInt64: Capability?}
        
        // the maximum amount of approved capabilities
        pub var limit: UInt64

        // adds a capability to the queue using the provded ID as the key
        pub fun addCapability(id: UInt64, capability: Capability) {
            pre {
                self.queued[id] == nil: "Queued capability already exists with this ID"
                self.approved[id] == nil: "Approved capability already exists with this ID"
            }

            self.queued[id] = capability
        }

        // moves the capability from the queue to the approved dictionary
        pub fun approveRequest(_ id: UInt64) {
            pre {
                self.queued[id] != nil: "No value at this key"
                self.approved[id] == nil: "A value has already been approved for this key"
                self.approved.length <= self.limit: "No capacity remaining for this approval"
            }

            self.approved[id] = self.queued[id]
            self.queued.remove(key: id)

            post {
                self.queued[id] == nil: "Queued value was not cleared after approval"
                self.approved[id] != nil: "Approved key has no value after approval"
            }
        }

        // removes the capability from the queue
        pub fun rejectRequest(_ id: UInt64) {
            pre {
                self.queued[id] != nil: "No value at this key"
            }

            self.queued.remove(key: id)

            post {
                self.queued[id] == nil: "Queued value was not cleared after being rejected"
            }
        }

        // removes the capability from the approved dictionary
        pub fun removeCapability(_ id: UInt64) {
            pre {
                self.approved[id] != nil: "No approved capability with this ID"
            }

            self.approved.remove(key: id)

            post {
                self.approved[id] == nil: "The capability was not removed"
            }
        }
    }
}