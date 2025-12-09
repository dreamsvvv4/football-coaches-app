import React, { useEffect, useState } from 'react';
import { View, Text, StyleSheet, FlatList } from 'react-native';
import { useRoute } from '@react-navigation/native';
import MatchTimeline from '../components/MatchTimeline';
import { getMatchDetails, subscribeToMatchUpdates } from '../services/realtime';

const MatchLiveScreen = () => {
  const route = useRoute();
  const { matchId } = route.params;
  const [matchDetails, setMatchDetails] = useState(null);
  const [events, setEvents] = useState([]);

  useEffect(() => {
    const fetchMatchDetails = async () => {
      const details = await getMatchDetails(matchId);
      setMatchDetails(details);
    };

    fetchMatchDetails();

    const unsubscribe = subscribeToMatchUpdates(matchId, (newEvent) => {
      setEvents((prevEvents) => [...prevEvents, newEvent]);
    });

    return () => {
      unsubscribe();
    };
  }, [matchId]);

  if (!matchDetails) {
    return (
      <View style={styles.loadingContainer}>
        <Text>Loading match details...</Text>
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <Text style={styles.title}>{matchDetails.title}</Text>
      <MatchTimeline events={events} />
      <FlatList
        data={events}
        keyExtractor={(item) => item.id.toString()}
        renderItem={({ item }) => (
          <View style={styles.eventItem}>
            <Text>{item.description}</Text>
          </View>
        )}
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
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 16,
  },
  eventItem: {
    padding: 10,
    borderBottomWidth: 1,
    borderBottomColor: '#ccc',
  },
});

export default MatchLiveScreen;