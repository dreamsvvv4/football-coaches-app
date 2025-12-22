import React from 'react';
import { View, Text, StyleSheet, FlatList } from 'react-native';
import NotificationBell from '../components/NotificationBell';
import TeamRoster from '../components/TeamRoster';

const HomeScreen = () => {
  const upcomingMatches = [
    { id: '1', teamA: 'Team A', teamB: 'Team B', date: '2023-10-01' },
    { id: '2', teamA: 'Team C', teamB: 'Team D', date: '2023-10-02' },
  ];

  return (
    <View style={styles.container}>
      <NotificationBell />
      <Text style={styles.title}>Upcoming Matches</Text>
      <FlatList
        data={upcomingMatches}
        keyExtractor={(item) => item.id}
        renderItem={({ item }) => (
          <View style={styles.matchItem}>
            <Text>{item.teamA} vs {item.teamB}</Text>
            <Text>{item.date}</Text>
          </View>
        )}
      />
      <Text style={styles.title}>Team Roster</Text>
      <TeamRoster />
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: 16,
    backgroundColor: '#fff',
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    marginVertical: 10,
  },
  matchItem: {
    padding: 10,
    borderBottomWidth: 1,
    borderBottomColor: '#ccc',
  },
});

export default HomeScreen;