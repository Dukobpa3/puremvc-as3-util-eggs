package org.puremvc.as3.multicore.utilities.net.connect
{
	import flash.events.IEventDispatcher;


	/**
	 * ...
	 * @author Dukobpa3
	 */
	public interface IServerConnect extends IEventDispatcher
	{
		/**
		 * Инициализирует �?пи�?ок до�?тупных конфигов (по дефолту �?разу подключает�?�?)
		 * @param    config
		 */
		function init(config:ServerConnectConfig):void;

		function close():void;

		/**
		 * Отправл�?ет команду на �?ервер
		 * @param    data �?об�?твенно данные
		 */
		function send(data:Object):void;

	}

}