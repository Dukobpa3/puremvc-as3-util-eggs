package org.puremvc.as3.multicore.utilities.net
{
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;
	import org.puremvc.as3.multicore.utilities.net.connect.ConnectionEvent;
	import org.puremvc.as3.multicore.utilities.net.connect.IServerConnect;
	import org.puremvc.as3.multicore.utilities.net.connect.ServerConnectConfig;
	import org.puremvc.as3.multicore.utilities.net.connect.SocketConnect;
	import org.puremvc.as3.multicore.utilities.net.decoder.DecoderEvent;
	import org.puremvc.as3.multicore.utilities.net.decoder.IMessageDecoder;
	import org.puremvc.as3.multicore.utilities.net.decoder.ParseStatus;


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

		private static const CONNECTIONS_MAP:Object = {
			"socket":SocketConnect
		}

		//=====================================================================
		//		PARAMETERS
		//=====================================================================
		/** Соб�?твенно коннектор
		 * TODO: перепилить под не�?колько коннекторов, ща�? похуй, рботаем тока �? �?окетом */
		private var _connection:IServerConnect;

		/**
		 * 1. При отправке пакует нечто адекватное в неведомую �?ерверную хуйню(ByteArray, String),
		 * 2. При получении ра�?паковывает неведомую �?ерверную хуйню в нечто адекватное
		 * контроллер не знает ни первый ни второй формат,
		 * Коннектор �?оответ�?твенно тоже
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

		override public function onRegister():void
		{
			_decoder.addEventListener(ParseStatus.INVALID_DATA_TYPE, onDecoderError);
			_decoder.addEventListener(ParseStatus.INVALID_PACKAGE_SIZE, onDecoderError);
			_decoder.addEventListener(ParseStatus.RECEIVING_HEADER, onDecoderProgress);
			_decoder.addEventListener(ParseStatus.IN_PROGRESS, onDecoderProgress);
			_decoder.addEventListener(ParseStatus.DONE, onDecoderData);
		}

		override public function onRemove():void
		{
			_connection.close();
			_connection = null;

			_decoder.addEventListener(ParseStatus.INVALID_DATA_TYPE, onDecoderError);
			_decoder.addEventListener(ParseStatus.INVALID_PACKAGE_SIZE, onDecoderError);
			_decoder.addEventListener(ParseStatus.RECEIVING_HEADER, onDecoderProgress);
			_decoder.addEventListener(ParseStatus.IN_PROGRESS, onDecoderProgress);
			_decoder.addEventListener(ParseStatus.DONE, onDecoderData);

			_connection.addEventListener(ConnectionEvent.CONNECT_ATTEMPT, onConnectAttempt);
			_connection.addEventListener(ConnectionEvent.CONNECT_ERROR, onConnectError);
			_connection.addEventListener(ConnectionEvent.CONNECTED, onConnected);
			_connection.addEventListener(ConnectionEvent.SEND_DATA, onSendData);
			_connection.addEventListener(ConnectionEvent.RECEIVE_DATA, onReceiveData);
			_connection.addEventListener(ConnectionEvent.CLOSE, onClose);

			_connection.addEventListener(ConnectionEvent.LOG, onLog);
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
		 * Инициализируем подключение, подпи�?ываем�?�? на �?обыти�? подключени�?
		 */
		public function connect(connectConfig:ServerConnectConfig):void
		{
			_connection = new (CONNECTIONS_MAP[connectConfig.type] as Class)();

			_decoder.addEventListener(ParseStatus.INVALID_DATA_TYPE, onDecoderError);
			_decoder.addEventListener(ParseStatus.INVALID_PACKAGE_SIZE, onDecoderError);
			_decoder.addEventListener(ParseStatus.RECEIVING_HEADER, onDecoderProgress);
			_decoder.addEventListener(ParseStatus.IN_PROGRESS, onDecoderProgress);
			_decoder.addEventListener(ParseStatus.DONE, onDecoderData);

			_connection.addEventListener(ConnectionEvent.CONNECT_ATTEMPT, onConnectAttempt);
			_connection.addEventListener(ConnectionEvent.CONNECT_ERROR, onConnectError);
			_connection.addEventListener(ConnectionEvent.CONNECTED, onConnected);
			_connection.addEventListener(ConnectionEvent.SEND_DATA, onSendData);
			_connection.addEventListener(ConnectionEvent.RECEIVE_DATA, onReceiveData);
			_connection.addEventListener(ConnectionEvent.CLOSE, onClose);

			_connection.addEventListener(ConnectionEvent.LOG, onLog);

			_connection.init(connectConfig);
		}

		//=====================================================================
		//		PRIVATE
		//=====================================================================

		//=====================================================================
		//		HANDLERS
		//=====================================================================
		private function onConnectAttempt(event:ConnectionEvent):void
		{
			sendNotification(SERVER_LOG, event.toString());
		}

		private function onConnectError(event:ConnectionEvent):void
		{
			sendNotification(SERVER_ERROR, event);
		}

		private function onConnected(event:ConnectionEvent):void
		{
			sendNotification(SERVER_LOG, event.toString());
			sendNotification(SERVER_CONNECTED);
		}

		private function onSendData(event:ConnectionEvent):void
		{
			sendNotification(SERVER_LOG, event.toString());
		}

		/**
		 * Обработка получени�? данных �? �?ервера.
		 * получем �?обытие. Внутри него е�?ть полученные данные.
		 * далее �?мотрим е�?ть ли ошибки. е�?ли е�?ть, то обрабатываем и ретурн.
		 * е�?ли нету ошибок �?мотрим команду. �?екоторые команды требуют отправки дополнительных нотификаций.
		 * �?о нотификации �?разу не отправл�?ем а добавл�?ем в ма�?�?ив.
		 * �?екоторые команды требуют уникального пар�?инга. В таком �?лучаем �?тавим ключ needUpdate = false, чтобы �?тандартный пар�?ер не запу�?кал�?�?
		 * Далее пар�?им �?тандартным пар�?ером.
		 * Потом когда ра�?пар�?или полученные данные - отправл�?ем нотификации из �?пи�?ка.
		 * @param    e
		 */
		private function onReceiveData(event:ConnectionEvent):void
		{
			sendNotification(SERVER_LOG, event.toString());

			if (_decoder) _decoder.parse(event.data);
		}

		private function onClose(event:ConnectionEvent):void
		{
			sendNotification(SERVER_LOG, event.toString());
			sendNotification(SERVER_DISCONNECTED);
		}

		private function onLog(event:ConnectionEvent):void
		{
			sendNotification(SERVER_LOG, event.toString());
		}

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
