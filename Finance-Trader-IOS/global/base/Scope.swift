import Foundation

struct Scope {
    var backTask: Task<Void, Error>?
    var medTask: Task<Void, Error>?
    var realmTask: Task<Void, Error>?
    
    var mainTask: Task<Void, Error>?

    @discardableResult mutating func launch(
        block: @Sendable @escaping () async -> Void
    ) -> Task<Void, Error>? {
        backTask = Task(priority: .background) { [backTask] in
            let _ = await backTask?.result
            return await block()
        }
        return backTask
    }
    
    @discardableResult mutating func launchMed(
        block: @Sendable @escaping () async -> Void
    ) -> Task<Void, Error>? {
        realmTask = Task(priority: .medium) { [realmTask] in
            let _ = await realmTask?.result
            return await block()
        }
        return realmTask
    }
    
    
    @discardableResult mutating func launchRealm(
        block: @BackgroundActor @Sendable @escaping () async -> Void
    ) -> Task<Void, Error>? {
        return Task { @BackgroundActor in
            return await block()
        }
    }

    @discardableResult mutating func launchMain(
        block: @MainActor @escaping @Sendable () async -> Void
    ) -> Task<Void, Error>? {
        mainTask = Task { @MainActor [mainTask] in
            let _ = await mainTask?.result
            return await block()
        }
        return mainTask
    }
    
    mutating func deInit() {
        backTask?.cancel()
        medTask?.cancel()
        realmTask?.cancel()
        mainTask?.cancel()
        self.backTask = nil
        self.medTask = nil
        self.realmTask = nil
        self.mainTask = nil
    }
}


protocol ScopeFunc {}
extension NSObject: ScopeFunc {}
extension Array : ScopeFunc {}
extension Int : ScopeFunc {}
extension Float : ScopeFunc {}


extension Optional where Wrapped: ScopeFunc {

    @inline(__always) func `let`<R>(_ block: (Wrapped) -> R) -> R? {
        guard let self = self else { return nil }
        return block(self)
    }
    
    @BackgroundActor
    @inline(__always) func letBack<R>(_ block: @BackgroundActor (Wrapped) -> R) -> R? {
        guard let self = self else { return nil }
        return block(self)
    }
    
    
    @BackgroundActor
    @inline(__always) func letBackN<R>(_ block: @BackgroundActor (Wrapped?) -> R?) -> R? {
        guard let self = self else { return nil }
        return block(self)
    }

    @inline(__always) func letSusBack<R>(_ block: @BackgroundActor (Wrapped) async -> R) async -> R? {
        guard let self = self else { return nil }
        return await block(self)
    }
    
    @inline(__always) func apply(_ block: (Self) -> ()) -> Self? {
        guard let self = self else { return nil }
        block(self)
        return self
    }
    
}


extension Optional where Wrapped == ScopeFunc? {

    @inline(__always) func `let`<R>(_ block: (Wrapped) -> R) -> R? {
        guard let self = self else { return nil }
        return block(self)
    }
    
    @BackgroundActor
    @inline(__always) func letBack<R>(_ block: @BackgroundActor (Wrapped) -> R) -> R? {
        guard let self = self else { return nil }
        return block(self)
    }
    
    @BackgroundActor
    @inline(__always) func letBackN<R>(_ block: @BackgroundActor (Wrapped?) -> R?) -> R? {
        guard let self = self else { return nil }
        return block(self)
    }

    @inline(__always) func letSusBack<R>(_ block: @BackgroundActor (Wrapped) async -> R) async -> R? {
        guard let self = self else { return nil }
        return await block(self)
    }
    
    @inline(__always) func apply(_ block: (Self) -> ()) -> Self {
        guard let self = self else { return nil }
        block(self)
        return self
    }
}



extension Optional {
    func `let`(do: (Wrapped)->()) {
        guard let v = self else { return }
        `do`(v)
    }
}

extension ScopeFunc {
    
    @inline(__always) func apply(_ block: (Self) -> ()) -> Self {
        block(self)
        return self
    }
    
    @inline(__always) func supply(_ block: (Self) -> ()) {
        block(self)
    }
    
    @BackgroundActor
    @inline(__always) func applyBack(_ block: @BackgroundActor (Self) -> ()) -> Self {
        block(self)
        return self
    }
    
    @BackgroundActor
    @inline(__always) func supplyBack(_ block: @BackgroundActor (Self) -> ()) {
        block(self)
    }
    
    @inline(__always) func `let`<R>(_ block: (Self) -> R) -> R {
        return block(self)
    }
    
}
