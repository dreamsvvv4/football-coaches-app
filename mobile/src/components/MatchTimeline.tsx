import React from 'react';
import { View, Text, StyleSheet, FlatList } from 'react-native';

interface MatchEvent {
  id: string;
  time: string;
  description: string;
}

interface MatchTimelineProps {
  events: MatchEvent[];
}

const MatchTimeline: React.FC<MatchTimelineProps> = ({ events }) => {
  const renderItem = ({ item }: { item: MatchEvent }) => (
    <View style={styles.eventContainer}>
      <Text style={styles.time}>{item.time}</Text>
      <Text style={styles.description}>{item.description}</Text>
    </View>
  );

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Match Timeline</Text>
      <FlatList
        data={events}
        renderItem={renderItem}
        keyExtractor={(item) => item.id}
      />
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    padding: 16,
    backgroundColor: '#fff',
    borderRadius: 8,
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 2,
  },
  title: {
    fontSize: 18,
    fontWeight: 'bold',
    marginBottom: 8,
  },
  eventContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    paddingVertical: 4,
  },
  time: {
    fontSize: 14,
    color: '#555',
  },
  description: {
    fontSize: 14,
    color: '#333',
  },
});

export default MatchTimeline;