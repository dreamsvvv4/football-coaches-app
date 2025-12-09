import { Server } from 'socket.io';
import { createServer } from 'http';

class RealtimeService {
    private io: Server;

    constructor(server: any) {
        this.io = new Server(server);
        this.initialize();
    }

    private initialize() {
        this.io.on('connection', (socket) => {
            console.log('A user connected: ' + socket.id);

            socket.on('disconnect', () => {
                console.log('User disconnected: ' + socket.id);
            });

            socket.on('joinMatch', (matchId: string) => {
                socket.join(matchId);
                console.log(`User ${socket.id} joined match ${matchId}`);
            });

            socket.on('liveUpdate', (matchId: string, data: any) => {
                this.io.to(matchId).emit('matchUpdate', data);
            });
        });
    }

    public emitMatchUpdate(matchId: string, data: any) {
        this.io.to(matchId).emit('matchUpdate', data);
    }
}

export default RealtimeService;