package
{
	import mx.utils.ObjectUtil;
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

			ab.fl.utils.json.JSON.throwJSONErrors = false;
			
			/*var url:URLLoader = new URLLoader();
				url.addEventListener(Event.COMPLETE, _handleJSONLoaded);
				url.load(new URLRequest("http://plugrman.com/example/json/testJson.txt"));
			 */
			 
			 var group:GroupVO = new GroupVO();
			group.ID = 1;
			group.ADDRESS = "my address";
			group.AVATAR = "my avatar";
			group.LATITUDE = 13.236;
			group.LONGITUDE = 42.236;
			group.MEMBERCOUNT = 16;
			group.NAME = "my group";
			group.TAGLINE = "my group tagline";
			group.TYPE = 1;
			group.URL = "my group url";

			 var group2:GroupVO = new GroupVO();
			group2.ID = 1;
			group2.ADDRESS = "my other address";
			group2.AVATAR = "my other avatar";
			group2.LATITUDE = 13.236;
			group2.LONGITUDE = 42.236;
			group2.MEMBERCOUNT = 16;
			group2.NAME = "my other group";
			group2.TAGLINE = "my other group tagline";
			group2.TYPE = 1;
			group2.URL = "my other group url";
			group2.groupVO = group;
			
			 trace(ObjectUtil.toString(group2));
			 
			 trace(ab.fl.utils.json.JSON.encodeToTyped(group2));
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
			trace("search[0] = " + search[0]);
			// Output: search[0].NAME = AdobeTURK - Ankara - TURKEY
			trace("search[0].MEMBERCOUNT = " + search[0].MEMBERCOUNT.valueOf());
			trace("GroupVO(search[0].valueOf()).MEMBERCOUNT = " + GroupVO(search[0].valueOf()).MEMBERCOUNT);
			trace("search[0].MEMBERCOUNT = " + search[0].MEMBERCOUNT);
//			trace("search[0] = " + GroupVO(search[0]).LONGITUDE);
//			trace("search[0] = " + GroupVO(search[0]).URL);
			// Output: search[0].NAME = AdobeTURK - Ankara - TURKEY
			trace("search[0].NAME = " + search[0].NAME); // Output: search[0].NAME = AdobeTURK - Ankara - TURKEY
			
			//search[0].NAMEZ = "Hai!";
			trace(search[0].NAMEZ);
			
			
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
