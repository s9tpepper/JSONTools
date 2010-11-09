package ab.fl.utils.json
{
	import mx.collections.ListCollectionView;
	
	/**
	 * The JSONListCollection class allows you to use JSONList type
	 * objects as dataProvider sources for List type components.
	 * 
	 * @author Omar Gonzalez :: omar@almerblank.com :: http://labs.almerblank.com
	 * 
	 */	
	public class JSONListCollection extends ListCollectionView
	{
		/**
		 * Release version, used for reference.
		 */
		//static private const _VERSION:String = "1.0";
		/**
		 * @Constructor
		 * 
		 * @param jsonList
		 * 
		 */
		public function JSONListCollection(jsonList:JSONList=null)
		{
			super();
			
			source = jsonList;
		}
		/**
		 * Returns the source object for the JSONListCollection
		 * 
		 * @return 
		 * 
		 */
		public function get source():Object
		{
			if (list && list is JSONList)
				return JSONList(list).source;
			
			return null;
		}
		/**
		 * Sets the JSONList source object for the JSONListCollection
		 * 
		 * @param value
		 * 
		 */
		public function set source(value:Object):void
		{
			list = (value is JSONList) ? value as JSONList: new JSONList(value as Array);
		}

	}
}
