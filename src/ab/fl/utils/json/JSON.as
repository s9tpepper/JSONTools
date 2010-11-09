package ab.fl.utils.json
{
	import flash.utils.getQualifiedClassName;
	import flash.utils.Dictionary;
	import json.JParser;
	import flash.utils.flash_proxy;
	import flash.utils.Proxy;

	/**
	 * @author Omar Gonzalez :: omar@almerblank.com
	 */
	dynamic public class JSON extends Proxy
	{
		/**
		 * The plain Object data parsed by JParser.
		 */
		private var _plainJson:Object;
		/**
		 * Reference to the root JSON object.
		 */
		private var _rootJSON:JSON;
		/**
		 * Reference object that contains name/value pairs.
		 */
		private var _objectReference:*;
		/**
		 * Flag set true if this is a JSON tree node (object or array in the root node).
		 */
		private var _isTree:Boolean;
		/**
		 * Flag set true if this is the JSON root node.
		 */
		private var _isRoot:Boolean;
		/**
		 * The value key for a JSON object that is not a tree. (Stores native values like String, Number, etc.)
		 */
		private var _nonTreeKey:String;
		
		private var _treeKey:String;
		
		private var _owner:JSON;
		
		private const _MATCH_EXPRESSION:RegExp				= new RegExp(/\((\w+)(\s+)?==(\s+)?(["'])?(\w+)(["'])?\)/gi);
		private const _OMIT_EXPRESSION:RegExp				= new RegExp(/\((\w+)(\s+)?!=(\s+)?(["'])?(\w+)(["'])?\)/gi);
		private const _GREATER_THAN_EXPRESSION:RegExp		= new RegExp(/\((\w+)(\s+)?>(\s+)?(["'])?(\w+)(["'])?\)/gi);
		private const _GREATER_OR_EQUAL_EXPRESSION:RegExp	= new RegExp(/\((\w+)(\s+)?>=(\s+)?(["'])?(\w+)(["'])?\)/gi);
		private const _LESS_THAN_EXPRESSION:RegExp			= new RegExp(/\((\w+)(\s+)?<(\s+)?(["'])?(\w+)(["'])?\)/gi);
		private const _LESS_OR_EQUAL_EXPRESSION:RegExp		= new RegExp(/\((\w+)(\s+)?<=(\s+)?(["'])?(\w+)(["'])?\)/gi);
		private const _EXPRESSIONS:Array					= [_MATCH_EXPRESSION, _OMIT_EXPRESSION, _GREATER_THAN_EXPRESSION, _GREATER_OR_EQUAL_EXPRESSION, _LESS_THAN_EXPRESSION, _LESS_OR_EQUAL_EXPRESSION];
		
		/**
		 * @Constructor
		 * 
		 * @param json String representing a JSON object.
		 */
		public function JSON(json:String=null)
		{
			_init();
			
			if (json)
				_initialize(json);
		}
		
		/**
		 * Inits the JSON object.
		 */
		private function _init():void
		{
			_objectReference = new Dictionary();
		}
		
		/**
		 * Initializes the JSON string, this should only be done
		 * when the string is initially parsed.
		 */
		private function _initialize(json:String):void
		{
			_isRoot = true;
			
			_plainJson = JParser.decode(json);
			
			_buildJSON();
		}
		
		/**
		 * Builds a JSON tree based on the object created
		 * 
		 */
		private function _buildJSON():void
		{
			_setProperties(_objectReference, _plainJson, _rootJSON);
		}
		
		/**
		 * Populates the properties of a JSON object
		 */
		private function _setProperties(target:*, source:*, root:JSON):void
		{
			_rootJSON = root;
			
			if (!target)
				return;
			
			var value:*;
			var className:String;
			for (var key:String in source)
			{
				value = source[key];
				
				className = getQualifiedClassName(value);
				switch (true)
				{
					case (value is String):
					case (value is Number):
					case (value is int):
					case (value is uint):
					case (value is Boolean):
						target[key] = value;
						break;
						
					case (className == "Object"):
					case (value is Array):
						target[key] = new JSON();
						var newJSON:JSON = target[key] as JSON;
							newJSON.isTree = true;
							newJSON.owner = this;
							newJSON.treeKey = key;
							
						if (className == "Object")
						{
							newJSON.objectReference = new Object();
						}
						else
						{
							newJSON.objectReference = new Array();
						}
							
						_setProperties(newJSON.objectReference, value, root);
						break;
				}
			}
		}
		
		flash_proxy override function callProperty(name:*, ...rest):*
		{
			trace("name = " + name);
		}
		flash_proxy override function deleteProperty(name:*):Boolean
		{
			trace("name = " + name);
			
			return false;
		}
		flash_proxy override function getDescendants(name:*):*
		{
			trace("name = " + name);
		}
		flash_proxy override function hasProperty(name:*):Boolean
		{
			trace("name = " + name);
			
			return false;
		}
		flash_proxy override function isAttribute(name:*):Boolean
		{
			trace("name = " + name);
			
			return false;
		}
		flash_proxy override function nextNameIndex(index:int):int
		{
			trace("index = " + index);
			
			return 0;
		}
		flash_proxy override function nextName(index:int):String
		{
			trace("index = " + index);
			
			return "empty";
		}
		
		/**
		 * Method called when a property value is being retrieved
		 * from this JSON object instance.
		 */
		flash_proxy override function getProperty(name:*):*
		{
			//trace("getProperty()");
			//trace("name = " + name);
			var propertyName:String = QName(name).toString();
			if (propertyName && propertyName.length)
			{
				try
				{
					var value:* = _objectReference[propertyName];
					
					// Look for queries
					var searchKey:String;
					var searchValue:String;
					var matches:Array;
					var item:Object;
					var expr:RegExp;
					var regexResult:*;
					for each (expr in _EXPRESSIONS)
					{
						regexResult = expr.exec(propertyName);
						if (regexResult != null)
						{
							break;
						}
						else
						{
							expr = null;
						}
					}
					
					if (regexResult != null)
					{
						searchKey = regexResult[1];
						searchValue = regexResult[5];
						
						matches = new Array();
						for each (item in objectReference)
						{
							switch (expr)
							{
								case _GREATER_THAN_EXPRESSION:
									if (item[searchKey] > searchValue)
									{
										matches.push(item);
									}
									break;
								case _GREATER_OR_EQUAL_EXPRESSION:
									if (item[searchKey] >= searchValue)
									{
										matches.push(item);
									}
									break;
								case _MATCH_EXPRESSION:
									if (item[searchKey] == searchValue)
									{
										matches.push(item);
									}
									break;
								case _LESS_THAN_EXPRESSION:
									if (item[searchKey] < searchValue)
									{
										matches.push(item);
									}
									break;
								case _LESS_OR_EQUAL_EXPRESSION:
									if (item[searchKey] <= searchValue)
									{
										matches.push(item);
									}
									break;
								case _OMIT_EXPRESSION:
									if (item[searchKey] != searchValue)
									{
										matches.push(item);
									}
									break;
							}
						}
						return matches;
					}
					
					// Check if the propertyName exists.
					if (value === undefined)
					{
						throw new Error("JSON property '" + propertyName + "' does not exist.");
					}
					
					return value;
				}
				catch (e:Error)
				{
					throw new Error("JSON property '" + propertyName + "' does not exist.");
				}
			}
			return null;
		}
		
		/**
		 * Method called when a property value is set on this
		 * JSON object instance.
		 */
		flash_proxy override function setProperty(name:*, value:*):void
		{
			try
			{
				_objectReference[name] = value;
				
				if (!_isTree)
				{
					_nonTreeKey = name;
				}
			}
			catch (e:Error)
			{
				//trace("I couldn't set the property: " + name + " with the value: " + value);
				throw new Error("JSON error comitting property '" + name + "', property does not exist.");
			}
		}
		/**
		 * Returns the object holding value references for this JSON
		 * object proxy.  This object is not meant to be used by classes
		 * other than JSON.
		 */
		public function get objectReference():*
		{
			return _objectReference;
		}
		
		/**
		 * Displays the JSON value for this instance as a String.
		 */
		public function toString():String
		{
			if (_isTree)
			{
				return _objectReference['toString']();
			}
			else
			{
				return _objectReference[_nonTreeKey];
			}
			
			return "ab.fl.utils.json.JSON";
		}
		/**
		 * Returns true if the JSON object is a tree node (Object or Array)
		 * but not the root.
		 */
		public function get isTree():Boolean
		{
			return _isTree;
		}
		/**
		 * Returns true if the JSON object is the root node.
		 */
		public function get isRoot():Boolean
		{
			return _isRoot;
		}
		/**
		 * @private
		 */
		public function set isTree(isTree:Boolean):void
		{
			_isTree = isTree;
		}
		/**
		 * @private
		 */
		public function set objectReference(objectReference:*):void
		{
			_objectReference = objectReference;
		}

		public function get owner():JSON
		{
			return _owner;
		}

		public function set owner(owner:JSON):void
		{
			_owner = owner;
		}

		public function get treeKey():String
		{
			return _treeKey;
		}

		public function set treeKey(treeKey:String):void
		{
			_treeKey = treeKey;
		}
	}
}
