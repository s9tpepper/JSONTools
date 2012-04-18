package ab.fl.utils.json
{
	import flash.net.getClassByAlias;
	import flash.net.registerClassAlias;
	import flash.utils.Dictionary;
	import flash.utils.Proxy;
	import flash.utils.describeType;
	import flash.utils.flash_proxy;
	import flash.utils.getQualifiedClassName;
	
	import json.JParser;

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
		 * List of RegExp objects used to do a search
		 * with E4J style syntax.
		 */
		private var _expressionList:Array;
		/**
		 * Searches for expressions using the "==" operator.
		 */
		private var _MATCH_EXPRESSION:RegExp;
		/**
		 * Searches for expressions using the "!=" operator.
		 */
		private var _OMIT_EXPRESSION:RegExp;
		/**
		 * Searches for expressions using the ">" operator.
		 */
		private var _GREATER_THAN_EXPRESSION:RegExp;
		/**
		 * Searches for expressions using the ">=" operator.
		 */
		private var _GREATER_OR_EQUAL_EXPRESSION:RegExp;
		/**
		 * Searches for expressions using the "<" operator.
		 */
		private var _LESS_THAN_EXPRESSION:RegExp;
		/**
		 * Searches for expressions using the "<=" operator.
		 */
		private var _LESS_OR_EQUAL_EXPRESSION:RegExp;
		/**
		 * Searches for expressions using the "==" operator.
		 */
		private var _MATCH_EXPRESSION_TEMP:RegExp				= /\((\w+)(\s+)?==(\s+)?(["'])?(\w+)(["'])?\)/gi;
		/**
		 * Searches for expressions using the "!=" operator.
		 */
		private var _OMIT_EXPRESSION_TEMP:RegExp				= /\((\w+)(\s+)?!=(\s+)?(["'])?(\w+)(["'])?\)/gi;
		/**
		 * Searches for expressions using the ">" operator.
		 */
		private var _GREATER_THAN_EXPRESSION_TEMP:RegExp		= /\((\w+)(\s+)?>(\s+)?(["'])?(\w+)(["'])?\)/gi;
		/**
		 * Searches for expressions using the ">=" operator.
		 */
		private var _GREATER_OR_EQUAL_EXPRESSION_TEMP:RegExp	= /\((\w+)(\s+)?>=(\s+)?(["'])?(\w+)(["'])?\)/gi;
		/**
		 * Searches for expressions using the "<" operator.
		 */
		private var _LESS_THAN_EXPRESSION_TEMP:RegExp			= /\((\w+)(\s+)?<(\s+)?(["'])?(\w+)(["'])?\)/gi;
		/**
		 * Searches for expressions using the "<=" operator.
		 */
		private var _LESS_OR_EQUAL_EXPRESSION_TEMP:RegExp		= /\((\w+)(\s+)?<=(\s+)?(["'])?(\w+)(["'])?\)/gi;
		
		/**
		 * List of expressions used to see if a getProperty() call is
		 * actually a query.
		 */
		private const _EXPRESSIONS:Array					= [_MATCH_EXPRESSION_TEMP, _OMIT_EXPRESSION_TEMP, _GREATER_THAN_EXPRESSION_TEMP, _GREATER_OR_EQUAL_EXPRESSION_TEMP, _LESS_THAN_EXPRESSION_TEMP, _LESS_OR_EQUAL_EXPRESSION_TEMP];
		
		/**
		 * This property determines whether or not the JSON class should
		 * throw JSONError objects when it catches certain errors.  This 
		 * property defaults to true.  To turn off JSONError objects from
		 * being thrown the throwJSONErrors property should be set to false.
		 * Some actions such as calling properties on JSON objects that
		 * do not exist will result in null returns.
		 */
		static public var throwJSONErrors:Boolean = true;
		
		static public var encoder:Function = JParser.encode;
		static public var decoder:Function = JParser.decode;
		
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
			
			if (String(json).charAt(0) == "[")
				_objectReference = new Array();
			
			_plainJson = decoder(json);
			
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
	
//				if (target.keys && target.keys.lastIndexOf(key) == -1)
//					target.keys.push(key);
			}
		}
		
		/**
		 * Reinitializes the RegExp objects for a new query, this has to
		 * be done because the RegExp API is weird and subsequent calls
		 * to exec() have to be made to exhaust all matches, which works
		 * in a way that doesn't work well with what its being used for
		 * in this JSON class, so reinitializing the RegExp is the current
		 * solution until I can figure out a better way.
		 */
		private function _initializeExpressionsList():void
		{
			_expressionList = new Array();
			var expr:RegExp;
			var newExpr:RegExp;
			for each (expr in _EXPRESSIONS)
			{
				newExpr = new RegExp(expr);
				switch (expr)
				{
					case _GREATER_THAN_EXPRESSION_TEMP:
						_GREATER_THAN_EXPRESSION = newExpr;
						break;
					case _GREATER_OR_EQUAL_EXPRESSION_TEMP:
						_GREATER_OR_EQUAL_EXPRESSION = newExpr;
						break;
					case _MATCH_EXPRESSION_TEMP:
						_MATCH_EXPRESSION = newExpr;
						break;
					case _LESS_THAN_EXPRESSION_TEMP:
						_LESS_THAN_EXPRESSION = newExpr;
						break;
					case _LESS_OR_EQUAL_EXPRESSION_TEMP:
						_LESS_OR_EQUAL_EXPRESSION = newExpr;
						break;
					case _OMIT_EXPRESSION_TEMP:
						_OMIT_EXPRESSION = newExpr;
						break;
				}
				_expressionList.push(newExpr);
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
		
		/**
		 * This method will decode a JSON string into 
		 * ActionScript 3 classes that it finds aliased. In
		 * order to get classes mapped from the JSON string
		 * into AS3 objects a JSON object "{...}" must have
		 * a property named _explicitType set to the AS3 Class' 
		 * remote class alias, ex. "{'_explicitType':'MyClassAlias'}"
		 * 
		 * @param json String of data in JSON format
		 * 
		 */
		static public function decodeToTyped(json:String):*
		{
			var plainJSON:Object = decoder(json);
			
			var rootType:String = (plainJSON._explicitType) ? plainJSON._explicitType : "Object";
			var rootClass:Class;
			try
			{
				rootClass = getClassByAlias(rootType);
			}
			catch (e:Error)
			{
				rootClass = Object;
			}
			
			var rootObj:* = new rootClass();
			_setStrongProperties(rootObj, plainJSON);
			
			return rootObj;
		}
		
		/**
		 * Encodes an AS3 object into JSON with AS3 types.
		 */
		static public function encodeToTyped(data:*):String
		{
			var rootType:String = _getClassAlias(data);
			
			var root:Object = new Object();
			if (rootType != "Object")
			{
				root._explicitType = rootType;
			}
				
			_encodeStrongProperties(root, data);
			
			return encoder(root);
		}
		/**
		 * Recursive method used to encode an object tree
		 * with class alias info in it, used to encode
		 * JSON structures that can be decoded into AS3
		 * objects by JSON.as
		 */
		static private function _encodeStrongProperties(target:*, source:*):void
		{
			if (!target)
				return;
				
			var sourceKeys:Array = new Array();
			var sourceInfo:XML = describeType(source);
			
			var propertyInfo:XML;
			var propertiesList:XMLList = sourceInfo.descendants("variable");
			for each (propertyInfo in propertiesList)
			{
				if (sourceKeys.lastIndexOf(propertyInfo.@name.toString()) == -1)
				{
					if (propertyInfo.@name.toString() != "_explicitType")
					{
						sourceKeys.push(propertyInfo.@name.toString());
					}
				}
			}
			
			// get dynamic keys
			var dynamicKey:String;
			for (dynamicKey in source)
			{
				if (sourceKeys.lastIndexOf(dynamicKey) == -1)
				{
					sourceKeys.push(dynamicKey);
				}
			}
			
				
			var value:*;
			var className:String;
			var key:String;
			for each (key in sourceKeys)
			{
				value = source[key];
				if (value==null)
				{
					target[key] = null;
					continue;
				}
				
				
				className = getQualifiedClassName(value);
				switch (true)
				{
					case (value is String):
                        target[key] = (value.length) ? value : "";
						break;
					case (value is Boolean):
                        target[key] = (value !== null) ? value : false;
						break;
					case (value is Number):
					case (value is int):
					case (value is uint):
                        target[key] = (value !== null) ? value : null;
						break;
						
					case (className == "Object"):
					case (value is Array):
					default: // Custom classes will fall into this case
						if (className == "Object" || !(value is Array))
						{
							// Look for Class mapping
							target[key] = new Object();
							var alias:String = _getClassAlias(value);
							if (alias != "Object")
							{
								target[key]._explicitType = alias;
							}
						}
						else
						{
							target[key] = new Array();
						}
							
						_encodeStrongProperties(target[key], value);
						break;
				}
				
//				if (target.keys && target.keys.lastIndexOf(key) == -1)
//					target.keys.push(key);
			}
		}
		/**
		 * Used to retrieve the alias of an object instance, if
		 * the object has an alias it is returned, otherwise the
		 * string "Object" is returned.
		 */
		static private function _getClassAlias(obj:*):String
		{
			var classAlias:String = "Object";
			
			var typeInfo:XML = describeType(obj);
			
			classAlias = (typeInfo.@alias.toString()) ? typeInfo.@alias.toString() : "Object";
			
			return classAlias;
		}
		
		/**
		 * Used to set the properties of an AS3 object being
		 * decoded from a JSON object with _explicitType info
		 * in it for class mapping.
		 */
		static private function _setStrongProperties(target:*, source:*):void
		{
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
						if (className == "Object")
						{
							// Look for Class mapping
							if (Object(value).hasOwnProperty("_explicitType"))
							{
								var alias:String = Object(value)._explicitType;
								try
								{
									var mappedClass:Class = getClassByAlias(alias);
									target[key] = new mappedClass();
								}
								catch (e:Error)
								{
									try
									{
										target[key] = new Object();
									}
									catch (e2:Error)
									{
										if (throwJSONErrors)
											throw new JSONError(JSONError.MAPPED_AS3_CLASS_IS_MISSING_PROPERTY + e2.getStackTrace());
									}
								}
							}
							else
							{
								target[key] = new Object();
							}
						}
						else
						{
							target[key] = new Array();
						}
							
						_setStrongProperties(target[key], value);
						break;
				}
				
//				if (target.keys && target.keys.lastIndexOf(key) == -1)
//					target.keys.push(key);
			}
		}
		
		flash_proxy override function callProperty(name:*, ...rest):*
		{
			return null;
		}
		flash_proxy override function deleteProperty(name:*):Boolean
		{
			return false;
		}
		flash_proxy override function getDescendants(name:*):*
		{
			return null;
		}
		flash_proxy override function hasProperty(name:*):Boolean
		{
			if (_objectReference[name] != null)
			{
				return _objectReference[name];
			}
			
			return false;
		}
		flash_proxy override function isAttribute(name:*):Boolean
		{
			return false;
		}
		flash_proxy override function nextNameIndex(index:int):int
		{
			return 0;
		}
		flash_proxy override function nextName(index:int):String
		{
			return "";
		}
		
		/**
		 * Method called when a property value is being retrieved
		 * from this JSON object instance.
		 */
		flash_proxy override function getProperty(name:*):*
		{
//			trace("getProperty()");
//			trace("name = " + name);
			var propertyName:String = QName(name).toString();
			if (propertyName && propertyName.length)
			{
				try
				{
					var value:* = _objectReference[propertyName];
					
					_initializeExpressionsList();
					
					// Look for queries
					var searchKey:String;
					var searchValue:String;
					var matches:Array;
					var item:Object;
					var expr:RegExp;
					var regexResult:*;
					for each (expr in _expressionList)
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
						//return (matches.length == 1) ? matches[0] : matches;
						searchKey = null;
						searchValue = null;
						item = null;
						expr = null;
						regexResult = null;
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
		
		private var _keys:Vector.<String> = new Vector.<String>();
		
		/**
		 * Method called when a property value is set on this
		 * JSON object instance.
		 */
		flash_proxy override function setProperty(name:*, value:*):void
		{
			try
			{
				_objectReference[name] = value;
				
				if (keys && keys.lastIndexOf(name) == -1)
				{
					keys.push(name);
				}
				
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
		
		public function hasKey(keyName:String):Boolean
		{
			return (_keys.lastIndexOf(keyName) > -1);
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

		public function get keys():Vector.<String>
		{
			_keys = new Vector.<String>();
			
			var key:String;
			for (key in objectReference)
			{
				if (_keys.lastIndexOf(key) == -1)
				{
					_keys.push(key);
				}
			}
			
			return _keys;
		}

		public function set keys(keys:Vector.<String>):void
		{
			_keys = keys;
		}
	}
}
