package org.puremvc.as3.multicore.utilities.net
{
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;
	import org.puremvc.as3.multicore.utilities.net.connectors.ConnectorsFactory;
	import org.puremvc.as3.multicore.utilities.net.events.ConnectorEvent;
	import org.puremvc.as3.multicore.utilities.net.interfaces.IServerConnect;
	import org.puremvc.as3.multicore.utilities.net.events.DecoderEvent;
	import org.puremvc.as3.multicore.utilities.net.interfaces.IMessageDecoder;


	public class ServerProxy extends Proxy implements IProxy
	{
		//=====================================================================
		//		CONSTANTS
		//=====================================================================
		public static const NAME:String = "serverProxy";

		public static const SERVER_CONNECTED:String = "serverConnected";
		public static const SERVER_DISCONNECTED:String = "serverDisconnected";
		public static const SERVER_DATA_READY:String = "serverDataReady";

		public static const SERVER_ERROR:String = "serverError";
		public static const SERVER_PROGRESS:String = "serverProgress";

		public static const SERVER_LOG:String = "serverLog";

		//=====================================================================
		//		PARAMETERS
		//=====================================================================

		/**
		 * Собственно коннектор
		 */
		private var _connection:IServerConnect;

		/**
		 * 1. При отправке пакует нечто адекватное в неведомую серверную хуйню(ByteArray, String),
		 * 2. При получении распаковывает неведомую серверную хуйню в нечто адекватное
		 * прокси не знает ни первый ни второй формат,
		 * Коннектор соответственно тоже
		 */
		private var _decoder:IMessageDecoder;

		//=====================================================================
		//		CONSTRUCTOR, INIT
		//=====================================================================
		public function ServerProxy(decoder:IMessageDecoder)
		{
			super(NAME);

			_decoder = decoder;
		}

		override public function onRegister():void { }

		override public function onRemove():void
		{
			_connection.close();
			_connection = null;

			_decoder.addEventListener(DecoderEvent.INVALID_DATA_TYPE, onDecoderError);
			_decoder.addEventListener(DecoderEvent.INVALID_PACKAGE_SIZE, onDecoderError);
			_decoder.addEventListener(DecoderEvent.RECEIVING_HEADER, onDecoderProgress);
			_decoder.addEventListener(DecoderEvent.IN_PROGRESS, onDecoderProgress);
			_decoder.addEventListener(DecoderEvent.DONE, onDecoderData);

			_connection.addEventListener(ConnectorEvent.CONNECT_ATTEMPT, onConnectAttempt);
			_connection.addEventListener(ConnectorEvent.CONNECT_ERROR, onConnectError);
			_connection.addEventListener(ConnectorEvent.CONNECTED, onConnected);
			_connection.addEventListener(ConnectorEvent.SEND_DATA, onSendData);
			_connection.addEventListener(ConnectorEvent.RECEIVE_DATA, onReceiveData);
			_connection.addEventListener(ConnectorEvent.CLOSE, onClose);

			_connection.addEventListener(ConnectorEvent.LOG, onLog);
		}

		/**
		 * Добавление сообщения в очередь
		 * @param    message
		 */
		public function sendMessage(message:Object):void
		{
			_connection.send(_decoder.pack(message));
		}

		//-----------------------------
		//	CONNECT
		//-----------------------------
		/**
		 * Инициализируем подключение, подписываемся на события подключения
		 */
		public function connect(connectConfig:ServerConnectConfig):void
		{
			_connection = ConnectorsFactory.getConnector(connectConfig.type);

			_decoder.addEventListener(DecoderEvent.INVALID_DATA_TYPE, onDecoderError);
			_decoder.addEventListener(DecoderEvent.INVALID_PACKAGE_SIZE, onDecoderError);
			_decoder.addEventListener(DecoderEvent.RECEIVING_HEADER, onDecoderProgress);
			_decoder.addEventListener(DecoderEvent.IN_PROGRESS, onDecoderProgress);
			_decoder.addEventListener(DecoderEvent.DONE, onDecoderData);

			_connection.addEventListener(ConnectorEvent.CONNECT_ATTEMPT, onConnectAttempt);
			_connection.addEventListener(ConnectorEvent.CONNECT_ERROR, onConnectError);
			_connection.addEventListener(ConnectorEvent.CONNECTED, onConnected);
			_connection.addEventListener(ConnectorEvent.SEND_DATA, onSendData);
			_connection.addEventListener(ConnectorEvent.RECEIVE_DATA, onReceiveData);
			_connection.addEventListener(ConnectorEvent.CLOSE, onClose);

			_connection.addEventListener(ConnectorEvent.LOG, onLog);

			_connection.init(connectConfig);
		}

		//=====================================================================
		//		PRIVATE
		//=====================================================================

		//=====================================================================
		//		HANDLERS
		//=====================================================================
		//-----------------------------
		//  Connector
		//-----------------------------
		private function onConnectAttempt(event:ConnectorEvent):void
		{
			sendNotification(SERVER_LOG, event.toString());
		}

		private function onConnectError(event:ConnectorEvent):void
		{
			sendNotification(SERVER_ERROR, event);
		}

		private function onConnected(event:ConnectorEvent):void
		{
			sendNotification(SERVER_LOG, event.toString());
			sendNotification(SERVER_CONNECTED);
		}

		private function onSendData(event:ConnectorEvent):void
		{
			sendNotification(SERVER_LOG, event.toString());
		}

		private function onReceiveData(event:ConnectorEvent):void
		{
			sendNotification(SERVER_LOG, event.toString());

			if (_decoder) _decoder.parse(event.data);
		}

		private function onClose(event:ConnectorEvent):void
		{
			sendNotification(SERVER_LOG, event.toString());
			sendNotification(SERVER_DISCONNECTED);
		}

		private function onLog(event:ConnectorEvent):void
		{
			sendNotification(SERVER_LOG, event.toString());
		}

		//-----------------------------
		//  Decoder
		//-----------------------------
		private function onDecoderError(event:DecoderEvent):void
		{
			sendNotification(SERVER_LOG, event.toString());
			sendNotification(SERVER_ERROR, event);
		}

		private function onDecoderProgress(event:DecoderEvent):void
		{
			sendNotification(SERVER_LOG, event.toString());
			sendNotification(SERVER_PROGRESS, event);
		}

		private function onDecoderData(event:DecoderEvent):void
		{
			sendNotification(SERVER_LOG, event.toString());
			sendNotification(SERVER_DATA_READY, event.data);
		}

		//=====================================================================
		//		ACCESSORS
		//=====================================================================
	}
}
