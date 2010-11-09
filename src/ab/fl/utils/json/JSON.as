package ab.fl.utils.json
{
	import flash.net.registerClassAlias;
	import flash.net.getClassByAlias;
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
		/**
		 * The value key for a JSON object that is a tree.
		 */
		private var _treeKey:String;
		/**
		 * If not the root node the _owner property is a 
		 * reference to the JSON node's parent.
		 */
		private var _owner:JSON;
		
		/**
		 * Searches for expressions using the "==" operator.
		 */
		private const _MATCH_EXPRESSION:RegExp				= new RegExp(/\((\w+)(\s+)?==(\s+)?(["'])?(\w+)(["'])?\)/gi);
		/**
		 * Searches for expressions using the "!=" operator.
		 */
		private const _OMIT_EXPRESSION:RegExp				= new RegExp(/\((\w+)(\s+)?!=(\s+)?(["'])?(\w+)(["'])?\)/gi);
		/**
		 * Searches for expressions using the ">" operator.
		 */
		private const _GREATER_THAN_EXPRESSION:RegExp		= new RegExp(/\((\w+)(\s+)?>(\s+)?(["'])?(\w+)(["'])?\)/gi);
		/**
		 * Searches for expressions using the ">=" operator.
		 */
		private const _GREATER_OR_EQUAL_EXPRESSION:RegExp	= new RegExp(/\((\w+)(\s+)?>=(\s+)?(["'])?(\w+)(["'])?\)/gi);
		/**
		 * Searches for expressions using the "<" operator.
		 */
		private const _LESS_THAN_EXPRESSION:RegExp			= new RegExp(/\((\w+)(\s+)?<(\s+)?(["'])?(\w+)(["'])?\)/gi);
		/**
		 * Searches for expressions using the "<=" operator.
		 */
		private const _LESS_OR_EQUAL_EXPRESSION:RegExp		= new RegExp(/\((\w+)(\s+)?<=(\s+)?(["'])?(\w+)(["'])?\)/gi);
		/**
		 * List of expressions used to see if a getProperty() call is
		 * actually a query.
		 */
		private const _EXPRESSIONS:Array					= [_MATCH_EXPRESSION, _OMIT_EXPRESSION, _GREATER_THAN_EXPRESSION, _GREATER_OR_EQUAL_EXPRESSION, _LESS_THAN_EXPRESSION, _LESS_OR_EQUAL_EXPRESSION];
		
		/**
		 * This property determines whether or not the JSON class should
		 * throw JSONError objects when it catches certain errors.  This 
		 * property defaults to true.  To turn off JSONError objects from
		 * being thrown the throwJSONErrors property should be set to false.
		 * Some actions such as calling properties on JSON objects that
		 * do not exist will result in null returns.
		 */
		static public var throwJSONErrors:Boolean = true;
		
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
							// Look for Class mapping
							if (Object(value).hasOwnProperty("_explicitType"))
							{
								var alias:String = Object(value)._explicitType;
								try
								{
									var mappedClass:Class = getClassByAlias(alias);
									newJSON.objectReference = new mappedClass();
								}
								catch (e:Error)
								{
									newJSON.objectReference = new Object();
								}
							}
							else
							{
								newJSON.objectReference = new Object();
							}
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
		
		/**
		 * Returns the raw value representing by the JSON object. For native types such
		 * as String, Number, etc, the valueOf() method should return the same as calling
		 * the property by dot notation using the JSON object.  The valueOf() method
		 * is helpful when the JSON object represents a strong typed object that was
		 * mapped from a JSON string using the _explicitType property in the JSON string.
		 * In such cases the valueOf() method will return the instance of the strong
		 * typed object.  In the example JsonTest.as, the method is used to cast the
		 * JSON by doing GroupVO(search[0].valueOf()).MEMBERCOUNT, this is also the
		 * same as just using search[0].MEMBERCOUNT
		 */
		public function valueOf():*
		{
			return _objectReference;
		}
		
		/**
		 * This method is a utility method to register classes that are being
		 * mapped from JSON with the registerClassAlias() method.  Simply 
		 * removes the need to import the registerClassAlias() by using this
		 * helper function, using registerClassAlias() maps the classes just
		 * the same for use with JSONTools JSON to AS3 class mapping.
		 */
		static public function registerClass(alias:String, aliasedClass:Class):void
		{
			registerClassAlias(alias, aliasedClass);
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
						if (throwJSONErrors)
							throw new JSONError(JSONError.ERROR_GETTING_PROPERTY_DOESNT_EXIST.replace("{name}", propertyName), 60001);
					}
					
					return _objectReference[propertyName];
				}
				catch (e:Error)
				{
					if (throwJSONErrors)
						throw new JSONError(JSONError.ERROR_GETTING_PROPERTY_DOESNT_EXIST.replace("{name}", propertyName), 60001);
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
				trace("setProperty: name  = " + name);
				
				_objectReference[name] = value;
				
				if (!_isTree)
				{
					_nonTreeKey = name;
				}
			}
			catch (e:Error)
			{
				if (throwJSONErrors)
					throw new JSONError(JSONError.ERROR_COMMITING_PROPERTY.replace("{name}", name), 60000);
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
			return "[ ab.fl.utils.json::JSON, json.valueOf()="+ valueOf() +" ]";
		}
		/**
		 * Returns true if the JSON object is a tree node (Object, Array, or custom strong type)
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
