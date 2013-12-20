/**
 * Created by Dukobpa3 on 12/20/13.
 */
package org.puremvc.as3.multicore.utilities.net.connectors
{
	import flash.events.EventDispatcher;

	import org.puremvc.as3.multicore.utilities.net.ServerConnectConfig;
	import org.puremvc.as3.multicore.utilities.net.interfaces.IServerConnect;


	public class HttpConnect extends EventDispatcher implements IServerConnect
	{
		public function HttpConnect()
		{
		}

		public function init(config:ServerConnectConfig):void
		{
		}

		public function close():void
		{
		}

		public function send(data:Object):void
		{
		}
	}
}
