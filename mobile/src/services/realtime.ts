import { EventEmitter } from 'events';

class RealtimeService extends EventEmitter {
    constructor() {
        super();
        this.socket = null;
    }

    connect(url) {
        this.socket = new WebSocket(url);

        this.socket.onopen = () => {
            console.log('Connected to the WebSocket server');
        };

        this.socket.onmessage = (event) => {
            const data = JSON.parse(event.data);
            this.emit(data.event, data.payload);
        };

        this.socket.onclose = () => {
            console.log('Disconnected from the WebSocket server');
        };

        this.socket.onerror = (error) => {
            console.error('WebSocket error:', error);
        };
    }

    send(event, payload) {
        if (this.socket && this.socket.readyState === WebSocket.OPEN) {
            this.socket.send(JSON.stringify({ event, payload }));
        } else {
            console.error('WebSocket is not open. Unable to send message.');
        }
    }

    disconnect() {
        if (this.socket) {
            this.socket.close();
        }
    }
}

const realtimeService = new RealtimeService();
export default realtimeService;