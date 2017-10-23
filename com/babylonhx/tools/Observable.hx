package com.babylonhx.tools;

/**
 * ...
 * @author Krtolica Vujadin
 */

/**
 * The Observable class is a simple implementation of the Observable pattern.
 * There's one slight particularity though: a given Observable can notify its observer using a particular mask value, 
 * only the Observers registered with this mask value will be notified.
 * This enable a more fine grained execution without having to rely on multiple different Observable objects.
 * For instance you may have a given Observable that have four different types of notifications: 
 * Move (mask = 0x01), Stop (mask = 0x02), Turn Right (mask = 0X04), Turn Left (mask = 0X08).
 * A given observer can register itself with only Move and Stop (mask = 0x03), then it will only be notified when 
 * one of these two occurs and will never be for Turn Left/Right.
 */
class Observable<T> {	
	
	private var _observers:Array<Observer<T>> = [];
	
	private var _eventState:EventState;
	
	private var _onObserverAdded:Observer<T>->Void;
	
	
	public function new(?onObserverAdded:Observer<T>->Void) {
		this._eventState = new EventState(0);
		
		this._onObserverAdded = onObserverAdded;
	}

	/**
	 * Create a new Observer with the specified callback
	 * @param callback the callback that will be executed for that Observer
	 * @param insertFirst if true the callback will be inserted at the first position, hence executed before the others ones.
	 * If false (default behavior) the callback will be inserted at the last position, executed after all the others 
	 * already present.
	 */
	public function add(callback:T->Null<EventState>->Void, mask:Int = -1, insertFirst:Bool = false, scope:Dynamic = null):Observer<T> {
		if (callback == null) {
			return null;
		}
		
		var observer = new Observer(callback, mask, scope);
		
		if (insertFirst) {
            this._observers.unshift(observer);
        } 
		else {
            this._observers.push(observer);
        }
		
		if (this._onObserverAdded != null) {
			this._onObserverAdded(observer);
		}
		
		return observer;
	}

	/**
	 * Remove an Observer from the Observable object
	 * @param observer the instance of the Observer to remove. If it doesn't belong to this Observable, false will be returned.
	 */
	public function remove(observer:Observer<T>):Bool {
		var index = this._observers.indexOf(observer);
		
		if (index != -1) {
			this._observers.splice(index, 1);
			
			return true;
		}
		
		return false;
	}

	/**
	 * Remove a callback from the Observable object
	 * @param callback the callback to remove. If it doesn't belong to this Observable, false will be returned.
	*/
	public function removeCallback(callback:T->Null<EventState>->Void):Bool {
		for (index in 0...this._observers.length) {
			if (this._observers[index].callback == callback) {
				this._observers.splice(index, 1);				
				return true;
			}
		}
		
		return false;
	}

	/**
	 * Notify all Observers by calling their respective callback with the given data
	 * Will return true if all observers were executed, false if an observer set skipNextObservers to true, then prevent the subsequent ones to execute
	 * @param eventData
	 * @param mask
	 */
	public function notifyObservers(eventData:T, mask:Int = -1) {
		var state:EventState = this._eventState;
		state.mask = mask;
		state.skipNextObservers = false;
		
        for (obs in this._observers) {
            if (obs.mask & mask != 0) {
				obs.callback(eventData, state);
			}
			if (state.skipNextObservers) {
				return false;
			}
        }
		return true;
	}
	
	/**
	 * Notify a specific observer
	 * @param eventData
	 * @param mask
	 */
	public function notifyObserver(observer:Observer<T>, eventData:T, mask:Int = -1) {
		var state = this._eventState;
		state.mask = mask;
		state.skipNextObservers = false;
		
		observer.callback(eventData, state);
	} 
	
	/**
	 * return true is the Observable has at least one Observer registered
	 */
	public function hasObservers():Bool {
		return this._observers.length > 0;
	}

	/**
	* Clear the list of observers
	*/
	public function clear() {
		this._observers = [];
		this._onObserverAdded = null;
	}
	
	/**
	* Clone the current observable
	*/
	public function clone():Observable<T> {
		var result = new Observable<T>();
		
		result._observers = this._observers.slice(0);
		
		return result;
	}
	
	/**
	 * Does this observable handles observer registered with a given mask
	 * @param {number} trigger - the mask to be tested
	 * @return {boolean} whether or not one observer registered with the given mask is handeled 
	**/
	public function hasSpecificMask(mask:Int = -1):Bool {
		for (obs in this._observers) {
			if ((obs.mask & mask != 0) && obs.mask == mask) {
				return true;
			}
		}
		return false;
	}
	
}