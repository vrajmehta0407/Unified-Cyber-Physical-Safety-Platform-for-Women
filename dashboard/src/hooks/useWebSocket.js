const WS_URL = import.meta.env.VITE_WS_URL || 'ws://localhost:8000/ws/sos';

export function connectSosWebSocket(onMessage) {
  let ws;
  let reconnectTimer;

  const connect = () => {
    ws = new WebSocket(WS_URL);
    ws.onmessage = (event) => {
      try {
        onMessage(JSON.parse(event.data));
      } catch {
        onMessage(event.data);
      }
    };
    ws.onclose = () => {
      reconnectTimer = setTimeout(connect, 5000);
    };
  };

  connect();

  return () => {
    clearTimeout(reconnectTimer);
    ws?.close();
  };
}
