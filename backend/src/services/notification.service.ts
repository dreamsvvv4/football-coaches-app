import { Notification } from '../models/notification.model';
import { User } from '../models/user.model';

class NotificationService {
    async createNotification(userId: string, message: string): Promise<Notification> {
        const notification = new Notification({
            userId,
            message,
            read: false,
            createdAt: new Date(),
        });
        await notification.save();
        return notification;
    }

    async getUserNotifications(userId: string): Promise<Notification[]> {
        return await Notification.find({ userId }).sort({ createdAt: -1 });
    }

    async markAsRead(notificationId: string): Promise<Notification | null> {
        return await Notification.findByIdAndUpdate(notificationId, { read: true }, { new: true });
    }

    async deleteNotification(notificationId: string): Promise<Notification | null> {
        return await Notification.findByIdAndDelete(notificationId);
    }

    async sendPushNotification(user: User, message: string): Promise<void> {
        // Logic to send push notification to the user
        console.log(`Sending push notification to ${user.email}: ${message}`);
    }
}

export default new NotificationService();