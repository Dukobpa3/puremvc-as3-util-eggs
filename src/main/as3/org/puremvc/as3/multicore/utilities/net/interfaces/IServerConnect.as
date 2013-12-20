package org.puremvc.as3.multicore.utilities.net.interfaces
{
	import org.puremvc.as3.multicore.utilities.net.ServerConnectConfig;
	import flash.events.IEventDispatcher;


	[Event(name="connected", type="org.puremvc.as3.multicore.utilities.net.events.ConnectorEvent")]
	[Event(name="closeConnection", type="org.puremvc.as3.multicore.utilities.net.events.ConnectorEvent")]
	[Event(name="connectAttempt", type="org.puremvc.as3.multicore.utilities.net.events.ConnectorEvent")]
	[Event(name="sendData", type="org.puremvc.as3.multicore.utilities.net.events.ConnectorEvent")]
	[Event(name="receiveData", type="org.puremvc.as3.multicore.utilities.net.events.ConnectorEvent")]
	[Event(name="connectError", type="org.puremvc.as3.multicore.utilities.net.events.ConnectorEvent")]

	[Event(name="log", type="flash.events.DataEvent")]

	/**
	 * ...
	 * @author Dukobpa3
	 */
	public interface IServerConnect extends IEventDispatcher
	{
		/**
		 * Подключается к определенному конфигу
		 * @param    config
		 */
		function init(config:ServerConnectConfig):void;

		/**
		 * Закрывает подключение
		 */
		function close():void;

		/**
		 * Отправляет команду на сервер
		 * @param    data собственно данные
		 */
		function send(data:Object):void;

	}

}