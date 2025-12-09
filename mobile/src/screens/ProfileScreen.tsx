import React from 'react';
import { View, Text, StyleSheet, Image } from 'react-native';

const ProfileScreen = () => {
    // Sample user data, this should be fetched from the backend
    const user = {
        name: 'John Doe',
        age: 30,
        role: 'Coach',
        photo: 'https://example.com/photo.jpg',
        team: 'FC Example',
    };

    return (
        <View style={styles.container}>
            <Image source={{ uri: user.photo }} style={styles.profileImage} />
            <Text style={styles.name}>{user.name}</Text>
            <Text style={styles.details}>Age: {user.age}</Text>
            <Text style={styles.details}>Role: {user.role}</Text>
            <Text style={styles.details}>Team: {user.team}</Text>
        </View>
    );
};

const styles = StyleSheet.create({
    container: {
        flex: 1,
        alignItems: 'center',
        justifyContent: 'center',
        padding: 20,
        backgroundColor: '#f5f5f5',
    },
    profileImage: {
        width: 100,
        height: 100,
        borderRadius: 50,
        marginBottom: 20,
    },
    name: {
        fontSize: 24,
        fontWeight: 'bold',
    },
    details: {
        fontSize: 16,
        marginVertical: 5,
    },
});

export default ProfileScreen;