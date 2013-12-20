package org.puremvc.as3.multicore.utilities.net.decoder
{
	import flash.events.IEventDispatcher;


	/**
	 * ...
	 * @author Dukobpa3
	 */
	[Event(name="invalid data type", type="flash.events.DataEvent")]
	[Event(name="invalid package size", type="flash.events.DataEvent")]
	[Event(name="receiving header", type="flash.events.DataEvent")]
	[Event(name="in progress", type="flash.events.DataEvent")]
	[Event(name="done", type="flash.events.DataEvent")]

	public interface IMessageDecoder extends IEventDispatcher
	{
		//=====================================================================
		//	PUBLIC
		//=====================================================================
		/**
		 * Пар�?ит "нечто" которое может быть чем-то вн�?тным, или же байтарреем
		 * @param    message "нечто", которе мы получили �? �?ервера
		 */
		function parse(message:Object):void

		/**
		 * пакует внутреннее "нечто" в �?ерверное
		 * @param    data
		 * @return
		 */
		function pack(data:Object):Object
	}
}