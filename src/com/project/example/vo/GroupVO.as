package com.project.example.vo
{
	[RemoteClass(alias="GroupVO")]
	/**
	 * Class represents a group object from the JSON.
	 * Properties are uppercase to match the JSON output.
	 * 
	 * @author Omar Gonzalez
	 */
	public class GroupVO
	{
		public var TAGLINE:String;
        public var AVATAR:String;
        public var NAME:String;
        public var MEMBERCOUNT:Number;
        public var ADDRESS:String;
        public var ID:Number;
        public var LONGITUDE:Number;
        public var URL:String;
        public var TYPE:Number;
        public var LATITUDE:Number;
		public var _explicitType:String;
		
		public function GroupVO()
		{
		}
	}
}
