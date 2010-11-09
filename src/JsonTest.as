package
{
	import com.rational.serialization.json.JSON;
	import com.brokenfunction.json.decodeJson;
	import com.adobe.serialization.json.JSON;
	import flash.net.URLRequest;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.utils.getTimer;
	import mx.utils.ObjectUtil;
	import ab.fl.utils.json.JSON;
	import flash.display.Sprite;

	/**
	 * @author omargonzalez
	 */
	public class JsonTest extends Sprite
	{
		private var _json:ab.fl.utils.json.JSON;
		public function JsonTest()
		{
			_init();
		}

		private function _init():void
		{
			var url:URLLoader = new URLLoader();
				url.addEventListener(Event.COMPLETE, _handleJSONLoaded);
				url.load(new URLRequest("http://plugrman.com/example/json/testJson.txt"));
		}

		private function _handleJSONLoaded(event:Event):void
		{
			// JSON
			var startTime:Number = getTimer();
			_json = new ab.fl.utils.json.JSON(URLLoader(event.target).data);
			var search:Array = _json.DATA["(ID == 355)"]; // Searching for objects in items with id of OpenNew
			trace("search[0].NAME = " + search[0].NAME); // Output: search[0].label = Open New
			var endTime:Number = getTimer();
			trace("Total time elapsed: " + (endTime - startTime).toString() + "ms");
			
			
			// AS3CoreLib
			trace("Starting to parse using as3corelib");
			startTime = getTimer();
			var searchResults:Array = new Array();
			var jsonObj:Object = com.adobe.serialization.json.JSON.decode(URLLoader(event.target).data);
			var jsonItem:Object;
			for each (jsonItem in jsonObj.DATA)
			{
				if (jsonItem.ID == 355)
				{
					searchResults.push(jsonItem);
				}
			}
			trace("searchResults[0].NAME = " + searchResults[0].NAME); 
			endTime = getTimer();
			trace("Total time elapsed: " + (endTime - startTime).toString() + "ms");
			
			
			// actionjson
			trace("Starting to parse using ason");
			startTime = getTimer();
			var searchResults:Array = new Array();
			var jsonObj:Object = com.rational.serialization.json.JSON.decode(URLLoader(event.target).data);
			var jsonItem:Object;
			for each (jsonItem in jsonObj.DATA)
			{
				if (jsonItem.ID == 355)
				{
					searchResults.push(jsonItem);
				}
			}
			trace("searchResults[0].NAME = " + searchResults[0].NAME); 
			endTime = getTimer();
			trace("Total time elapsed: " + (endTime - startTime).toString() + "ms");
		}
	}
}
