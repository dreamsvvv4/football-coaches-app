import React from 'react';
import { View, Text, FlatList, StyleSheet } from 'react-native';
import TeamRoster from '../components/TeamRoster';
import { Player } from '../../shared/src/types/models';

interface TeamScreenProps {
  route: {
    params: {
      teamName: string;
      players: Player[];
    };
  };
}

const TeamScreen: React.FC<TeamScreenProps> = ({ route }) => {
  const { teamName, players } = route.params;

  return (
    <View style={styles.container}>
      <Text style={styles.title}>{teamName}</Text>
      <FlatList
        data={players}
        renderItem={({ item }) => <TeamRoster player={item} />}
        keyExtractor={(item) => item.id.toString()}
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
});

export default TeamScreen;