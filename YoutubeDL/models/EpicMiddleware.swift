import RxSwift
import ReSwift

public typealias Epic<State> = (Observable<Action>, @escaping () -> State?) -> Observable<Action>

public func CombineEpics<State>(epics: [Epic<State>]) -> Epic<State> {
    return { (actions: Observable<Action>, getState: @escaping () -> State?) -> Observable<Action> in
        return Observable.from(epics)
            .map{ e in e(actions, getState) }
            .merge()
    }
}

class EpicMiddleware<State> {

    private let disposeBag = DisposeBag()

    private var epic: Epic<State>

    init(epic: @escaping Epic<State>) {
        self.epic = epic
    }

    func createMiddleware() -> Middleware<State> {

        let middleware: Middleware<State> = { dispatch, getState in
            
            let actionSubject = PublishSubject<Action>()
            Observable.just(self.epic)
                // Could this be simplified? There's only ever going to be 1 epic...
                .map{ e in
                    return e(actionSubject, getState)
                }
                .flatMapLatest{ output in
                    return output
                }
                .subscribe(onNext: { action in
                    _ = dispatch(action)
                })
                .disposed(by: self.disposeBag)
        
            return { next in
                return { action in
                    let result = next(action)
                    actionSubject.onNext(action)
                    return result
                }
            }
        }

        return middleware
    }
}
