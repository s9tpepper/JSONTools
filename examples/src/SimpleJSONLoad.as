package
{
	import flash.display.StageScaleMode;
	import flash.display.StageAlign;
	import ab.fl.utils.json.JSON;
	import flash.net.URLRequest;
	import flash.events.SecurityErrorEvent;
	import flash.events.IOErrorEvent;
	import flash.text.TextField;
	import flash.net.URLLoader;
	import flash.events.Event;
	import flash.display.Sprite;

	/**
	 * @author Omar Gonzalez
	 */
	public class SimpleJSONLoad extends Sprite
	{
		/**
		 * The URL to the JSON text being loaded.
		 */
		private static const _JSON_URL:String = "http://plugrman.com/example/json/basic_json_example.txt";
		/**
		 * URLLoader object used to load JSON raw string data.
		 */
		private var _urlLoader:URLLoader;
		/**
		 * TextField used to display the JSON that was loaded.
		 */
		private var _rawJSONDisplay:TextField;
		/**
		 * TextField used to display a part of the JSON.
		 */
		private var _selectedJSON:TextField;
		
		/**
		 * @Constructor
		 */
		public function SimpleJSONLoad()
		{
			super();
			_init();
		}

		/**
		 * Initializes the SWF example.
		 */
		private function _init():void
		{
			addEventListener(Event.ADDED_TO_STAGE, _handleAddedToStage, false, 0, true);
		}

		/**
		 * On Event.ADDED_TO_STAGE sets up the example.
		 */
		private function _handleAddedToStage(event:Event):void
		{
			// Stage settings
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			// Set the throw errors flag, true by default, JSONError errors can be turned off by setting to false.
			JSON.throwJSONErrors = true;
			
			
			_createUI();
			_loadJSON();
		}

		/**
		 * Starts the JSON loading process.
		 */
		private function _loadJSON():void
		{
			_urlLoader = new URLLoader();
			_urlLoader.addEventListener(Event.COMPLETE, _handleJsonLoadingComplete, false, 0, true);
			_urlLoader.addEventListener(IOErrorEvent.IO_ERROR, _handleJsonLoadingError, false, 0, true);
			_urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, _handleJsonLoadingError, false, 0, true);
			_urlLoader.load(new URLRequest(_JSON_URL));
		}

		/**
		 * Handles the Event.COMPLETE event from the URLLoader loading the JSON.
		 */
		private function _handleJsonLoadingComplete(event:Event):void
		{
			var json:JSON = new JSON(_urlLoader.data);
			
			_rawJSONDisplay.text = _urlLoader.data;
			_selectedJSON.text += "\n" + json.DATA["(ID == 831)"][0].NAME;
			_selectedJSON.text += "\n" + json.DATA["(ID == 831)"][0].ID;
		}

		/**
		 * Handles any errors loading the JSON file.
		 */
		private function _handleJsonLoadingError(event:Event):void
		{
			_rawJSONDisplay.text = "Error loading JSON.";
		}

		/**
		 * Creates the text fields to display the loaded data.
		 */
		private function _createUI():void
		{
			_rawJSONDisplay = new TextField();
			_rawJSONDisplay.width	= 400;
			_rawJSONDisplay.height = 400;
			addChild(_rawJSONDisplay);

			_selectedJSON = new TextField();
			_selectedJSON.width	= 400;
			_selectedJSON.height = 400;
			_selectedJSON.x = 420;
			addChild(_selectedJSON);
		}
	}
}
