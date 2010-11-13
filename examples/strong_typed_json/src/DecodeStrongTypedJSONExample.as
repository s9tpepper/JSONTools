package
{
	import mx.utils.ObjectUtil;
	import com.project.model.vo.PlayerVO;
	import com.project.model.vo.TeamVO;
	import ab.fl.utils.json.JSON;
	import flash.events.Event;
	import flash.text.TextFormat;
	import flash.text.TextField;
	import flash.display.Sprite;

	/**
	 * @author Omar Gonzalez
	 */
	public class DecodeStrongTypedJSONExample extends Sprite
	{
		private var _textField:TextField;
		public function DecodeStrongTypedJSONExample()
		{
			super();
			
			addEventListener(Event.ADDED_TO_STAGE, _handleAddedToStage, false, 0, true);
		}

		private function _handleAddedToStage(event:Event):void
		{
			// Create text field to show the trace of the object
			_createOutputField();
			
			// Register classes to make sure they're available to decode
			JSON.registerClass("TeamVO", TeamVO);
			JSON.registerClass("PlayerVO", PlayerVO);
			
			// JSON string generated with EncodeStrongTypedJSONExample.as
			var json:String = '{"logoURL":"http://team.com/logo.png","players":[{"position":"Guard","jerseyNumber":"24","lastName":"Bryant","_explicitType":"PlayerVO","firstName":"Kobe"},{"position":"Forward","jerseyNumber":"7","lastName":"Odom","_explicitType":"PlayerVO","firstName":"Lamar"}],"_explicitType":"TeamVO","name":"Lakers"}';
			
			// Decode JSON string into a TeamVO object
			var teamVO:TeamVO = JSON.decodeToTyped(json);
			
			// Trace the object to a TextField
			_textField.text = ObjectUtil.toString(teamVO);
			
			/** Output:
			 (com.project.model.vo::TeamVO)#0
				  _explicitType = "TeamVO"
				  logoURL = "http://team.com/logo.png"
				  name = "Lakers"
				  players = (Array)#1
				    [0] (com.project.model.vo::PlayerVO)#2
				      _explicitType = "PlayerVO"
				      firstName = "Kobe"
				      jerseyNumber = "24"
				      lastName = "Bryant"
				      position = "Guard"
				    [1] (com.project.model.vo::PlayerVO)#3
				      _explicitType = "PlayerVO"
				      firstName = "Lamar"
				      jerseyNumber = "7"
				      lastName = "Odom"
				      position = "Forward"
			 */
		}
		
		private function _createOutputField():void
		{
			// Create textfield for output
			_textField = new TextField();
			var tf:TextFormat = new TextFormat();
				tf.font = "Courier";
				tf.size = 12;
			_textField.defaultTextFormat = tf;
			_textField.width = 600;
			_textField.height = 600;
			_textField.wordWrap = true;
			_textField.multiline = true;
			addChild(_textField);
		}
	}
}
