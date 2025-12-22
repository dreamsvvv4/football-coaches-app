import React from 'react';
import { View, Text, TouchableOpacity } from 'react-native';
import { useNotifications } from '../services/notifications';

const NotificationBell = () => {
    const { notifications, markAsRead } = useNotifications();

    return (
        <View style={{ position: 'relative' }}>
            <TouchableOpacity onPress={() => markAsRead()}>
                <Text style={{ fontSize: 24 }}>🔔</Text>
            </TouchableOpacity>
            {notifications.length > 0 && (
                <View style={{
                    position: 'absolute',
                    right: 0,
                    top: 0,
                    backgroundColor: 'red',
                    borderRadius: 10,
                    padding: 5,
                }}>
                    <Text style={{ color: 'white', fontWeight: 'bold' }}>{notifications.length}</Text>
                </View>
            )}
        </View>
    );
};

export default NotificationBell;