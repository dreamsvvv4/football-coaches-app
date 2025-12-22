import React, { useEffect, useState } from 'react';
import { View, Text, FlatList, TextInput, Button, StyleSheet } from 'react-native';
import { getChatMessages, sendMessage } from '../services/api';
import { useRoute } from '@react-navigation/native';

const ChatScreen = () => {
    const route = useRoute();
    const { teamId } = route.params; // Assuming teamId is passed as a parameter
    const [messages, setMessages] = useState([]);
    const [newMessage, setNewMessage] = useState('');

    useEffect(() => {
        const fetchMessages = async () => {
            const fetchedMessages = await getChatMessages(teamId);
            setMessages(fetchedMessages);
        };

        fetchMessages();
    }, [teamId]);

    const handleSendMessage = async () => {
        if (newMessage.trim()) {
            await sendMessage(teamId, newMessage);
            setNewMessage('');
            const updatedMessages = await getChatMessages(teamId);
            setMessages(updatedMessages);
        }
    };

    return (
        <View style={styles.container}>
            <FlatList
                data={messages}
                keyExtractor={(item) => item.id.toString()}
                renderItem={({ item }) => (
                    <View style={styles.messageContainer}>
                        <Text style={styles.messageText}>{item.text}</Text>
                    </View>
                )}
            />
            <TextInput
                style={styles.input}
                value={newMessage}
                onChangeText={setNewMessage}
                placeholder="Type your message..."
            />
            <Button title="Send" onPress={handleSendMessage} />
        </View>
    );
};

const styles = StyleSheet.create({
    container: {
        flex: 1,
        padding: 10,
    },
    messageContainer: {
        marginVertical: 5,
        padding: 10,
        borderRadius: 5,
        backgroundColor: '#f0f0f0',
    },
    messageText: {
        fontSize: 16,
    },
    input: {
        height: 40,
        borderColor: 'gray',
        borderWidth: 1,
        marginBottom: 10,
        paddingHorizontal: 10,
    },
});

export default ChatScreen;