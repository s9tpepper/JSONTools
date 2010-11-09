package ab.fl.utils.json
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.collections.IList;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	import mx.events.PropertyChangeEvent;
	import mx.events.PropertyChangeEventKind;
	import mx.resources.IResourceManager;
	import mx.resources.ResourceManager;
	import mx.utils.UIDUtil;
	
	/**
	 * The JSONList is used by the JSONListCollection to use
	 * its API for List type components.   JSONList provides
	 * additional functionality to Array objects that make using
	 * Arrays with JSON in List type components easier and similar to
	 * using Array/ArrayCollection or XML/XMLListCollection pairings.
	 * 
	 * @author Omar Gonzalez :: omar@almerblank.com :: http://labs.almerblank.com
	 * 
	 */	
	public class JSONList extends EventDispatcher implements IList
	{
		/**
		 * Release version, used for reference.
		 */
		//static private const _VERSION:String = "1.0";
		/**
		 * The source Array type object.  This property is set to type
		 * Object because Array and Array can not be used
		 * as a storage location for any type of Array object.
		 */
		private var _source:Array;
		/**
		 * Unique id of the JSONList object.
		 */
		private var _uid:String;
		
		/**
		 *  @private 
		 *  Indicates if events should be dispatched.
		 *  calls to enableEvents() and disableEvents() effect the value when == 0
		 *  events should be dispatched. 
		 */
		private var _dispatchEvents:int = 0;
		
		/**
		 *  @private
		 *  Used for accessing localized Error messages.
		 */
		private var _resourceManager:IResourceManager = ResourceManager.getInstance();
		
		/**
		 * @Constructor
		 * 
		 * @param Array This object should be a Array type object.
		 * @author Omar Gonzalez
		 */
		public function JSONList(array:Array)
		{
			super();
			
			// Use the private var here to skip any event dispatching since we are initializing.
			_disableEvents();
			source = array;
			_enableEvents();
			_uid = UIDUtil.createUID();
		}
		/**
		 *  Disables event dispatch for this list.
		 *  To re-enable events call enableEvents(), enableEvents() must be called
		 *  a matching number of times as disableEvents().
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		private function _disableEvents():void
		{
			_dispatchEvents--;
		}
		/**
		 *  Enables event dispatch for this list.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		private function _enableEvents():void
		{
			_dispatchEvents++;
			if (_dispatchEvents > 0)
				_dispatchEvents = 0;
		}
		/**
		 * Returns the unique id for the instance of JSONList.
		 * 
		 * @return 
		 * 
		 */
		public function get uid():String
		{
			return _uid;
		}
		/**
		 * Sets the unique id for the instance of JSONList.
		 * 
		 * @return 
		 * 
		 */
		public function set uid(value:String):void
		{
			_uid = value;
		}
		/**
		 * Gets the source Array object for this JSONList.
		 * 
		 * @return 
		 * 
		 */		
		public function get source():Array
		{
			return _source;
		}
		/** 
		 *  If the item is an IEventDispatcher watch it for updates.  
		 *  This is called by addItemAt and when the source is initially
		 *  assigned.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		protected function startTrackUpdates(item:Object):void
		{
			if (item && (item is IEventDispatcher))
			{
				IEventDispatcher(item).addEventListener(
					PropertyChangeEvent.PROPERTY_CHANGE, 
					itemUpdateHandler, false, 0, true);
			}
		}
		/**
		 *  Called whenever any of the contained items in the list fire an
		 *  ObjectChange event.  
		 *  Wraps it in a CollectionEventKind.UPDATE.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */    
		protected function itemUpdateHandler(event:PropertyChangeEvent):void
		{
			_internalDispatchEvent(CollectionEventKind.UPDATE, event);
			// need to dispatch object event now
			if (_dispatchEvents == 0 && hasEventListener(PropertyChangeEvent.PROPERTY_CHANGE))
			{
				var objEvent:PropertyChangeEvent = PropertyChangeEvent(event.clone());
				var index:uint = getItemIndex(event.target);
				objEvent.property = index.toString() + "." + event.property;
				dispatchEvent(objEvent);
			}
		}
		/** 
		 *  If the item is an IEventDispatcher stop watching it for updates.
		 *  This is called by removeItemAt, removeAll, and before a new
		 *  source is assigned.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		protected function stopTrackUpdates(item:Object):void
		{
			if (item && item is IEventDispatcher)
			{
				IEventDispatcher(item).removeEventListener(
					PropertyChangeEvent.PROPERTY_CHANGE, 
					itemUpdateHandler);    
			}
		}
		/**
		 *  Dispatches a collection event with the specified information.
		 *
		 *  @param kind String indicates what the kind property of the event should be
		 *  @param item Object reference to the item that was added or removed
		 *  @param location int indicating where in the source the item was added.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		private function _internalDispatchEvent(kind:String, item:Object = null, location:int = -1):void
		{
			if (_dispatchEvents == 0)
			{
				if (hasEventListener(CollectionEvent.COLLECTION_CHANGE))
				{
					var event:CollectionEvent =
						new CollectionEvent(CollectionEvent.COLLECTION_CHANGE);
					event.kind = kind;
					event.items.push(item);
					event.location = location;
					dispatchEvent(event);
				}
				
				// now dispatch a complementary PropertyChangeEvent
				if (hasEventListener(PropertyChangeEvent.PROPERTY_CHANGE) && 
					(kind == CollectionEventKind.ADD || kind == CollectionEventKind.REMOVE))
				{
					var objEvent:PropertyChangeEvent =
						new PropertyChangeEvent(PropertyChangeEvent.PROPERTY_CHANGE);
					objEvent.property = location;
					if (kind == CollectionEventKind.ADD)
						objEvent.newValue = item;
					else
						objEvent.oldValue = item;
					dispatchEvent(objEvent);
				}
			}
		}
		/**
		 * Sets the source Array object for the JSONList.
		 * 
		 * @param value
		 * 
		 */
		public function set source(value:Array):void
		{
			var i:int;
			var len:int;
			if (_source && _source.length)
			{
				len = _source.length;
				for (i = 0; i < len; i++)
				{
					stopTrackUpdates(_source[i]);
				}
			}
			_source  = value ? value : new Array();
			len = _source.length;
			for (i = 0; i < len; i++)
			{
				startTrackUpdates(_source[i]);
			}
			
			var event:CollectionEvent =
				new CollectionEvent(CollectionEvent.COLLECTION_CHANGE);
			event.kind = CollectionEventKind.RESET;
			dispatchEvent(event);
		}
		/**
		 * Gets the length of the JSONList.
		 * 
		 * @return 
		 * 
		 */
		public function get length():int
		{
			if (source)
				return source.length;
			else
				return 0;
		}
		/**
		 * Adds an item to the JSONList.
		 * 
		 * @param item
		 * 
		 */
		public function addItem(item:Object):void
		{
			addItemAt(item, length);
		}
		/**
		 * Adds an item to the JSONList at a specified index.
		 * 
		 * @param item
		 * @param index
		 * 
		 */		
		public function addItemAt(item:Object, index:int):void
		{
			// This range check is slightly different than _checkForRangeError()
			if (index < 0 || index > length) 
			{
				var message:String = _resourceManager.getString(
					"collections", "outOfBounds", [ index ]);
				throw new RangeError(message);
			}
			
			source.splice(index, 0, item);
			
			startTrackUpdates(item);
			_internalDispatchEvent(CollectionEventKind.ADD, item, index);
		}
		/**
		 * Gets an item at a specified index.
		 * 
		 * @param index
		 * @param prefetch
		 * @return 
		 * 
		 */
		public function getItemAt(index:int, prefetch:int=0):Object
		{
			_checkForRangeError(index,length);
			
			return source[index];
		}
		/**
		 * Checks if an index is out range of the JSONList.
		 * 
		 * @param index
		 * @param length
		 * 
		 */
		private function _checkForRangeError(index:int, length:int):void
		{
			if (index < 0 || index >= length)
			{
				var message:String = _resourceManager.getString(
					"collections", "outOfBounds", [ index ]);
				throw new RangeError(message);
			}
		}
		/**
		 * Gets the index of a specified item in the JSONList.
		 * 
		 * @param item
		 * @return 
		 * 
		 */
		public function getItemIndex(item:Object):int
		{
			var n:int = source.length;
			for (var i:int = 0; i < n; i++)
			{
				if (source[i] === item)
					return i;
			}
			
			return -1; 
		}
		/**
		 * This method is triggered when properties of an object that is in the
		 * JSONList are updated and those properties are bindable.
		 * 
		 * @param item
		 * @param property
		 * @param oldValue
		 * @param newValue
		 * 
		 */
		public function itemUpdated(item:Object, property:Object=null, oldValue:Object=null, newValue:Object=null):void
		{
			var event:PropertyChangeEvent =
				new PropertyChangeEvent(PropertyChangeEvent.PROPERTY_CHANGE);
			
			event.kind = PropertyChangeEventKind.UPDATE;
			event.source = item;
			event.property = property;
			event.oldValue = oldValue;
			event.newValue = newValue;
			
			itemUpdateHandler(event);  
		}
		/**
		 * Removes all items from the list.
		 * 
		 */
		public function removeAll():void
		{
			if (length > 0)
			{
				var len:int = length;
				for (var i:int = 0; i < len; i++)
				{
					stopTrackUpdates(source[i]);
				}
				
				source.splice(0, length);
				_internalDispatchEvent(CollectionEventKind.RESET);
			}
		}
		/**
		 * Removes the item at a specified index.
		 * 
		 * @param index
		 * @return 
		 * 
		 */
		public function removeItemAt(index:int):Object
		{
			_checkForRangeError(index,length);
			
			var removed:Object = source.splice(index, 1)[0];
			stopTrackUpdates(removed);
			_internalDispatchEvent(CollectionEventKind.REMOVE, removed, index);
			return removed;
		}
		/**
		 * Sets the item passed in at the specified index of the JSONList.
		 * 
		 * @param item
		 * @param index
		 * @return 
		 * 
		 */
		public function setItemAt(item:Object, index:int):Object
		{
			_checkForRangeError(index,length);
			
			var oldItem:Object = source[index];
			source[index] = item;
			stopTrackUpdates(oldItem);
			startTrackUpdates(item);
			
			//dispatch the appropriate events 
			if (_dispatchEvents == 0)
			{
				var hasCollectionListener:Boolean = 
					hasEventListener(CollectionEvent.COLLECTION_CHANGE);
				var hasPropertyListener:Boolean = 
					hasEventListener(PropertyChangeEvent.PROPERTY_CHANGE);
				var updateInfo:PropertyChangeEvent; 
				
				if (hasCollectionListener || hasPropertyListener)
				{
					updateInfo = new PropertyChangeEvent(PropertyChangeEvent.PROPERTY_CHANGE);
					updateInfo.kind = PropertyChangeEventKind.UPDATE;
					updateInfo.oldValue = oldItem;
					updateInfo.newValue = item;
					updateInfo.property = index;
				}
				
				if (hasCollectionListener)
				{
					var event:CollectionEvent =
						new CollectionEvent(CollectionEvent.COLLECTION_CHANGE);
					event.kind = CollectionEventKind.REPLACE;
					event.location = index;
					event.items.push(updateInfo);
					dispatchEvent(event);
				}
				
				if (hasPropertyListener)
				{
					dispatchEvent(updateInfo);
				}
			}
			return oldItem;
		}
		/**
		 * Returns an Array of the JSONList items.
		 * 
		 * @return 
		 * 
		 */
		public function toArray():Array
		{
			var array:Array = [];
			var arrayItem:Object;
			for each (arrayItem in source)
			{
				array.push(arrayItem);
			}
			return array;
		}
		/**
		 *  @copy mx.collections.ListCollectionView#addAll()
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public function addAll(addList:IList):void
		{
			addAllAt(addList, length);
		}
		
		/**
		 *  @copy mx.collections.ListCollectionView#addAllAt()
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public function addAllAt(addList:IList, index:int):void
		{
			var length:int = addList.length;
			for (var i:int = 0; i < length; i++)
			{
				addItemAt(addList.getItemAt(i), i+index);
			}
		}
		/**
		 *  Removes the specified item from this list, should it exist.
		 *
		 *  @param  item Object reference to the item that should be removed.
		 *  @return Boolean indicating if the item was removed.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public function removeItem(item:Object):Boolean
		{
			var index:int = getItemIndex(item);
			var result:Boolean = index >= 0;
			if (result)
				removeItemAt(index);
			
			return result;
		}
	}
}