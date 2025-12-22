import React from 'react';
import { View, Text, FlatList, StyleSheet } from 'react-native';

interface Player {
  id: string;
  name: string;
  age: number;
  position: string;
  photoUrl: string;
}

interface TeamRosterProps {
  players: Player[];
}

const TeamRoster: React.FC<TeamRosterProps> = ({ players }) => {
  const renderPlayer = ({ item }: { item: Player }) => (
    <View style={styles.playerContainer}>
      <Text style={styles.playerName}>{item.name}</Text>
      <Text style={styles.playerDetails}>
        {item.position} - Age: {item.age}
      </Text>
    </View>
  );

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Team Roster</Text>
      <FlatList
        data={players}
        renderItem={renderPlayer}
        keyExtractor={(player) => player.id}
      />
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
    marginBottom: 16,
  },
  playerContainer: {
    padding: 12,
    borderBottomWidth: 1,
    borderBottomColor: '#ccc',
  },
  playerName: {
    fontSize: 18,
    fontWeight: '600',
  },
  playerDetails: {
    fontSize: 14,
    color: '#666',
  },
});

export default TeamRoster;