package ab.fl.utils.json
{
	/**
	 * @author Omar Gonzalez
	 */
	public class JSONError extends Error
	{
		/**
		 * Error code: 60000.  This error is thrown when an attempt to set 
		 * a property has been made on a property that does not exist. When
		 * not using strong types JSON objects are dynamic and this error
		 * is not thrown when setting an arbritrary property name.  If
		 * an AS3 class was mapped from the JSON string then this error
		 * will be thrown if an attempt is made on setting a property on
		 * an object that does not have that property.
		 */
		static public const ERROR_COMMITING_PROPERTY:String = "JSON Error Code:#60000: Error comitting property '{name}', property does not exist.";
		/**
		 * Error code: 60001.  This error is thrown when an attempt to get 
		 * a property has been made on a property that does not exist on the
		 * JSON object that was decoded.
		 */
		static public const ERROR_GETTING_PROPERTY_DOESNT_EXIST:String = "JSON Error Code:#60001: Error getting property, JSON property '{name}' does not exist.";
		/**
		* Error code: 60002.  This error is thrown when an attempt to set
		* a property has been made on a property that does not exist on the
		* AS3 object that is being mapped.
		*/
		static public const MAPPED_AS3_CLASS_IS_MISSING_PROPERTY:String = "JSON Error Code:#60002: Error setting property on mapped AS3 class, details: ";
		
		
		/**
		 * @Constructor
		 */
		public function JSONError(message:* = "", id:* = 0)
		{
			super(message, id);
		}
	}
}
