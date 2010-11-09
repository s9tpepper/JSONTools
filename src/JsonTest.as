package
{
	import com.project.example.vo.GroupVO;
	import com.rational.serialization.json.JSON;
	import com.adobe.serialization.json.JSON;
	import flash.net.URLRequest;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.utils.getTimer;
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
			// Register mapped classes
			ab.fl.utils.json.JSON.registerClass("GroupVO", GroupVO);
			
			var url:URLLoader = new URLLoader();
				url.addEventListener(Event.COMPLETE, _handleJSONLoaded);
				url.load(new URLRequest("http://plugrman.com/example/json/testJson.txt"));
		}

		private function _handleJSONLoaded(event:Event):void
		{
			// JSONTools
			trace("\n*******************************\nStarting to parse using JSONTools");
			var startTime:Number = getTimer();
			_json = new ab.fl.utils.json.JSON(URLLoader(event.target).data);
			var search:Array = _json.DATA["(ID == 831)"]; // Searching for objects in DATA with ID of 355
			var endTime:Number = getTimer();
			trace("Total time elapsed: " + (endTime - startTime).toString() + "ms");
			trace("search[0] = " + search[0]); // Output: search[0].NAME = AdobeTURK - Ankara - TURKEY
			trace("search[0].NAME = " + search[0].NAME); // Output: search[0].NAME = AdobeTURK - Ankara - TURKEY
			
			
			// AS3CoreLib
			trace("\n*******************************\nStarting to parse using as3corelib");
			startTime = getTimer();
			var searchResults:Array = new Array();
			jsonObj = com.adobe.serialization.json.JSON.decode(URLLoader(event.target).data);
			var jsonItem:Object;
			for each (jsonItem in jsonObj.DATA)
			{
				if (jsonItem.ID == 831)
				{
					searchResults.push(jsonItem);
				}
			}
			endTime = getTimer();
			trace("Total time elapsed: " + (endTime - startTime).toString() + "ms");
			trace("searchResults[0] = " + searchResults[0]); // Output: 
			trace("searchResults[0].NAME = " + searchResults[0].NAME); 
			
			
			// actionjson
			trace("\n*******************************\nStarting to parse using ason");
			startTime = getTimer();
			searchResults = new Array();
			var jsonObj:Object = com.rational.serialization.json.JSON.decode(URLLoader(event.target).data);
			for each (jsonItem in jsonObj.DATA)
			{
				if (jsonItem.ID == 831)
				{
					searchResults.push(jsonItem);
				}
			}
			endTime = getTimer();
			trace("Total time elapsed: " + (endTime - startTime).toString() + "ms");
			trace("searchResults[0] = " + searchResults[0]); // Output: 
			trace("searchResults[0].NAME = " + searchResults[0].NAME); 
		}
	}
}
