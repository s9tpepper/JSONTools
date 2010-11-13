package
{
	import ab.fl.utils.json.JSON;
	import com.project.model.vo.PlayerVO;
	import com.project.model.vo.TeamVO;
	import flash.text.TextFormat;
	import flash.text.TextField;
	import flash.events.Event;
	import flash.display.Sprite;

	/**
	 * @author Omar Gonzalez
	 */
	public class StrongTypedJSONExample extends Sprite
	{
		private var _textField:TextField;
		
		public function StrongTypedJSONExample()
		{
			super();
			
			addEventListener(Event.ADDED_TO_STAGE, _handleAddedToStage, false, 0, true);
		}

		private function _handleAddedToStage(event:Event):void
		{
			// Make a text field to show the encoded JSON
			_createOutputField();
			
			// Register classes to make sure JSON can map them properly
			JSON.registerClass("TeamVO", TeamVO);
			JSON.registerClass("PlayerVO", PlayerVO);
			
			// Create a TeamVO instance with info in it
			var teamVO:TeamVO = _makeATeam();
			
			// Encode the string as JSON with strong type info
			var jsonString:String = JSON.encodeToTyped(teamVO);
			
			// Display JSON in text field
			_textField.text = jsonString;
			
			/* Output:
			 * {
			 * 		"logoURL":"http://team.com/logo.png",
			 * 		"players":
			 * 			[
			 * 				{
			 * 					"position":"Guard",
			 * 					"jerseyNumber":"24",
			 * 					"lastName":"Bryant",
			 * 					"_explicitType":"PlayerVO",
			 * 					"firstName":"Kobe"
			 * 				},
			 * 				{
			 * 					"position":"Forward",
			 * 					"jerseyNumber":"7",
			 * 					"lastName":"Odom",
			 * 					"_explicitType":"PlayerVO",
			 * 					"firstName":"Lamar"
			 * 				}
			 * 			],
			 * 		"_explicitType":"TeamVO",
			 * 		"name":"Lakers"
			 * 	}
			 */
		}

		private function _makeATeam():TeamVO
		{
			var teamVO:TeamVO = new TeamVO();
			teamVO.logoURL = "http://team.com/logo.png";
			teamVO.name = "Lakers";
			teamVO.players = new Array();
			
			var player:PlayerVO = new PlayerVO();
			player.firstName = "Kobe";
			player.jerseyNumber = "24";
			player.lastName = "Bryant";
			player.position = "Guard";
			teamVO.players.push(player);
			
			
			player = new PlayerVO();
			player.firstName = "Lamar";
			player.jerseyNumber = "7";
			player.lastName = "Odom";
			player.position = "Forward";
			teamVO.players.push(player);
			
			return teamVO;
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
