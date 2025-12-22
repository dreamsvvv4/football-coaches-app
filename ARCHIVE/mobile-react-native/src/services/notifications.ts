import { Notifications } from 'react-native-notifications';

export const initializeNotifications = () => {
    Notifications.registerRemoteNotifications();

    Notifications.events().registerNotificationReceivedForeground((notification, completion) => {
        console.log('Notification received in foreground:', notification);
        completion({ alert: false });
    });

    Notifications.events().registerNotificationOpened((notification) => {
        console.log('Notification opened:', notification);
        // Handle navigation or actions based on the notification
    });
};

export const sendNotification = (title: string, body: string) => {
    Notifications.postLocalNotification({
        title: title,
        body: body,
        // Additional options can be added here
    });
};

export const scheduleNotification = (title: string, body: string, date: Date) => {
    Notifications.scheduleLocalNotification({
        title: title,
        body: body,
        fireDate: date.toISOString(),
        // Additional options can be added here
    });
};