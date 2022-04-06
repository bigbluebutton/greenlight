export default function useRooms() {
  return {
    isLoading: false,
    data:
            [
              {
                name: 'Home Room',
                friendly_id: 'dummy_id1',
              },
              {
                name: 'Room 1',
                friendly_id: 'dummy_id2',
              },
              {
                name: 'Room 2',
                friendly_id: 'dummy_id3',
              },
            ],
  };
}
